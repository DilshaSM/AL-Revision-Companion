import SwiftUI

struct NewPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: SessionViewModel

    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    backButtonSection
                    headerSection
                    formSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Sections
private extension NewPasswordView {
    var backButtonSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColors.primary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    var headerSection: some View {
        VStack(alignment: .center, spacing: 22) {
            Text("New Password")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Set the new password for your account so you can login and access all features.")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
        .padding(.top, 24)
        .padding(.bottom, 18)
    }

    var formSection: some View {
        VStack(spacing: 18) {
            PasswordField(
                title: "Enter New Password",
                placeholder: "8 symbols at least",
                text: $password
            )

            PasswordField(
                title: "Confirm Password",
                placeholder: "8 symbols at least",
                text: $confirmPassword
            )

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                handlePasswordUpdate()
            } label: {
                Text("Update password")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.18), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
    }

    func handlePasswordUpdate() {
        guard !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in both password fields."
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        errorMessage = ""
        session.authRoute = .signIn
    }
}
