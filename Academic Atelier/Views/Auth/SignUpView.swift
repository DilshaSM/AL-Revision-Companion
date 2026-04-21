import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    backButton
                        .padding(.top, 18)

                    headerSection
                        .padding(.top, 25)

                    formSection
                        .padding(.top, 52)

                    helperSection
                        .padding(.top, 28)

                    createButtonSection
                        .padding(.top, 44)

                    termsSection
                        .padding(.top, 56)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Sections
private extension SignUpView {
    var backButton: some View {
        Button {
            session.authRoute = .signIn
        } label: {
            Image(systemName: "arrow.left")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(AppColors.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }

    var headerSection: some View {
        VStack(spacing: 14) {
            Text("Create your account")
                .font(AppTypography.authScreenTitle)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Start your revision journey.")
                .font(AppTypography.authScreenSubtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    var formSection: some View {
        VStack(spacing: 18) {
            StyledTextField(
                title: "FULL NAME",
                placeholder: "Enter your full name",
                text: $viewModel.fullName,
                keyboardType: .default,
                isSecure: false
            )

            StyledTextField(
                title: "EMAIL ADDRESS",
                placeholder: "name@example.com",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                isSecure: false
            )

            StyledTextField(
                title: "PASSWORD",
                placeholder: "••••••••",
                text: $viewModel.password,
                keyboardType: .default,
                isSecure: true,
                isSecureVisible: $showPassword
            )

            StyledTextField(
                title: "CONFIRM PASSWORD",
                placeholder: "••••••••",
                text: $viewModel.confirmPassword,
                keyboardType: .default,
                isSecure: true,
                isSecureVisible: $showConfirmPassword
            )

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            }
        }
    }

    var helperSection: some View {
        VStack(spacing: 22) {
            Text("Your stream can be selected after account creation.")
                .font(AppTypography.authHelperText)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            HStack(spacing: 6) {
                Text("Already have an account?")
                    .font(AppTypography.authPromptBody)
                    .foregroundStyle(.primary)

                Button("Sign In") {
                    session.authRoute = .signIn
                }
                .font(AppTypography.authPromptAction)
                .foregroundStyle(AppColors.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    var createButtonSection: some View {
        PrimaryButton(title: "Create Account") {
            if let user = viewModel.signUp() {
                session.signIn(user: user)
            }
        }
    }

    var termsSection: some View {
        VStack(spacing: 6) {
            Text("By continuing, you agree to Academic Atelier's")
                .font(AppTypography.authLegalCopy)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Button("Terms of Service") {
                    // Later phase
                }
                .font(AppTypography.authLegalCopy)
                .foregroundStyle(.secondary)
                .underline()

                Text("and")
                    .font(AppTypography.authLegalCopy)
                    .foregroundStyle(.secondary)

                Button("Privacy Policy.") {
                    // Later phase
                }
                .font(AppTypography.authLegalCopy)
                .foregroundStyle(.secondary)
                .underline()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
