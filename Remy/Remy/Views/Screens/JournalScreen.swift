//
//  JournalScreen.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct JournalScreen: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @FocusState private var isInputFocused: Bool

    private let aiService = AIService.shared

    var body: some View {
        ZStack {
            // Warm background
            Color(hex: "#F7F1E3")
                .ignoresSafeArea()

            // Subtle decorative pattern
            VStack {
                HStack {
                    Spacer()
                    BreathingOrnament(pattern: .flower)
                        .padding(.trailing, 40)
                        .padding(.top, 80)
                }
                Spacer()
            }

            VStack(spacing: 0) {
                // Elegant Header
                VStack(spacing: 12) {
                    // Decorative top ornament
                    OrnamentalDivider(pattern: .star, width: 60)
                        .padding(.top, 8)

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .shadow(color: Color(hex: "#6B4F3B").opacity(0.25), radius: 10, x: 0, y: 4)

                            Image(systemName: "sparkles")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("AI Journal Assistant")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4A2C1A"))

                            Text("Your reflective companion")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: "#8B6F4B"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 50)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#F7F1E3"), Color(hex: "#F7F1E3").opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Messages List
                if messages.isEmpty {
                    ModernEmptyChatView(messageText: $messageText, isInputFocused: $isInputFocused)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                ForEach(messages) { message in
                                    ModernChatBubble(message: message)
                                        .id(message.id)
                                }

                                if isTyping {
                                    ModernTypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                        }
                        .onChange(of: messages.count) { _, _ in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if let lastMessage = messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isTyping) { _, _ in
                            if isTyping {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Aesthetic Input Area - Floating
                HStack(alignment: .bottom, spacing: 14) {
                    // Aesthetic Text Input
                    HStack(spacing: 12) {
                        TextField("Share your thoughts...", text: $messageText, axis: .vertical)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "#2C2C2C"))
                            .lineLimit(1...6)
                            .focused($isInputFocused)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                    .frame(minHeight: 52)
                    .background(Color.white)
                    .cornerRadius(26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: "#6B4F3B").opacity(0.15), radius: 16, x: 0, y: 8)

                    // Aesthetic Send Button
                    Button(action: sendMessage) {
                        ZStack {
                            Circle()
                                .fill(
                                    messageText.isEmpty
                                        ? LinearGradient(
                                            colors: [Color(hex: "#E8DCD1"), Color(hex: "#E8DCD1")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(
                                    color: messageText.isEmpty ? Color.clear : Color(hex: "#6B4F3B").opacity(0.3),
                                    radius: 16,
                                    x: 0,
                                    y: 8
                                )

                            Image(systemName: "arrow.up")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(messageText.isEmpty ? Color(hex: "#8B6F4B").opacity(0.5) : .white)
                        }
                    }
                    .disabled(messageText.isEmpty)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: messageText.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .onAppear {
            // Add welcome message
            if messages.isEmpty {
                messages.append(
                    ChatMessage(
                        content: "Hello! I'm Remy, your reflective companion. I'm here to help you explore your thoughts, emotions, and inner world through mindful conversation. What's on your mind today?",
                        isUser: false
                    )
                )
            }
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        let userMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(userMessage)

        let messageToSend = messageText
        messageText = ""
        isInputFocused = false

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        // Show typing indicator
        isTyping = true

        // Call OpenAI API via AIService
        Task {
            do {
                // Build conversation history
                let conversationHistory = messages.prefix(messages.count - 1).map { message in
                    (role: message.isUser ? "user" : "assistant", content: message.content)
                }

                // Get AI response
                let aiText = try await aiService.generateChatResponse(
                    userMessage: messageToSend,
                    conversationHistory: Array(conversationHistory)
                )

                // Hide typing indicator and show response
                await MainActor.run {
                    isTyping = false
                    let aiResponse = ChatMessage(content: aiText, isUser: false)
                    messages.append(aiResponse)
                }
            } catch {
                // Handle errors gracefully
                await MainActor.run {
                    isTyping = false

                    // Show detailed error for debugging
                    let errorDetails = error.localizedDescription
                    print("[JournalScreen] Error generating AI response: \(errorDetails)")
                    print("[JournalScreen] Full error: \(error)")

                    let errorMessage = ChatMessage(
                        content: "I'm having trouble connecting right now. Error: \(errorDetails)\n\nPlease check the console logs for details.",
                        isUser: false
                    )
                    messages.append(errorMessage)
                }
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(message.isUser ? .white : .remyTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser
                            ? LinearGradient(
                                colors: [Color.remyBrown, Color.remyDarkBrown],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white, Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .cornerRadius(20)
                    .shadow(
                        color: message.isUser ? .remyBrown.opacity(0.2) : .black.opacity(0.06),
                        radius: 8,
                        x: 0,
                        y: 3
                    )

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.remyTextSecondary)
                    .padding(.horizontal, 4)
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Modern Chat Bubble
struct ModernChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser {
                Spacer(minLength: 50)
            } else {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#6B4F3B").opacity(0.15), Color(hex: "#8B6F4B").opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#6B4F3B"))
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(message.isUser ? .white : Color(hex: "#2C2C2C"))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        message.isUser
                            ? LinearGradient(
                                colors: [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white, Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                message.isUser ? Color.clear : Color(hex: "#E8DCD1").opacity(0.6),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: message.isUser ? Color(hex: "#6B4F3B").opacity(0.2) : Color(hex: "#6B4F3B").opacity(0.06),
                        radius: 12,
                        x: 0,
                        y: 4
                    )

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "#8E8E93"))
                    .padding(.horizontal, 6)
            }

            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationPhase: Int = 0

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.remyTextSecondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)

            Spacer(minLength: 60)
        }
        .onAppear {
            animationPhase = 1
        }
    }
}

// MARK: - Modern Typing Indicator
struct ModernTypingIndicator: View {
    @State private var animationPhase: Int = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6B4F3B").opacity(0.15), Color(hex: "#8B6F4B").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#6B4F3B"))
            }

            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(hex: "#8B6F4B").opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.3 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(hex: "#E8DCD1").opacity(0.6), lineWidth: 1)
            )
            .shadow(color: Color(hex: "#6B4F3B").opacity(0.06), radius: 12, x: 0, y: 4)

            Spacer(minLength: 50)
        }
        .onAppear {
            animationPhase = 1
        }
    }
}

// MARK: - Empty Chat View
struct EmptyChatView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.remyBrown.opacity(0.1), Color.remyLightBrown.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "sparkles")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.remyBrown)
            }

            VStack(spacing: 12) {
                Text("Start a Conversation")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.remyTextPrimary)

                Text("Ask me anything about journaling, reflection, or share your thoughts. I'm here to help!")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.remyTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Suggested prompts
            VStack(spacing: 10) {
                Text("Try asking:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.remyTextSecondary)

                VStack(spacing: 8) {
                    SuggestedPromptButton(text: "How can I build a consistent journaling habit?")
                    SuggestedPromptButton(text: "Help me reflect on my day")
                    SuggestedPromptButton(text: "What should I write about?")
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modern Empty Chat View
struct ModernEmptyChatView: View {
    @Binding var messageText: String
    @FocusState.Binding var isInputFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // Decorative ornament
                OrnamentalDivider(pattern: .flower, width: 80)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#6B4F3B").opacity(0.12), Color(hex: "#8B6F4B").opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)

                    BreathingOrnament(pattern: .star)
                        .frame(width: 60, height: 60)
                }

                VStack(spacing: 14) {
                    Text("Begin Your Journey")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4A2C1A"))

                    Text("Share your thoughts and let's explore them together. I'm here to listen and reflect with you.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#8B6F4B"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                // Suggested prompts
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#8B6F4B"))
                        Text("Suggested prompts")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#8B6F4B"))
                    }

                    VStack(spacing: 12) {
                        ModernSuggestedPrompt(text: "How can I build a consistent journaling habit?") {
                            messageText = "How can I build a consistent journaling habit?"
                            isInputFocused = true
                        }
                        ModernSuggestedPrompt(text: "Help me reflect on my day") {
                            messageText = "Help me reflect on my day"
                            isInputFocused = true
                        }
                        ModernSuggestedPrompt(text: "What should I write about today?") {
                            messageText = "What should I write about today?"
                            isInputFocused = true
                        }
                        ModernSuggestedPrompt(text: "Guide me through gratitude journaling") {
                            messageText = "Guide me through gratitude journaling"
                            isInputFocused = true
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Suggested Prompt Button
struct SuggestedPromptButton: View {
    let text: String

    var body: some View {
        Button(action: {
            // TODO: Auto-fill the input with this prompt
        }) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.remyBrown)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Modern Suggested Prompt
struct ModernSuggestedPrompt: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack {
                Text(text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#4A2C1A"))
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#8B6F4B"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
            )
            .shadow(color: Color(hex: "#6B4F3B").opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    JournalScreen()
        .environmentObject(JournalViewModel())
}
