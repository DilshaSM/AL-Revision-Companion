import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PasswordResetViewModel
    @State private var showVerification = false

    private let onCompleted: () -> Void

    init(
        email: String = "",
        onCompleted: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: PasswordResetViewModel(email: email))
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
        .navigationDestination(isPresented: $showVerification) {
            VerificationView(
                viewModel: viewModel,
                onCompleted: onCompleted
            )
        }
    }
}

// MARK: - Sections
private extension ForgotPasswordView {
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
            Text("Forgot password")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Enter your email for the verification process, we will send 4 digits code to your email.")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
        .padding(.top, 24)
        .padding(.bottom, 24)
    }

    var formSection: some View {
        VStack(spacing: 22) {
            AppTextField(
                title: "Email",
                placeholder: "name@university.edu",
                text: $viewModel.email,
                keyboardType: .emailAddress
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
                title: "Continue",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
                Task {
                    if await viewModel.sendResetCode() {
                        showVerification = true
                    }
                }
            }
        }
    }
}
