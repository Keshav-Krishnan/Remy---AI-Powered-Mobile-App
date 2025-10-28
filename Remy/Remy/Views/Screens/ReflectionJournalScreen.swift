//
//  ReflectionJournalScreen.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI

struct ReflectionJournalScreen: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: JournalViewModel

    @State private var responses: [String: String] = [:]
    @State private var currentPromptIndex = 0
    @FocusState private var isTextEditorFocused: Bool

    let reflectionPrompts = [
        "What was the highlight of your day?",
        "What challenged you today, and how did you respond?",
        "What are you grateful for right now?",
        "What did you learn about yourself today?",
        "How did you show up for yourself or others today?",
        "What would you like to do differently tomorrow?"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F7F1E3").ignoresSafeArea()
                CornerEngraving(pattern: .leaf, corner: .bottomRight, opacity: 0.05)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        DecorativeHeader(
                            title: "Personal Reflection",
                            subtitle: "Guided introspection",
                            pattern: .flower
                        )
                        .padding(.top, 8)

                        VStack(spacing: 20) {
                            // Progress indicator
                            HStack(spacing: 8) {
                                ForEach(0..<reflectionPrompts.count, id: \.self) { index in
                                    Circle()
                                        .fill(index <= currentPromptIndex ? Color(hex: "#9B87F5") : Color(hex: "#E8DCD1"))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.top, 8)

                            // Current prompt
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(hex: "#9B87F5"))

                                    Text("Question \(currentPromptIndex + 1) of \(reflectionPrompts.count)")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                }

                                Text(reflectionPrompts[currentPromptIndex])
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "#9B87F5").opacity(0.1), radius: 12, x: 0, y: 4)

                            // Response area
                            VStack(alignment: .leading, spacing: 10) {
                                TextEditor(text: binding(for: currentPromptIndex))
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "#2C2C2C"))
                                    .frame(height: 200)
                                    .scrollContentBackground(.hidden)
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                    )
                                    .focused($isTextEditorFocused)

                                if responses["\(currentPromptIndex)"]?.isEmpty ?? true {
                                    Text("Take your time to reflect...")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                        .padding(.top, -196)
                                        .padding(.leading, 32)
                                        .allowsHitTesting(false)
                                }
                            }

                            // Navigation buttons
                            HStack(spacing: 12) {
                                if currentPromptIndex > 0 {
                                    Button(action: { currentPromptIndex -= 1 }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "chevron.left")
                                            Text("Previous")
                                        }
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#9B87F5"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "#9B87F5"), lineWidth: 2)
                                        )
                                    }
                                }

                                if currentPromptIndex < reflectionPrompts.count - 1 {
                                    Button(action: { currentPromptIndex += 1 }) {
                                        HStack(spacing: 8) {
                                            Text("Next")
                                            Image(systemName: "chevron.right")
                                        }
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(hex: "#9B87F5"), Color(hex: "#B8A4F7")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                        .shadow(color: Color(hex: "#9B87F5").opacity(0.3), radius: 12, x: 0, y: 4)
                                    }
                                } else {
                                    Button(action: saveReflection) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Complete Reflection")
                                        }
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(hex: "#9B87F5"), Color(hex: "#B8A4F7")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                        .shadow(color: Color(hex: "#9B87F5").opacity(0.3), radius: 12, x: 0, y: 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#8B6F4B"))
                    }
                }
            }
        }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { responses["\(index)"] ?? "" },
            set: { responses["\(index)"] = $0 }
        )
    }

    private func saveReflection() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Only include prompts that have responses
        let answeredPrompts = reflectionPrompts.enumerated().compactMap { index, prompt -> String? in
            guard let response = responses["\(index)"], !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return "Q: \(prompt)\n\nA: \(response)"
        }

        let content = answeredPrompts.isEmpty
            ? "No responses recorded"
            : answeredPrompts.joined(separator: "\n\n---\n\n")

        Task {
            let entry = JournalEntry(
                content: content,
                journalType: .reflection,
                moodTag: .neutral
            )
            await viewModel.createEntry(entry)
            isPresented = false
        }
    }
}

#Preview {
    ReflectionJournalScreen(isPresented: .constant(true))
        .environmentObject(JournalViewModel())
}
