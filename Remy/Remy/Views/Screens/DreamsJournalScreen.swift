//
//  DreamsJournalScreen.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI

struct DreamsJournalScreen: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: JournalViewModel

    @State private var dreamTitle = ""
    @State private var dreamDescription = ""
    @State private var dreamType: DreamType = .normal
    @State private var emotions: Set<DreamEmotion> = []
    @State private var clarity: Double = 3.0
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, description
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F7F1E3").ignoresSafeArea()
                CornerEngraving(pattern: .moon, corner: .topRight, opacity: 0.06)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        DecorativeHeader(
                            title: "Dream Journal",
                            subtitle: "Record your dreams",
                            pattern: .star
                        )
                        .padding(.top, 8)

                        VStack(spacing: 24) {
                            // Dream Title
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Dream Title")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))

                                TextField("e.g., Flying over mountains", text: $dreamTitle)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#2C2C2C"))
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                    )
                                    .focused($focusedField, equals: .title)
                            }

                            // Dream Type
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dream Type")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))

                                HStack(spacing: 10) {
                                    ForEach(DreamType.allCases, id: \.self) { type in
                                        DreamTypeButton(
                                            type: type,
                                            isSelected: dreamType == type
                                        ) {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            dreamType = type
                                        }
                                    }
                                }
                            }

                            // Dream Description
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Dream Description")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))

                                TextEditor(text: $dreamDescription)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "#2C2C2C"))
                                    .frame(height: 150)
                                    .scrollContentBackground(.hidden)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                    )
                                    .focused($focusedField, equals: .description)

                                if dreamDescription.isEmpty {
                                    Text("Describe what you remember...")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                        .padding(.top, -146)
                                        .padding(.leading, 28)
                                        .allowsHitTesting(false)
                                }
                            }

                            // Emotions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Emotions in Dream")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 10) {
                                    ForEach(DreamEmotion.allCases, id: \.self) { emotion in
                                        EmotionToggle(
                                            emotion: emotion,
                                            isSelected: emotions.contains(emotion)
                                        ) {
                                            if emotions.contains(emotion) {
                                                emotions.remove(emotion)
                                            } else {
                                                emotions.insert(emotion)
                                            }
                                        }
                                    }
                                }
                            }

                            // Clarity Slider
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Dream Clarity")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#4A2C1A"))

                                    Spacer()

                                    Text(clarityText)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#9B87F5"))
                                }

                                Slider(value: $clarity, in: 1...5, step: 1)
                                    .tint(Color(hex: "#9B87F5"))
                                    .padding(.horizontal, 8)

                                HStack {
                                    Text("Vague")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                    Spacer()
                                    Text("Crystal Clear")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                            )

                            // Save Button
                            Button(action: saveDream) {
                                HStack(spacing: 10) {
                                    Image(systemName: "moon.stars.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Save Dream")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: isEnabled ? [Color(hex: "#9B87F5"), Color(hex: "#B8A4F7")] : [Color(hex: "#E8DCD1"), Color(hex: "#E8DCD1")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: isEnabled ? Color(hex: "#9B87F5").opacity(0.3) : Color.clear, radius: 15, x: 0, y: 8)
                            }
                            .disabled(!isEnabled)
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 24)
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

    private var isEnabled: Bool {
        !dreamTitle.isEmpty && !dreamDescription.isEmpty
    }

    private var clarityText: String {
        switch Int(clarity) {
        case 1: return "Vague"
        case 2: return "Somewhat Clear"
        case 3: return "Moderate"
        case 4: return "Clear"
        case 5: return "Crystal Clear"
        default: return "Moderate"
        }
    }

    private func saveDream() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        let emotionsText = emotions.map { "\($0.icon) \($0.rawValue.capitalized)" }.joined(separator: ", ")

        var contentParts: [String] = []

        // Dream header
        contentParts.append("🌙 \(dreamTitle)")
        contentParts.append("")

        // Metadata
        contentParts.append("Type: \(dreamType.rawValue.capitalized) \(dreamType.icon)")
        contentParts.append("Clarity: \(clarityText)")
        if !emotionsText.isEmpty {
            contentParts.append("Emotions: \(emotionsText)")
        }
        contentParts.append("")

        // Dream description
        contentParts.append("Dream Description:")
        contentParts.append(dreamDescription)

        let content = contentParts.joined(separator: "\n")

        Task {
            let entry = JournalEntry(
                content: content,
                journalType: .dreams,
                moodTag: .neutral
            )
            await viewModel.createEntry(entry)
            isPresented = false
        }
    }
}

// MARK: - Dream Types
enum DreamType: String, CaseIterable {
    case normal
    case lucid
    case nightmare
    case recurring

    var icon: String {
        switch self {
        case .normal: return "moon.fill"
        case .lucid: return "sparkles"
        case .nightmare: return "exclamationmark.triangle.fill"
        case .recurring: return "arrow.triangle.2.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .normal: return Color(hex: "#9B87F5")
        case .lucid: return Color(hex: "#FFD700")
        case .nightmare: return Color(hex: "#FF6B6B")
        case .recurring: return Color(hex: "#74B9FF")
        }
    }
}

enum DreamEmotion: String, CaseIterable {
    case joy, fear, wonder, sadness, excitement, peace

    var icon: String {
        switch self {
        case .joy: return "😊"
        case .fear: return "😰"
        case .wonder: return "✨"
        case .sadness: return "😢"
        case .excitement: return "🤩"
        case .peace: return "😌"
        }
    }
}

// MARK: - Dream Type Button
struct DreamTypeButton: View {
    let type: DreamType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .medium))
                Text(type.rawValue.capitalized)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "#4A2C1A"))
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? type.color : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(type.color, lineWidth: isSelected ? 0 : 1.5)
            )
            .shadow(color: isSelected ? type.color.opacity(0.3) : Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Emotion Toggle
struct EmotionToggle: View {
    let emotion: DreamEmotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emotion.icon)
                    .font(.system(size: 20))
                Text(emotion.rawValue.capitalized)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color(hex: "#4A2C1A"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? Color(hex: "#9B87F5") : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#9B87F5"), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DreamsJournalScreen(isPresented: .constant(true))
        .environmentObject(JournalViewModel())
}
