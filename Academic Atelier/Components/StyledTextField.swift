import SwiftUI

struct StyledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var isSecureVisible: Binding<Bool>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Color(.systemGray))
                .accessibilityHidden(true)

            HStack {
                Group {
                    if isSecure {
                        if isSecureVisible?.wrappedValue == true {
                            TextField(placeholder, text: $text)
                        } else {
                            SecureField(placeholder, text: $text)
                        }
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .accessibilityLabel(title)
                .accessibilityHint(placeholder)

                if isSecure, let isSecureVisible {
                    Button {
                        isSecureVisible.wrappedValue.toggle()
                    } label: {
                        Image(systemName: isSecureVisible.wrappedValue ? "eye.slash" : "eye")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color(.systemGray3))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSecureVisible.wrappedValue ? "Hide \(title.lowercased())" : "Show \(title.lowercased())")
                    .accessibilityHint("Double tap to toggle secure text visibility.")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(
            color: .black.opacity(AppTheme.cardShadowOpacity),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}
