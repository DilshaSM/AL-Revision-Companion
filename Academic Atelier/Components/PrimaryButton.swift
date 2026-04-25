import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(isDisabled ? AppColors.primary.opacity(0.55) : AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(
                color: AppColors.primary.opacity(0.20),
                radius: 10,
                x: 0,
                y: 8
            )
        }
        .disabled(isLoading || isDisabled)
        .buttonStyle(.plain)
    }
}
