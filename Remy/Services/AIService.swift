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
    private var apiKey: String? {
        // get from keychain eventually
        return nil
    }

    private init() {}
    func generateChatResponse(
        userMessage: String,
        conversationHistory: [(role: String, content: String)]
    ) async throws -> String {
        guard let apiKey = apiKey else {
            throw AIServiceError.missingAPIKey
        }

        // TODO: Implement OpenAI API call
        /*
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = """
        You are Remy, a warm and empathetic AI journaling therapist. Your role is to:
        - Help users explore their thoughts and feelings through gentle questioning
        - Provide supportive, non-judgmental responses
        - Guide users toward self-reflection and personal insights
        - Ask open-ended questions that encourage deeper exploration
        - Validate emotions while offering therapeutic perspectives
        - Suggest journaling prompts when appropriate

        Keep responses conversational, warm, and focused on the user's emotional wellbeing.
        Limit responses to 2-3 sentences to maintain natural conversation flow.
        """

        var messages: [[String: String]] = [["role": "system", "content": systemPrompt]]
        messages += conversationHistory.map { ["role": $0.role, "content": $0.content] }
        messages.append(["role": "user", "content": userMessage])

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.8,
            "max_tokens": 150
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError(statusCode: httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        return result.choices.first?.message.content ?? "I'm here to listen. Please continue."
        */

        // mock response for now
        print("[AIService] Mock: Generating chat response for message length \(userMessage.count)")
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Return contextual mock responses
        if userMessage.lowercased().contains("help") || userMessage.lowercased().contains("how") {
            return "I'm here to support you through your journaling journey. What specific aspect would you like to explore together?"
        } else if userMessage.lowercased().contains("feel") || userMessage.lowercased().contains("feeling") {
            return "Thank you for sharing how you're feeling. Can you tell me more about what's contributing to these emotions?"
        } else if userMessage.lowercased().contains("day") || userMessage.lowercased().contains("today") {
            return "It sounds like your day has been eventful. What stands out to you most about your experience today?"
        } else {
            return "That's a valuable reflection. What insights are emerging for you as you think about this?"
        }
    }
    func analyzeEntry(
        content: String,
        userContext: UserContext,
        entryType: JournalType = .quick
    ) async throws -> AIReflection {
        guard let apiKey = apiKey else {
            throw AIServiceError.missingAPIKey
        }

        // TODO: Implement OpenAI API call
        /*
        let systemPrompt = createContextualPrompt(userContext)
        let userPrompt = createAnalysisPrompt(content, entryType)

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 400
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError(statusCode: httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        let aiText = result.choices.first?.message.content ?? ""

        // Parse the AI response into AIReflection structure
        return parseAIResponse(aiText)
        */

        print("[AIService] Mock: Analyzing entry with content length \(content.count)")
        return AIReflection(
            summary: "This is a thoughtful entry exploring \(entryType.rawValue) themes. You're reflecting on important aspects of your life with honesty and depth.",
            dominantEmotion: userContext.moodHistory.first ?? "neutral",
            followUp: "What would you like to explore more deeply about this experience?",
            personalizedInsight: userContext.totalEntries > 5 ? "I've noticed a pattern in your recent entries focusing on \(userContext.themeHistory.first ?? "personal growth")." : nil,
            moodTrend: userContext.moodHistory.count > 3 ? "Your emotional state has been \(analyzeMoodTrend(userContext.moodHistory))." : nil,
            growthSuggestion: "Consider journaling about specific moments that triggered these feelings to gain deeper insight."
        )
    }
    func transcribeAudio(_ audioURL: URL) async throws -> String {
        guard let apiKey = apiKey else {
            throw AIServiceError.missingAPIKey
        }

        /*
        let url = URL(string: "\(baseURL)/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let audioData = try Data(contentsOf: audioURL)
        let httpBody = createMultipartFormData(
            boundary: boundary,
            audioData: audioData,
            filename: audioURL.lastPathComponent
        )
        request.httpBody = httpBody

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError(statusCode: httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
        return result.text
        */

        print("[AIService] Mock: Transcribing audio from \(audioURL.lastPathComponent)")
        return "This is a mock transcription. Connect OpenAI Whisper API to transcribe actual audio."
    }
    private func createContextualPrompt(_ context: UserContext) -> String {
        """
        You are Remy, an empathetic AI journaling companion. You provide therapeutic insights and reflections.

        User Context:
        - Name: \(context.displayName)
        - Total Entries: \(context.totalEntries)
        - Current Streak: \(context.currentStreak) days
        - Journaling Frequency: \(context.journalingFrequency)
        - Goal: \(context.journalingGoal)
        - Preference: \(context.expressionPreference)

        Recent Emotional Patterns:
        \(context.moodHistory.prefix(5).joined(separator: ", "))

        Recent Themes:
        \(context.themeHistory.prefix(5).joined(separator: ", "))

        Guidelines:
        - Be warm, supportive, and non-judgmental
        - Provide 2-3 sentence personalized summary
        - Identify dominant emotion
        - Ask a thoughtful follow-up question
        - Suggest actionable growth insights when appropriate
        - Reference patterns from their history when relevant
        """
    }
    private func createAnalysisPrompt(_ content: String, _ type: JournalType) -> String {
        """
        Journal Type: \(type.rawValue)
        Entry Content:
        \(content)

        Please provide:
        1. A personalized summary (2-3 sentences)
        2. The dominant emotion expressed
        3. A therapeutic follow-up question
        4. Any patterns you notice (if applicable)
        5. A growth suggestion (if appropriate)

        Format your response as JSON with keys: summary, dominantEmotion, followUp, personalizedInsight, moodTrend, growthSuggestion
        """
    }

    private func parseAIResponse(_ text: String) -> AIReflection {
        return AIReflection(
            summary: text,
            dominantEmotion: "neutral",
            followUp: "How does this reflection make you feel?",
            personalizedInsight: nil,
            moodTrend: nil,
            growthSuggestion: nil
        )
    }
    private func analyzeMoodTrend(_ moods: [String]) -> String {
        guard moods.count >= 3 else { return "variable" }

        let positiveMoods = ["happy", "grateful", "excited"]
        let negativeMoods = ["sad", "anxious", "stressed", "angry"]

        let recentPositive = moods.prefix(3).filter { positiveMoods.contains($0) }.count
        let recentNegative = moods.prefix(3).filter { negativeMoods.contains($0) }.count

        if recentPositive > recentNegative {
            return "generally positive"
        } else if recentNegative > recentPositive {
            return "somewhat challenging"
        } else {
            return "balanced"
        }
    }
    private func createMultipartFormData(
        boundary: String,
        audioData: Data,
        filename: String
    ) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("en\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}

enum AIServiceError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not found. Please add it in Settings."
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let code):
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
