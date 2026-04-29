import SwiftUI

struct SignInView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var showPassword = false
    @State private var isShowingForgotPassword = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.top, 82)

                    formSection
                        .padding(.top, 56)

                    forgotPasswordSection
                        .padding(.top, 26)

                    if session.canUseBiometricQuickLogin {
                        quickAccessSection
                            .padding(.top, 32)
                    }

                    newStudentSection
                        .padding(.top, session.canUseBiometricQuickLogin ? 48 : 32)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $isShowingForgotPassword) {
            NavigationStack {
                ForgotPasswordView {
                    isShowingForgotPassword = false
                }
            }
        }
    }
}

// MARK: - Sections
private extension SignInView {
    var headerSection: some View {
        VStack(spacing: 14) {
            Text("Sign in to continue")
                .font(AppTypography.authScreenTitle)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Access your academic companion")
                .font(AppTypography.authScreenSubtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    var formSection: some View {
        VStack(spacing: 16) {
            StyledTextField(
                title: "EMAIL",
                placeholder: "name@university.edu",
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

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }

            PrimaryButton(
                title: "Sign In",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.password.isEmpty
            ) {
                Task {
                    await viewModel.signIn(using: session)
                }
            }
        }
    }

    var forgotPasswordSection: some View {
        Button("Forgot Password?") {
            isShowingForgotPassword = true
        }
        .font(AppTypography.authInlineAction)
        .foregroundStyle(AppColors.primary)
        .frame(maxWidth: .infinity)
    }

    var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("QUICK ACCESS")
                .font(AppTypography.authSectionLabel)
                .tracking(2.4)
                .foregroundStyle(Color(.systemGray))

            Button {
                Task {
                    await session.signInWithBiometrics()
                }
            } label: {
                HStack(spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primary.opacity(0.10))
                            .frame(width: 60, height: 60)

                        if session.isAuthenticatingWithBiometrics {
                            ProgressView()
                                .tint(AppColors.primary)
                        } else {
                            Image(systemName: session.biometricType.iconSystemName)
                                .frame(width: 30, height: 30)
                                .font(.system(size: 30, weight: .regular))
                                .foregroundStyle(AppColors.primary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.biometricButtonTitle)
                            .font(AppTypography.authFeatureTitle)
                            .foregroundStyle(.primary)

                        Text(session.biometricButtonSubtitle)
                            .font(AppTypography.authFeatureCaption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
                .background(AppColors.cardBackground.opacity(0.02))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(session.isAuthenticatingWithBiometrics || viewModel.isLoading)

            if !session.biometricErrorMessage.isEmpty {
                Text(session.biometricErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    var newStudentSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NEW STUDENT")
                    .font(AppTypography.authCardEyebrow)
                    .tracking(1.8)
                    .foregroundStyle(Color(.systemGray3))

                Text("Join the academy")
                    .font(AppTypography.authCardTitle)
                    .foregroundStyle(.primary)
            }
            
            Spacer()

            Button {
                session.showSignUp()
            } label: {
                Text("Get Started")
                    .font(AppTypography.authPillLabel)
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 16)
                    .frame(height: 32)
                    .background(AppColors.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 76)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
