//
//  SignUpView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import SwiftUI

// MARK: - SignUpView

/// Sign up screen for creating new user accounts.
///
/// This view is nearly identical to SignInView but with key differences:
///
/// 1. **textContentType: .newPassword** - Triggers strong password suggestions
/// 2. **Different analytics event** - Tracks sign_up instead of sign_in
/// 3. **Sheet presentation** - Dismisses on successful registration
///
/// ## Password Requirements
///
/// Firebase requires passwords to be at least 6 characters.
/// In production, consider adding:
/// - Password strength indicator
/// - Confirm password field
/// - Password visibility toggle
struct SignUpView: View {
    // MARK: Private Properties

    /// Access to dismiss the sheet.
    @Environment(\.dismiss) private var dismiss

    /// Access to shared authentication state.
    @Environment(AuthViewModel.self) private var viewModel

    // MARK: View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection

                    // Sign Up Form
                    signUpForm

                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Sign Up")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - Private Views

extension SignUpView {
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)

            Text("Join ARCFirebase Example")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    private var signUpForm: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 16) {
            // Email Field
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Email address")

            // ================================================================
            // Password Field - Note: .newPassword instead of .password
            // ================================================================
            // Using .newPassword triggers iOS to suggest a strong password
            // and saves it to the Keychain automatically.

            SecureField("Password", text: $viewModel.password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Password")

            // Password requirements hint
            Text("Password must be at least 6 characters")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Sign Up Button
            Button {
                Task {
                    await viewModel.signUp()
                    // Dismiss on success
                    if viewModel.isAuthenticated {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text("Create Account")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Previews

#Preview("Sign Up - Empty") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )

    return SignUpView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Sign Up - Filled") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.email = "newuser@example.com"
    viewModel.password = "securepassword123"

    return SignUpView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Sign Up - Dark Mode") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )

    return SignUpView()
        .environment(viewModel)
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
