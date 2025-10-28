//
//  SignInScreen.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI

struct SignInScreen: View {
    @EnvironmentObject var supabaseService: SupabaseService

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "#FDF8F6")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Logo/Header
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "#8B5A3C"))

                            Text("Welcome to Remy")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#5D3A1A"))

                            Text("Your personal journaling companion")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: "#8B5A3C"))
                        }
                        .padding(.top, 60)

                        // Sign In Form
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

                                SecureField("Enter password", text: $password)
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

                            // Sign In Button
                            Button(action: signIn) {
                                HStack(spacing: 10) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                        Text("Sign In")
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

                            // Forgot Password
                            Button(action: { showForgotPassword = true }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 32)

                        // Sign Up Link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color(hex: "#5D3A1A"))

                            Button(action: { showSignUp = true }) {
                                Text("Sign Up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                            }
                        }
                        .padding(.top, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .sheet(isPresented: $showSignUp) {
                SignUpScreen()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordSheet(email: email)
            }
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }

    // MARK: - Actions

    private func signIn() {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        Task {
            do {
                _ = try await supabaseService.signIn(email: email, password: password)
                // Success - auth state will automatically update
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Forgot Password Sheet

struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var supabaseService: SupabaseService

    let email: String

    @State private var resetEmail: String
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    init(email: String) {
        self.email = email
        _resetEmail = State(initialValue: email)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FDF8F6")
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    if showSuccess {
                        // Success State
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "#6BCF7F"))

                            Text("Email Sent!")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#5D3A1A"))

                            Text("Check your inbox for password reset instructions.")
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
                    } else {
                        // Reset Form
                        VStack(spacing: 20) {
                            VStack(spacing: 8) {
                                Text("Reset Password")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#5D3A1A"))

                                Text("Enter your email to receive reset instructions")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(hex: "#8B5A3C"))
                                    .multilineTextAlignment(.center)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "#5D3A1A"))

                                TextField("your@email.com", text: $resetEmail)
                                    .font(.system(size: 16, weight: .regular))
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
                            }

                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }

                            Button(action: sendResetEmail) {
                                HStack(spacing: 10) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Send Reset Link")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#8B5A3C"))
                                .cornerRadius(28)
                            }
                            .disabled(!resetEmail.contains("@") || isLoading)
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                }
                .padding(.top, 40)
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

    private func sendResetEmail() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await supabaseService.resetPassword(email: resetEmail)
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
    SignInScreen()
        .environmentObject(SupabaseService.shared)
}
