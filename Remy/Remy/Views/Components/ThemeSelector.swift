//
//  ThemeSelector.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct ThemeSelector: View {
    @Binding var selectedTheme: ThemeTag?

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(ThemeTag.allCases) { theme in
                ThemeButton(
                    theme: theme,
                    isSelected: selectedTheme == theme
                ) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTheme = theme
                    }
                }
            }
        }
    }
}

struct ThemeButton: View {
    let theme: ThemeTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon with background circle
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [theme.color.opacity(0.2), theme.color.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(hex: "#F7F1E3"), Color(hex: "#F7F1E3")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? theme.color.opacity(0.4) : Color(hex: "#E8DCD1"),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(
                            color: isSelected ? theme.color.opacity(0.25) : Color.black.opacity(0.05),
                            radius: isSelected ? 8 : 4,
                            x: 0,
                            y: isSelected ? 4 : 2
                        )

                    Image(systemName: theme.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? theme.color : Color(hex: "#6B4F3B"))
                }

                // Label
                Text(theme.displayName)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? theme.color : Color(hex: "#6B4F3B"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        theme.color.opacity(0.08) :
                        Color.white
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? theme.color.opacity(0.3) : Color(hex: "#E8DCD1").opacity(0.5),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTheme: ThemeTag? = .personal

        var body: some View {
            ThemeSelector(selectedTheme: $selectedTheme)
                .padding()
        }
    }

    return PreviewWrapper()
}
