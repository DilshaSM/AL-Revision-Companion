import SwiftUI

struct SignInView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    formSection
                    faceIDSection
                    footerSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Sections
private extension SignInView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("A/L Revision Companion")
                .font(.system(size: 34, weight: .bold))

            Text("Sign in to continue your personalized A/L revision journey.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var formSection: some View {
        VStack(spacing: 18) {
            AppTextField(
                title: "Email Address",
                placeholder: "Enter your email",
                text: $viewModel.email,
                keyboardType: .emailAddress
            )

            PasswordField(
                title: "Password",
                placeholder: "Enter your password",
                text: $viewModel.password,
                textContentType: .password
            )

            HStack {
                Spacer()

                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    Text("Forgot Password?")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(AppColors.primary)
                }
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(title: "Sign In") {
                if let user = viewModel.signIn() {
                    session.signIn(user: user)
                }
            }
        }
    }

    var faceIDSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)

            Button {
                // Face ID will be wired in a later step
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.primary.opacity(0.12))
                            .frame(width: 48, height: 48)

                        Image(systemName: "faceid")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Face ID Login")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Use biometric authentication for faster access.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .shadow(
                    color: .black.opacity(AppTheme.cardShadowOpacity),
                    radius: 10,
                    x: 0,
                    y: 4
                )
            }
            .buttonStyle(.plain)
        }
    }

    var footerSection: some View {
        VStack(spacing: 18) {
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)

                Text("OR")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)
            }

            HStack(spacing: 4) {
                Text("New student?")
                    .foregroundStyle(.secondary)

                Button("Create Account") {
                    session.authRoute = .signUp
                }
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primary)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 8)
    }
}
