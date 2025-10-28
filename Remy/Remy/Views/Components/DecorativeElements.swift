//
//  DecorativeElements.swift
//  Remy
//
//  Minimalist tattoo-style engravings and decorative elements
//

import SwiftUI

// MARK: - Engraving Patterns
enum EngravingPattern: String, CaseIterable {
    case leaf
    case flower
    case moon
    case star
    case branch
    case wave
    case circle
    case line

    var systemImage: String {
        switch self {
        case .leaf: return "leaf.fill"
        case .flower: return "circle.hexagongrid.fill"
        case .moon: return "moon.fill"
        case .star: return "star.fill"
        case .branch: return "leaf.circle"
        case .wave: return "waveform"
        case .circle: return "circle"
        case .line: return "minus"
        }
    }
}

// MARK: - Corner Engraving
struct CornerEngraving: View {
    let pattern: EngravingPattern
    let corner: Corner
    let opacity: Double

    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    var body: some View {
        VStack {
            if corner == .bottomLeft || corner == .bottomRight {
                Spacer()
            }

            HStack {
                if corner == .topRight || corner == .bottomRight {
                    Spacer()
                }

                Image(systemName: pattern.systemImage)
                    .font(.system(size: 30, weight: .ultraLight))
                    .foregroundColor(Color.remyDarkBrown.opacity(opacity))
                    .rotationEffect(rotationAngle)
                    .padding(edgePadding)

                if corner == .topLeft || corner == .bottomLeft {
                    Spacer()
                }
            }

            if corner == .topLeft || corner == .topRight {
                Spacer()
            }
        }
    }

    private var rotationAngle: Angle {
        switch corner {
        case .topLeft: return .degrees(-45)
        case .topRight: return .degrees(45)
        case .bottomLeft: return .degrees(-135)
        case .bottomRight: return .degrees(135)
        }
    }

    private var edgePadding: EdgeInsets {
        let padding: CGFloat = 20
        switch corner {
        case .topLeft: return EdgeInsets(top: padding, leading: padding, bottom: 0, trailing: 0)
        case .topRight: return EdgeInsets(top: padding, leading: 0, bottom: 0, trailing: padding)
        case .bottomLeft: return EdgeInsets(top: 0, leading: padding, bottom: padding, trailing: 0)
        case .bottomRight: return EdgeInsets(top: 0, leading: 0, bottom: padding, trailing: padding)
        }
    }
}

// MARK: - Divider Ornament
struct OrnamentalDivider: View {
    let pattern: EngravingPattern
    let width: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: pattern.systemImage)
                .font(.system(size: 12, weight: .ultraLight))
                .foregroundColor(Color.remyDarkBrown.opacity(0.3))

            Rectangle()
                .fill(Color.remyDarkBrown.opacity(0.15))
                .frame(width: width, height: 1)

            Image(systemName: pattern.systemImage)
                .font(.system(size: 12, weight: .ultraLight))
                .foregroundColor(Color.remyDarkBrown.opacity(0.3))
        }
    }
}

// MARK: - Subtle Background Pattern
struct SubtlePattern: View {
    let pattern: EngravingPattern
    let opacity: Double

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let spacing: CGFloat = 80
                let rows = Int(size.height / spacing) + 1
                let cols = Int(size.width / spacing) + 1

                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * spacing
                        let y = CGFloat(row) * spacing
                        let point = CGPoint(x: x, y: y)

                        // Draw symbol at position
                        context.opacity = opacity
                        context.draw(
                            Text(Image(systemName: pattern.systemImage))
                                .font(.system(size: 16, weight: .ultraLight)),
                            at: point
                        )
                    }
                }
            }
        }
        .foregroundColor(Color.remyDarkBrown.opacity(opacity))
    }
}

// MARK: - Floating Accent
struct FloatingAccent: View {
    let pattern: EngravingPattern
    let position: Position
    let size: CGFloat
    let opacity: Double

    enum Position {
        case topLeading, topTrailing, bottomLeading, bottomTrailing, center
    }

    var body: some View {
        GeometryReader { geometry in
            Image(systemName: pattern.systemImage)
                .font(.system(size: size, weight: .ultraLight))
                .foregroundColor(Color.remyDarkBrown.opacity(opacity))
                .position(calculatePosition(in: geometry.size))
        }
    }

    private func calculatePosition(in size: CGSize) -> CGPoint {
        let padding: CGFloat = 40

        switch position {
        case .topLeading:
            return CGPoint(x: padding, y: padding)
        case .topTrailing:
            return CGPoint(x: size.width - padding, y: padding)
        case .bottomLeading:
            return CGPoint(x: padding, y: size.height - padding)
        case .bottomTrailing:
            return CGPoint(x: size.width - padding, y: size.height - padding)
        case .center:
            return CGPoint(x: size.width / 2, y: size.height / 2)
        }
    }
}

// MARK: - Card Border Ornament
struct OrnamentedCard<Content: View>: View {
    let content: Content
    let pattern: EngravingPattern

    init(pattern: EngravingPattern = .leaf, @ViewBuilder content: () -> Content) {
        self.pattern = pattern
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Main content
            content
                .padding(20)
                .background(Color.remyCardBg)
                .cornerRadius(24)
                .shadow(color: Color.remyDarkBrown.opacity(0.08), radius: 20, x: 0, y: 10)

            // Corner ornaments
            CornerEngraving(pattern: pattern, corner: .topLeft, opacity: 0.08)
            CornerEngraving(pattern: pattern, corner: .bottomRight, opacity: 0.08)
        }
    }
}

// MARK: - Decorative Header
struct DecorativeHeader: View {
    let title: String
    let subtitle: String?
    let pattern: EngravingPattern

    init(title: String, subtitle: String? = nil, pattern: EngravingPattern = .leaf) {
        self.title = title
        self.subtitle = subtitle
        self.pattern = pattern
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: pattern.systemImage)
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundColor(Color.remyDarkBrown.opacity(0.4))

                Text(title)
                    .font(.remyHeadline)
                    .foregroundColor(Color.remyTextPrimary)

                Image(systemName: pattern.systemImage)
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundColor(Color.remyDarkBrown.opacity(0.4))
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.remyCaption)
                    .foregroundColor(Color.remyTextSecondary)
            }
        }
    }
}

// MARK: - Breathing Animation Ornament
struct BreathingOrnament: View {
    let pattern: EngravingPattern
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: pattern.systemImage)
            .font(.system(size: 40, weight: .ultraLight))
            .foregroundColor(Color.remyDarkBrown.opacity(0.1))
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .opacity(isAnimating ? 0.05 : 0.1)
            .animation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Preview
#Preview("Corner Engravings") {
    ZStack {
        Color.remyWarmWhite.ignoresSafeArea()

        VStack {
            Spacer()
            Text("Decorative Corners")
                .font(.remyTitle)
            Spacer()
        }

        CornerEngraving(pattern: .leaf, corner: .topLeft, opacity: 0.1)
        CornerEngraving(pattern: .flower, corner: .topRight, opacity: 0.1)
        CornerEngraving(pattern: .moon, corner: .bottomLeft, opacity: 0.1)
        CornerEngraving(pattern: .star, corner: .bottomRight, opacity: 0.1)
    }
}

#Preview("Ornamented Card") {
    ZStack {
        Color.remyWarmWhite.ignoresSafeArea()

        OrnamentedCard(pattern: .leaf) {
            VStack(spacing: 16) {
                DecorativeHeader(title: "Beautiful Card", subtitle: "With ornamental design", pattern: .flower)

                Text("This is a card with decorative elements that give it a warm, hand-crafted feel.")
                    .font(.remyBody)
                    .foregroundColor(Color.remyTextSecondary)
            }
        }
        .padding(32)
    }
}
