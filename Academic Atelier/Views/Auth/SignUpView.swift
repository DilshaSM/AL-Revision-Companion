import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle.bold())

                Text("Start your personalized A/L revision journey")
                    .foregroundStyle(.secondary)

                AppTextField(
                    title: "Full Name",
                    placeholder: "Enter your full name",
                    text: $viewModel.fullName
                )
                AppTextField(
                    title: "Email",
                    placeholder: "Enter your email",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )
                PasswordField(
                    title: "Password",
                    placeholder: "Enter your password",
                    text: $viewModel.password
                )
                PasswordField(
                    title: "Confirm Password",
                    placeholder: "Confirm your password",
                    text: $viewModel.confirmPassword
                )

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                PrimaryButton(title: "Create Account") {
                    if let user = viewModel.signUp() {
                        session.signIn(user: user)
                    }
                }

                Button("Already have an account? Sign In") {
                    session.authRoute = .signIn
                }
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
