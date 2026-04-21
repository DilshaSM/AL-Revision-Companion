import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(
                    color: AppColors.primary.opacity(0.20),
                    radius: 10,
                    x: 0,
                    y: 8
                )
        }
        .buttonStyle(.plain)
    }
}
