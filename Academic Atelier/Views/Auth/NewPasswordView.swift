import SwiftUI

struct NewPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PasswordResetViewModel

    private let onCompleted: () -> Void

    init(
        viewModel: PasswordResetViewModel,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.onCompleted = onCompleted
    }

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
                placeholder: "6 characters at least",
                text: $viewModel.newPassword
            )

            PasswordField(
                title: "Confirm Password",
                placeholder: "6 characters at least",
                text: $viewModel.confirmPassword
            )

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !viewModel.infoMessage.isEmpty {
                Text(viewModel.infoMessage)
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(
                title: "Update password",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.newPassword.isEmpty || viewModel.confirmPassword.isEmpty
            ) {
                Task {
                    if await viewModel.resetPassword() {
                        onCompleted()
                    }
                }
            }
            .padding(.top, 6)
        }
    }
}
