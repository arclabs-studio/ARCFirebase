import SwiftUI

struct SignInView: View {
    @Environment(AuthViewModel.self) private var viewModel
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)

                    Text("ARCFirebase Example")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 40)

                // Sign In Form
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            await viewModel.signIn()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 32)

                // Sign Up Link
                Button {
                    showSignUp = true
                } label: {
                    Text("Don't have an account? **Sign Up**")
                        .font(.callout)
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .navigationTitle("Sign In")
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environment(viewModel)
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthViewModel())
}
