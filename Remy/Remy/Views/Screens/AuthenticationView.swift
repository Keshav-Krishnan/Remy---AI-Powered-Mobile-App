//
//  AuthenticationView.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background with decorative elements
            Color(hex: "#FDF8F6")
                .ignoresSafeArea()

            // Decorative corner pattern
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#8B5A3C").opacity(0.08), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(x: 100, y: -100)
                }
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 80)

                    // Logo and Title with shadow
                    VStack(spacing: 20) {
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "#8B5A3C").opacity(0.15), Color.clear],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 140, height: 140)

                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 64, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        Text("Remy")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#5D3A1A"))

                        Text("Your AI-Powered Journal")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#8B5A3C"))
                    }
                    .padding(.bottom, 12)

                    // Auth Form Card
                    VStack(spacing: 24) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#5D3A1A"))

                            TextField("your@email.com", text: $email)
                                .textFieldStyle(RemyTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#5D3A1A"))

                            SecureField("••••••••", text: $password)
                                .textFieldStyle(RemyTextFieldStyle())
                                .textContentType(isSignUp ? .newPassword : .password)
                        }

                        // Error Message
                        if let errorMessage = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Sign In / Sign Up Button
                        Button(action: handleAuth) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: isSignUp ? "person.badge.plus.fill" : "person.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: isFormValid
                                        ? [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")]
                                        : [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: isFormValid ? Color(hex: "#8B5A3C").opacity(0.4) : Color.clear,
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                        }
                        .disabled(isLoading || !isFormValid)
                    }
                    .padding(28)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                    .shadow(color: Color(hex: "#8B5A3C").opacity(0.06), radius: 30, x: 0, y: 15)
                    .padding(.horizontal, 24)

                    // Toggle Sign Up / Sign In
                    Button(action: toggleAuthMode) {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(Color(hex: "#8B5A3C").opacity(0.7))
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .foregroundColor(Color(hex: "#8B5A3C"))
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 16, design: .rounded))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.top, 8)

                    // Privacy Policy Link
                    Link(destination: URL(string: "https://remy-web-policy.vercel.app")!) {
                        HStack(spacing: 4) {
                            Text("By continuing, you agree to our")
                                .foregroundColor(Color(hex: "#8B5A3C").opacity(0.6))
                            Text("Privacy Policy")
                                .foregroundColor(Color(hex: "#8B5A3C"))
                                .fontWeight(.semibold)
                                .underline()
                        }
                        .font(.system(size: 14, design: .rounded))
                    }
                    .padding(.top, 16)

                    Spacer()
                        .frame(height: 60)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }

    // MARK: - Actions

    private func handleAuth() {
        guard isFormValid else { return }

        errorMessage = nil
        isLoading = true

        Task {
            do {
                if isSignUp {
                    _ = try await supabaseService.signUp(email: email, password: password)
                } else {
                    _ = try await supabaseService.signIn(email: email, password: password)
                }

                // Success - SupabaseService will update isAuthenticated
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func toggleAuthMode() {
        isSignUp.toggle()
        errorMessage = nil
    }
}

// MARK: - Custom Text Field Style

struct RemyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(18)
            .background(Color(hex: "#FDF8F6"))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#E8DCD1"), lineWidth: 2)
            )
            .font(.system(size: 16, weight: .medium, design: .rounded))
    }
}

// MARK: - Preview

#Preview {
    AuthenticationView()
}
