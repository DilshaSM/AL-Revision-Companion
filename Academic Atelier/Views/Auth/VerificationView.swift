import SwiftUI

struct VerificationView: View {
    @Environment(\.dismiss) private var dismiss
    let email: String
    
    @State private var codeDigits: [String] = ["", "", "", ""]
    @State private var timeRemaining: Int = 59
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .onReceive(timer) { _ in
            guard timeRemaining > 0 else { return }
            timeRemaining -= 1
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
        NavigationLink {
            NewPasswordView()
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!isCodeComplete)
        .opacity(isCodeComplete ? 1.0 : 0.7)
        .padding(.top, 8)
    }

    var timerSection: some View {
        Text("00:\(String(format: "%02d", timeRemaining))")
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 28)
    }

    var resendSection: some View {
        HStack(spacing: 4) {
            Text("If you didn’t receive a code!")
                .foregroundStyle(.secondary)

            Button("Resend") {
                timeRemaining = 59
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

    func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { codeDigits[index] },
            set: { newValue in
                let filtered = newValue.filter { $0.isNumber }
                codeDigits[index] = String(filtered.prefix(1))
            }
        )
    }
}
