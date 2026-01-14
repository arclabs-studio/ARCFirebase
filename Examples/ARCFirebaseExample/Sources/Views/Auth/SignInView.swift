//
//  SignInView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import SwiftUI

// MARK: - SignInView

/// Sign in screen for user authentication.
///
/// This view demonstrates several SwiftUI best practices:
///
/// 1. **Form Design**: Proper text field configuration for email/password
/// 2. **Loading States**: Disable interactions and show progress during async work
/// 3. **Error Handling**: Display user-friendly error messages
/// 4. **Keyboard Handling**: Appropriate text content types and keyboard types
/// 5. **Accessibility**: Proper labels and hints for VoiceOver
///
/// ## Text Content Types
///
/// Setting correct `textContentType` enables:
/// - Keychain password autofill
/// - Strong password suggestions (for sign up)
/// - Better autocomplete behavior
struct SignInView: View {
    // MARK: Private Properties

    /// Access to shared authentication state.
    @Environment(AuthViewModel.self) private var viewModel

    /// Controls presentation of sign up sheet.
    @State private var showSignUp = false

    // MARK: View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // ============================================================
                    // Header Section
                    // ============================================================
                    headerSection

                    // ============================================================
                    // Sign In Form
                    // ============================================================
                    signInForm

                    // ============================================================
                    // Sign Up Link
                    // ============================================================
                    signUpLink

                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Sign In")
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environment(viewModel)
            }
        }
    }
}

// MARK: - Private Views

extension SignInView {
    private var headerSection: some View {
        VStack(spacing: 12) {
            // App icon
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            // Title
            Text("ARCFirebase Example")
                .font(.title)
                .fontWeight(.bold)

            // Subtitle
            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }

    private var signInForm: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 16) {
            // ================================================================
            // Email Field
            // ================================================================
            // textContentType: .emailAddress enables autofill from contacts
            // keyboardType: .emailAddress shows @ and . prominently
            // autocapitalization: .none prevents auto-capitalizing email

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
            // Password Field
            // ================================================================
            // textContentType: .password enables Keychain autofill
            // SecureField hides the password by default

            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Password")

            // ================================================================
            // Error Message
            // ================================================================
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Error: \(error)")
            }

            // ================================================================
            // Sign In Button
            // ================================================================
            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .accessibilityHint("Double tap to sign in with your email and password")
        }
        .padding(.horizontal, 8)
    }

    private var signUpLink: some View {
        Button {
            showSignUp = true
        } label: {
            Text("Don't have an account? ")
                .foregroundStyle(.secondary)
                +
                Text("Sign Up")
                .fontWeight(.semibold)
        }
        .font(.callout)
        .accessibilityHint("Double tap to create a new account")
    }
}

// MARK: - Previews

#Preview("Sign In - Empty") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )

    return SignInView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Sign In - With Error") {
    let mockAuth = MockAuthProvider.unauthenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.email = "test@example.com"

    return SignInView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Sign In - Loading") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.email = "test@example.com"
    viewModel.password = "password123"

    return SignInView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Sign In - Dark Mode") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )

    return SignInView()
        .environment(viewModel)
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
