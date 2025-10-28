//
//  RemyApp.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

@main
struct RemyApp: App {
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var journalViewModel = JournalViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if supabaseService.isInitializing {
                    // Show beautiful loading screen while initializing
                    SplashLoadingView()
                } else if let error = supabaseService.initializationError {
                    // Show configuration error screen
                    ConfigurationErrorView(errorMessage: error)
                } else if !hasCompletedOnboarding {
                    // Show onboarding first
                    OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
                } else if !supabaseService.isAuthenticated {
                    // Show authentication
                    AuthenticationView()
                        .environmentObject(supabaseService)
                } else {
                    // Show main app
                    ContentView()
                        .environmentObject(journalViewModel)
                        .environmentObject(supabaseService)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: supabaseService.isInitializing)
        }
    }
}

// MARK: - Splash Loading View
struct SplashLoadingView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#FDF8F6"), Color(hex: "#F5EBE0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Animated book icon
                ZStack {
                    // Outer pulsing glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "#8B5A3C").opacity(0.2),
                                    Color(hex: "#8B5A3C").opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.6 : 0.3)

                    // Icon
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 80, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                }

                // App name
                Text("Remy")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#5D3A1A"))
                    .opacity(opacity)

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#8B5A3C")))
                    .scaleEffect(1.2)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                opacity = 1.0
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Configuration Error View
struct ConfigurationErrorView: View {
    let errorMessage: String

    var body: some View {
        ZStack {
            Color(hex: "#FDF8F6")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color(hex: "#FF6B35"))

                Text("Configuration Error")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#5D3A1A"))

                Text(errorMessage)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "#8B5A3C"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 12) {
                    Text("To fix this issue:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#5D3A1A"))

                    Group {
                        Text("1. Ensure Config.xcconfig exists")
                        Text("2. Add your Supabase credentials")
                        Text("3. Clean and rebuild the project")
                    }
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "#8B5A3C"))
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 32)
            }
        }
    }
}
