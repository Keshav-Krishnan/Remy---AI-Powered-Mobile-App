//
//  JournalDetailView.swift
//  Remy
//
//  Detailed view for a single journal entry
//

import SwiftUI

struct JournalDetailView: View {
    @Environment(\.dismiss) var dismiss
    let entry: JournalEntry

    init(entry: JournalEntry) {
        self.entry = entry
        print("[JournalDetailView] Init with entry type: \(entry.journalType.displayName)")
    }

    private var wordCount: Int {
        entry.content.split(separator: " ").count
    }

    private var characterCount: Int {
        entry.content.count
    }

    private var readingTime: Int {
        // Average reading speed: 200 words per minute
        max(1, wordCount / 200)
    }

    private var contentHeaderText: String {
        switch entry.journalType {
        case .reflection: return "Reflection"
        case .goals: return "Goal Details"
        case .dreams: return "Dream Entry"
        case .photo: return entry.imageUri != nil ? "Caption" : "Photo Journal"
        default: return "Journal Entry"
        }
    }

    private var contentFontSize: CGFloat {
        switch entry.journalType {
        case .reflection, .goals, .dreams: return 16
        default: return 17
        }
    }

    private var contentLineSpacing: CGFloat {
        switch entry.journalType {
        case .reflection, .goals, .dreams: return 6
        default: return 8
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background - solid color first
            Color(hex: "#FDF8F6")
                .edgesIgnoringSafeArea(.all)

            // Gradient overlay
            LinearGradient(
                colors: [Color(hex: "#FDF8F6"), Color(hex: "#F5EBE0")],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Custom Header with Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "#8B5A3C"))
                    }

                    Spacer()

                    // Type badge
                    HStack(spacing: 6) {
                        Image(systemName: entry.journalType.icon)
                            .font(.system(size: 14, weight: .medium))
                        Text(entry.journalType.displayName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(colorForType(entry.journalType))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 20)

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Date and Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.timestamp, style: .date)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#5D3A1A"))

                            Text(entry.timestamp, style: .time)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#8B5A3C"))
                        }
                        .padding(.horizontal, 20)

                        // Mood Tag if exists
                        if let mood = entry.moodTag {
                            HStack(spacing: 12) {
                                Text(mood.icon)
                                    .font(.system(size: 24))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Mood")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#8B5A3C"))

                                    Text(mood.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#5D3A1A"))
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(mood.color.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(mood.color.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }

                        // Theme Tag if exists
                        if let theme = entry.themeTag {
                            HStack(spacing: 12) {
                                Image(systemName: theme.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(theme.color)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Theme")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#8B5A3C"))

                                    Text(theme.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#5D3A1A"))
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.color.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(theme.color.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }

                        // Stats Card
                        HStack(spacing: 16) {
                            StatBox(
                                icon: "textformat.size",
                                value: "\(wordCount)",
                                label: "Words"
                            )

                            StatBox(
                                icon: "character.textbox",
                                value: "\(characterCount)",
                                label: "Characters"
                            )

                            StatBox(
                                icon: "clock",
                                value: "\(readingTime) min",
                                label: "Read time"
                            )
                        }
                        .padding(.horizontal, 20)

                        // Photo if exists - show before content
                        if let imageUri = entry.imageUri, let url = URL(string: imageUri) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Photo")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                                    .textCase(.uppercase)
                                    .tracking(1)

                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(hex: "#E8DCD1"))
                                            .frame(height: 250)
                                            .overlay(
                                                ProgressView()
                                                    .tint(Color(hex: "#8B5A3C"))
                                            )
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 250)
                                            .cornerRadius(20)
                                            .clipped()
                                    case .failure:
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(hex: "#E8DCD1"))
                                            .frame(height: 250)
                                            .overlay(
                                                VStack(spacing: 8) {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 48))
                                                        .foregroundColor(Color(hex: "#8B5A3C").opacity(0.3))
                                                    Text("Unable to load photo")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(Color(hex: "#8B5A3C").opacity(0.6))
                                                }
                                            )
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .shadow(color: Color(hex: "#8B5A3C").opacity(0.1), radius: 15, x: 0, y: 5)
                            }
                            .padding(.horizontal, 20)
                        }

                        // Journal Content
                        VStack(alignment: .leading, spacing: 12) {
                            Text(contentHeaderText)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#8B5A3C"))
                                .textCase(.uppercase)
                                .tracking(1)

                            if !entry.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(entry.content)
                                    .font(.system(size: contentFontSize, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "#5D3A1A"))
                                    .lineSpacing(contentLineSpacing)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .textSelection(.enabled)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(hex: "#8B5A3C").opacity(0.3))

                                    Text("No content available")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "#8B5A3C").opacity(0.6))

                                    Text("This entry was saved without content")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "#8B5A3C").opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color(hex: "#8B5A3C").opacity(0.08), radius: 15, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#FDF8F6"))
        .navigationBarHidden(true)
        .onAppear {
            print("[JournalDetailView] ===== VIEW APPEARED =====")
            print("  Type: \(entry.journalType.rawValue) - \(entry.journalType.displayName)")
            print("  ID: \(entry.id)")
            print("  Content length: \(entry.content.count)")
            print("  Content preview: \(String(entry.content.prefix(100)))")
            print("  Has mood: \(entry.moodTag != nil)")
            print("  Has theme: \(entry.themeTag != nil)")
            print("  Has image: \(entry.imageUri != nil)")
            print("  Timestamp: \(entry.timestamp)")
            print("[JournalDetailView] =====================")
        }
    }

    private func colorForType(_ type: JournalType) -> Color {
        switch type {
        case .quick: return Color(hex: "#FF8C42")
        case .personal: return Color(hex: "#9B87F5")
        case .photo: return Color(hex: "#4ECDC4")
        case .gratitude: return Color(hex: "#6BCF7F")
        case .goals: return Color(hex: "#FF6B35")
        case .reflection: return Color(hex: "#9B87F5")
        case .dreams: return Color(hex: "#B4A5F5")
        case .travel: return Color(hex: "#74B9FF")
        }
    }
}

// MARK: - Stat Box Component

struct StatBox: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "#8B5A3C"))

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#5D3A1A"))

            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#8B5A3C"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color(hex: "#8B5A3C").opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview {
    JournalDetailView(
        entry: JournalEntry(
            content: "Today was an amazing day! I finally completed the project I've been working on for weeks. The feeling of accomplishment is incredible. I learned so much throughout this process.",
            journalType: .personal,
            moodTag: .happy,
            themeTag: .work
        )
    )
}
