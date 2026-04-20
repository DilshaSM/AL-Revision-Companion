import SwiftUI

struct SignInView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Academic Atelier")
                .font(.largeTitle.bold())

            Text("Sign in to continue your revision journey")
                .foregroundStyle(.secondary)

            AppTextField(title: "Email", text: $viewModel.email)
            PasswordField(title: "Password", text: $viewModel.password)

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            PrimaryButton(title: "Sign In") {
                if let user = viewModel.signIn() {
                    session.signIn(user: user)
                }
            }

            Button("Create an Account") {
                session.authRoute = .signUp
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
        .background(AppColors.background.ignoresSafeArea())
    }
}
