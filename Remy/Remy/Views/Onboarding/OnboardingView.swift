//
//  OnboardingView.swift
//  Remy
//
//  Simple, sleek 3-page onboarding
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            // Page-specific background
            pageBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            TabView(selection: $currentPage) {
                // Page 1: Hero/Welcome
                Page1Welcome()
                    .tag(0)

                // Page 2: Core Value
                Page2CoreValue()
                    .tag(1)

                // Page 3: Get Started
                Page3GetStarted(isOnboardingComplete: $isOnboardingComplete)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Page Indicator - Lower on screen
            VStack {
                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color(hex: "#8B5A3C") : Color(hex: "#E8DCD1"))
                            .frame(width: currentPage == index ? 10 : 7, height: currentPage == index ? 10 : 7)
                            .shadow(
                                color: currentPage == index ? Color(hex: "#8B5A3C").opacity(0.3) : Color.clear,
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private var pageBackground: some View {
        switch currentPage {
        case 0:
            LinearGradient(
                colors: [Color(hex: "#FDF8F6"), Color(hex: "#F5EBE0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 1:
            LinearGradient(
                colors: [Color(hex: "#E8DCD1"), Color(hex: "#D6C9BC")],
                startPoint: .top,
                endPoint: .bottom
            )
        case 2:
            LinearGradient(
                colors: [Color(hex: "#8B5A3C").opacity(0.05), Color(hex: "#FDF8F6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            Color.white
        }
    }
}

// MARK: - Page 1: Welcome (Centered Hero)

struct Page1Welcome: View {
    @State private var animate = false
    @State private var floatingOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Floating decorative elements
            FloatingDecorativeElements(isAnimating: animate)

            VStack(spacing: 0) {
                Spacer()

                // Large centered icon with animation
                ZStack {
                    // Outer pulsing glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "#8B5A3C").opacity(0.15),
                                    Color(hex: "#8B5A3C").opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .opacity(animate ? 0.8 : 0.4)

                    // Middle ring
                    Circle()
                        .stroke(Color(hex: "#8B5A3C").opacity(0.1), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(animate ? 1.0 : 0.8)
                        .opacity(animate ? 1.0 : 0.0)

                    // Icon
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 100, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animate ? 1.0 : 0.8)
                        .rotationEffect(.degrees(animate ? 0 : -5))
                        .offset(y: floatingOffset)
                }
                .padding(.bottom, 60)

                // Title
                Text("Remy")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#5D3A1A"))
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)

                // Subtitle
                Text("Your personal space\nfor reflection")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "#8B5A3C"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 16)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 30)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animate = true
            }

            // Continuous floating animation
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatingOffset = -8
            }
        }
    }
}

// MARK: - Page 2: Core Value (Split Design)

struct Page2CoreValue: View {
    @State private var animate = false
    @State private var pillAnimation1 = false
    @State private var pillAnimation2 = false

    var body: some View {
        ZStack {
            // Background decorative circles
            Circle()
                .fill(Color(hex: "#FF6B6B").opacity(0.08))
                .frame(width: 150, height: 150)
                .offset(x: -120, y: -200)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0.0)

            Circle()
                .fill(Color(hex: "#4ECDC4").opacity(0.08))
                .frame(width: 120, height: 120)
                .offset(x: 130, y: -150)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0.0)

            VStack(spacing: 0) {
                Spacer()

                // Top section - Visual
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        FeaturePill(icon: "mic.fill", text: "Voice", color: Color(hex: "#FF6B6B"))
                            .scaleEffect(pillAnimation1 ? 1.0 : 0.8)
                        FeaturePill(icon: "photo.fill", text: "Photos", color: Color(hex: "#4ECDC4"))
                            .scaleEffect(pillAnimation1 ? 1.0 : 0.8)
                        FeaturePill(icon: "sparkles", text: "AI", color: Color(hex: "#FFE66D"))
                            .scaleEffect(pillAnimation1 ? 1.0 : 0.8)
                    }
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : -30)

                    HStack(spacing: 16) {
                        FeaturePill(icon: "heart.fill", text: "Mood", color: Color(hex: "#95E1D3"))
                            .scaleEffect(pillAnimation2 ? 1.0 : 0.8)
                        FeaturePill(icon: "chart.line.uptrend.xyaxis", text: "Insights", color: Color(hex: "#F38181"))
                            .scaleEffect(pillAnimation2 ? 1.0 : 0.8)
                    }
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : -30)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Bottom section - Text
                VStack(spacing: 16) {
                    Text("Everything you need")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#5D3A1A"))
                        .multilineTextAlignment(.center)

                    Text("Journal your way with voice, photos, or text.\nTrack your mood and gain AI-powered insights.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#8B5A3C"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                }
                .opacity(animate ? 1.0 : 0.0)
                .offset(y: animate ? 0 : 30)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                pillAnimation1 = true
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.4)) {
                pillAnimation2 = true
            }
        }
    }
}

// MARK: - Page 3: Get Started (Bottom-heavy CTA)

struct Page3GetStarted: View {
    @Binding var isOnboardingComplete: Bool
    @State private var animate = false
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var sparkleOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Decorative sparkles
            VStack {
                HStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FFE66D"))
                        .opacity(sparkleOpacity)
                        .offset(x: -30, y: 100)

                    Spacer()

                    Image(systemName: "sparkle")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#4ECDC4"))
                        .opacity(sparkleOpacity)
                        .offset(x: 50, y: 120)
                }
                Spacer()
            }
            .padding(.horizontal, 40)

            VStack(spacing: 0) {
                Spacer()

                // Animated checkmark icon
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color(hex: "#8B5A3C").opacity(0.2), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(animate ? 1.0 : 0.8)
                        .opacity(animate ? 1.0 : 0.0)

                    // Icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80, weight: .regular))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(checkmarkScale)
                        .rotationEffect(.degrees(animate ? 0 : -180))
                }

                Spacer()

                // Bottom section - Emphasized CTA
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Ready to begin?")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#5D3A1A"))

                        Text("Your journaling journey starts now")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "#8B5A3C"))
                    }
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)

                    // Large CTA Button with animated shadow
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()

                        withAnimation(.spring(response: 0.5)) {
                            isOnboardingComplete = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text("Get Started")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(32)
                        .shadow(color: Color(hex: "#8B5A3C").opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 32)
                    .opacity(animate ? 1.0 : 0.0)
                    .scaleEffect(animate ? 1.0 : 0.9)
                    .offset(y: animate ? 0 : 30)

                    // Skip text
                    Text("No account needed to start")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8B5A3C").opacity(0.6))
                        .opacity(animate ? 1.0 : 0.0)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                animate = true
                checkmarkScale = 1.0
            }

            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                sparkleOpacity = 1.0
            }
        }
    }
}

// MARK: - Feature Pill Component

struct FeaturePill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)

            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#5D3A1A"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Floating Decorative Elements

struct FloatingDecorativeElements: View {
    let isAnimating: Bool
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0
    @State private var offset3: CGFloat = 0

    var body: some View {
        ZStack {
            // Small circle top left
            Circle()
                .fill(Color(hex: "#8B5A3C").opacity(0.06))
                .frame(width: 60, height: 60)
                .offset(x: -140, y: -300 + offset1)
                .opacity(isAnimating ? 1.0 : 0.0)

            // Medium circle top right
            Circle()
                .fill(Color(hex: "#FFE66D").opacity(0.08))
                .frame(width: 80, height: 80)
                .offset(x: 130, y: -250 + offset2)
                .opacity(isAnimating ? 1.0 : 0.0)

            // Small circle bottom
            Circle()
                .fill(Color(hex: "#4ECDC4").opacity(0.06))
                .frame(width: 50, height: 50)
                .offset(x: -120, y: 280 + offset3)
                .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                offset1 = 20
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                offset2 = -15
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                offset3 = 15
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
