import SwiftUI

struct StreamSelectionCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 18) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.gray.opacity(0.45))
            }
            .padding(20)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(
                color: .black.opacity(AppTheme.cardShadowOpacity),
                radius: 14,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
}
