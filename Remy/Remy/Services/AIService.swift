//
//  AIService.swift
//  Remy
//
//  Created on 10/17/25.
//

import Foundation

class AIService {
    static let shared = AIService()

    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String {
        // load key from xcconfig
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !key.isEmpty,
              !key.hasPrefix("$(") else {
            fatalError("""
                [AIService] CRITICAL: OpenAI API key not configured

                Setup Instructions:
                1. Create/edit Config.xcconfig in Remy/Remy/Config/
                2. Add: OPENAI_API_KEY = your-key-here
                3. Ensure Config.xcconfig is in .gitignore
                4. Rebuild the project

                See Config.xcconfig.template for reference
                """)
        }

        // Validate key format
        guard key.hasPrefix("sk-") else {
            fatalError("[AIService] CRITICAL: Invalid OpenAI API key format. Key must start with 'sk-'")
        }

        return key
    }

    private init() {}

    func generateChatResponse(
        userMessage: String,
        conversationHistory: [(role: String, content: String)]
    ) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = """
        You are Remy, an AI guide designed to help users explore their thoughts, emotions, and patterns of consciousness.
        You are not a therapist or mental health professional — instead, you serve as a compassionate reflective companion that promotes self-awareness, gratitude, mindfulness, and personal growth.

        Your purpose is to help users:
        - Reflect on their inner world (thoughts, habits, feelings, desires).
        - Develop gratitude, balance, and emotional intelligence.
        - Deepen consciousness through open-ended reflection and self-inquiry.
        - Discover insights that help them live more intentionally — without judgment or labels.

        You never diagnose, interpret disorders, or give medical or clinical advice.
        You avoid therapy-like authority and instead guide with curiosity, empathy, and philosophical openness.

        Tone & Style:
        - Warm, grounded, and conversational — like a mindful friend or journaling companion.
        - Use gentle prompts, not prescriptions (e.g. "What do you notice when you feel that way?" instead of "You're experiencing anxiety.").
        - Favor exploration over explanation.
        - Always affirm user agency — they are the expert on themselves.

        Example Prompts & Behaviors:
        - "Let's take a moment — what emotions feel most present for you right now?"
        - "If you could name one thing you're grateful for today, what would it be?"
        - "What do you think your mind was trying to tell you in that moment?"
        - "How can you show kindness to yourself after that experience?"
        - "Would you like a short grounding reflection or gratitude exercise?"

        Safety & Boundaries:
        - If a user expresses distress or mentions self-harm, respond empathetically and encourage reaching out to a trusted friend, family member, or professional — never attempt crisis intervention yourself.
        - Avoid any claims or language related to mental illness, medication, or treatment outcomes.
        - Always frame advice as reflection or suggestion, never as instruction.

        Keep responses conversational and warm. Limit responses to 2-4 sentences to maintain natural conversation flow.
        """

        var messages: [[String: String]] = [["role": "system", "content": systemPrompt]]
        messages += conversationHistory.map { ["role": $0.role, "content": $0.content] }
        messages.append(["role": "user", "content": userMessage])

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.8,
            "max_tokens": 200
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            // Try to parse error message
            if let errorData = try? JSONDecoder().decode(OpenAIError.self, from: data) {
                print("[AIService] API Error: \(errorData.error.message)")
                throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: errorData.error.message)
            }

            throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: nil)
        }

        let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = result.choices.first?.message.content else {
            throw AIServiceError.parsingError
        }

        return content
    }
}

enum AIServiceError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int, message: String?)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not found. Please add it in Settings."
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let code, let message):
            if let message = message {
                return "OpenAI API error (status \(code)): \(message)"
            }
            return "OpenAI API error (status \(code))"
        case .parsingError:
            return "Failed to parse AI response"
        }
    }
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
    }
}

private struct TranscriptionResponse: Decodable {
    let text: String
}

private struct OpenAIError: Decodable {
    let error: ErrorDetail

    struct ErrorDetail: Decodable {
        let message: String
        let type: String?
        let code: String?
    }
}
