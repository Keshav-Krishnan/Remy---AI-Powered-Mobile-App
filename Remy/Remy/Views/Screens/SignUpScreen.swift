//
//  SignUpScreen.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI

struct SignUpScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var supabaseService: SupabaseService

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, confirmPassword
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "#FDF8F6")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        if showSuccess {
                            // Success State
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(Color(hex: "#6BCF7F"))

                                Text("Account Created!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#5D3A1A"))

                                Text("Check your email to verify your account, then sign in.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)

                                Button(action: { dismiss() }) {
                                    Text("Done")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(hex: "#8B5A3C"))
                                        .cornerRadius(28)
                                }
                                .padding(.horizontal, 32)
                                .padding(.top, 16)
                            }
                            .padding(.top, 80)
                        } else {
                            // Sign Up Form
                            VStack(spacing: 12) {
                                Text("Create Account")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#5D3A1A"))

                                Text("Start your journaling journey")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                            }
                            .padding(.top, 40)

                            VStack(spacing: 20) {
                                // Email Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#5D3A1A"))

                                    TextField("your@email.com", text: $email)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(hex: "#2C2C2C"))
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                        )
                                        .focused($focusedField, equals: .email)
                                }

                                // Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Password")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#5D3A1A"))

                                    SecureField("At least 6 characters", text: $password)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(hex: "#2C2C2C"))
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                        )
                                        .focused($focusedField, equals: .password)

                                    // Password strength indicator
                                    if !password.isEmpty {
                                        HStack(spacing: 4) {
                                            ForEach(0..<3) { index in
                                                Rectangle()
                                                    .fill(index < passwordStrength ? passwordStrengthColor : Color(hex: "#E8DCD1"))
                                                    .frame(height: 4)
                                                    .cornerRadius(2)
                                            }
                                        }

                                        Text(passwordStrengthText)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(passwordStrengthColor)
                                    }
                                }

                                // Confirm Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Confirm Password")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#5D3A1A"))

                                    SecureField("Re-enter password", text: $confirmPassword)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(hex: "#2C2C2C"))
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(passwordsMatch ? Color(hex: "#6BCF7F") : Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                        )
                                        .focused($focusedField, equals: .confirmPassword)

                                    if !confirmPassword.isEmpty && !passwordsMatch {
                                        Text("Passwords don't match")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.red)
                                    }
                                }

                                // Error Message
                                if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                }

                                // Sign Up Button
                                Button(action: signUp) {
                                    HStack(spacing: 10) {
                                        if isLoading {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "person.badge.plus.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                            Text("Create Account")
                                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            colors: isFormValid ? [Color(hex: "#8B5A3C"), Color(hex: "#5D3A1A")] : [Color(hex: "#E8DCD1"), Color(hex: "#E8DCD1")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(28)
                                    .shadow(color: isFormValid ? Color(hex: "#8B5A3C").opacity(0.3) : Color.clear, radius: 15, x: 0, y: 8)
                                }
                                .disabled(!isFormValid || isLoading)
                                .padding(.top, 8)

                                // Terms
                                Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.horizontal, 32)

                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#8B5A3C"))
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        passwordsMatch
    }

    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    private var passwordStrength: Int {
        let length = password.count
        if length < 6 { return 0 }
        if length < 10 { return 1 }
        if length >= 10 && password.rangeOfCharacter(from: .decimalDigits) != nil {
            return 3
        }
        return 2
    }

    private var passwordStrengthText: String {
        switch passwordStrength {
        case 0: return "Too short"
        case 1: return "Weak"
        case 2: return "Good"
        case 3: return "Strong"
        default: return ""
        }
    }

    private var passwordStrengthColor: Color {
        switch passwordStrength {
        case 0: return .red
        case 1: return Color(hex: "#FFB8A3")
        case 2: return Color(hex: "#74B9FF")
        case 3: return Color(hex: "#6BCF7F")
        default: return Color(hex: "#E8DCD1")
        }
    }

    // MARK: - Actions

    private func signUp() {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        Task {
            do {
                _ = try await supabaseService.signUp(email: email, password: password)
                await MainActor.run {
                    showSuccess = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    SignUpScreen()
        .environmentObject(SupabaseService.shared)
}
