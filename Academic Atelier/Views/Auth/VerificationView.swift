import SwiftUI

struct VerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PasswordResetViewModel
    
    @State private var codeDigits: [String] = ["", "", "", ""]
    @State private var currentTime: Date = Date()
    @State private var showNewPassword = false

    private let onCompleted: () -> Void
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                    codeSection
                    actionSection
                    timerSection
                    resendSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showNewPassword) {
            NewPasswordView(
                viewModel: viewModel,
                onCompleted: onCompleted
            )
        }
        .onReceive(timer) { value in
            currentTime = value
        }
        .onAppear {
            syncDigitsFromViewModel()
        }
    }
}

// MARK: - Sections
private extension VerificationView {
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
            Text("Verification")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Enter your 4 digits code that you received on your email.")
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

    var codeSection: some View {
        HStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { index in
                TextField("", text: binding(for: index))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 64, height: 78)
                    .background(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.45), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
    }

    var actionSection: some View {
        VStack(spacing: 14) {
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
                isDisabled: !isCodeComplete
            ) {
                Task {
                    viewModel.verificationCode = codeDigits.joined()

                    if await viewModel.verifyCode() {
                        showNewPassword = true
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    var timerSection: some View {
        Text(timerLabel)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(timeRemaining > 0 ? .orange : .red)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 28)
    }

    var resendSection: some View {
        HStack(spacing: 4) {
            Text("If you didn’t receive a code!")
                .foregroundStyle(.secondary)

            Button("Resend") {
                Task {
                    let didSend = await viewModel.sendResetCode()
                    if didSend {
                        syncDigitsFromViewModel()
                    }
                }
            }
            .foregroundStyle(.orange)
        }
        .font(.system(size: 16, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 4)
    }

    var isCodeComplete: Bool {
        codeDigits.allSatisfy { $0.count == 1 }
    }

    var timeRemaining: Int {
        guard let expiresAt = viewModel.expiresAt else { return 0 }
        return max(0, Int(expiresAt.timeIntervalSince(currentTime)))
    }

    var timerLabel: String {
        if timeRemaining == 0 {
            return "Code expired"
        }

        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { codeDigits[index] },
            set: { newValue in
                let filtered = newValue.filter { $0.isNumber }
                codeDigits[index] = String(filtered.prefix(1))
            }
        )
    }

    func syncDigitsFromViewModel() {
        let digits = Array(viewModel.verificationCode.prefix(4)).map(String.init)

        for index in 0..<codeDigits.count {
            codeDigits[index] = index < digits.count ? digits[index] : ""
        }
    }
}
