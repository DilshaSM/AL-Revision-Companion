import SwiftUI

struct SignUpView: View {
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
private extension SignUpView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("A/L Revision Companion")
                .font(.system(size: 32, weight: .bold))

            Text("Create your account to begin your personalized A/L revision journey.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var formSection: some View {
        VStack(spacing: 18) {
            AppTextField(
                title: "Full Name",
                placeholder: "Enter your full name",
                text: $viewModel.fullName
            )

            AppTextField(
                title: "Email Address",
                placeholder: "Enter your email",
                text: $viewModel.email,
                keyboardType: .emailAddress
            )

            PasswordField(
                title: "Password",
                placeholder: "Create a password",
                text: $viewModel.password,
                textContentType: .newPassword
            )

            PasswordField(
                title: "Confirm Password",
                placeholder: "Re-enter your password",
                text: $viewModel.confirmPassword,
                textContentType: .oneTimeCode
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Your stream will be selected after account creation.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(title: "Create Account") {
                if let user = viewModel.signUp() {
                    session.signIn(user: user)
                }
            }
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
                Text("Already have an account?")
                    .foregroundStyle(.secondary)

                Button("Sign In") {
                    session.authRoute = .signIn
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
