//
//  QuickJournalScreen.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct QuickJournalScreen: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: JournalViewModel
    @State private var content = ""
    @State private var selectedMood: MoodTag?
    @State private var selectedTheme: ThemeTag?
    @State private var selectedPrompt: String?
    @State private var isSaving = false

    let quickPrompts = [
        "What made you smile today?",
        "What are you grateful for?",
        "What challenged you today?",
        "What did you learn today?",
        "What are you looking forward to?",
        "How are you feeling right now?",
        "What's on your mind?",
        "What brought you peace today?"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Warm background
                Color(hex: "#F7F1E3")
                    .ignoresSafeArea()

                // Decorative corner engravings
                CornerEngraving(pattern: .leaf, corner: .topRight, opacity: 0.06)
                CornerEngraving(pattern: .flower, corner: .bottomLeft, opacity: 0.06)

                ScrollView {
                    VStack(spacing: 28) {
                        // Decorative header
                        DecorativeHeader(
                            title: "Quick Entry",
                            subtitle: "Capture your thoughts",
                            pattern: .star
                        )
                        .padding(.top, 8)

                        // Quick Prompts Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8B6F4B"))
                                Text("Quick Prompts")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(quickPrompts, id: \.self) { prompt in
                                        ModernPromptChip(
                                            prompt: prompt,
                                            isSelected: selectedPrompt == prompt
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedPrompt = prompt
                                            }
                                            if content.isEmpty {
                                                content = prompt + " "
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color(hex: "#6B4F3B").opacity(0.08), radius: 20, x: 0, y: 8)

                        // Text Editor Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "pencil.and.outline")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8B6F4B"))
                                Text("What's on your mind?")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                            }

                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("Share your thoughts...")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(Color.gray.opacity(0.4))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }

                                TextEditor(text: $content)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "#2C2C2C"))
                                    .frame(minHeight: 180)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .padding(16)
                            .background(Color(hex: "#FFFCF9"))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                            )

                            HStack {
                                Spacer()
                                Text("\(content.count) characters")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(Color(hex: "#8E8E93"))
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color(hex: "#6B4F3B").opacity(0.08), radius: 20, x: 0, y: 8)

                        // Mood Selector - wrapped in card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8B6F4B"))
                                Text("How are you feeling?")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                            }

                            MoodSelector(selectedMood: $selectedMood)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color(hex: "#6B4F3B").opacity(0.08), radius: 20, x: 0, y: 8)

                        // Theme Selector - wrapped in card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8B6F4B"))
                                Text("Choose a theme")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                            }

                            ThemeSelector(selectedTheme: $selectedTheme)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color(hex: "#6B4F3B").opacity(0.08), radius: 20, x: 0, y: 8)

                        // Save Button
                        Button(action: saveEntry) {
                            HStack(spacing: 12) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Save Entry")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color(hex: "#6B4F3B").opacity(0.3), radius: 15, x: 0, y: 8)
                        }
                        .disabled(content.isEmpty || isSaving)
                        .opacity(content.isEmpty || isSaving ? 0.5 : 1.0)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "#6B4F3B"))
                    }
                }
            }
        }
    }

    func saveEntry() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        isSaving = true

        // Create journal entry
        let entry = JournalEntry(
            content: content,
            journalType: .quick,
            moodTag: selectedMood,
            themeTag: selectedTheme
        )

        Task {
            await viewModel.createEntry(entry)
            isSaving = false
            isPresented = false
        }
    }
}

// Modern Prompt Chip
struct ModernPromptChip: View {
    let prompt: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Text(prompt)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(hex: "#6B4F3B"))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color(hex: "#F7F1E3"), Color(hex: "#F7F1E3")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color.clear : Color(hex: "#E8DCD1"),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: isSelected ? Color(hex: "#6B4F3B").opacity(0.2) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct PromptChip: View {
    let prompt: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(prompt)
                .font(.remyBody)
                .foregroundColor(isSelected ? .white : .remyBrown)
                .padding(.horizontal, .md)
                .padding(.vertical, .sm)
                .background(
                    isSelected ? Color.remyBrown : Color.remyBeige
                )
                .clipShape(Capsule())
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true

        var body: some View {
            QuickJournalScreen(isPresented: $isPresented)
        }
    }

    return PreviewWrapper()
}
