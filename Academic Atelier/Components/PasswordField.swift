import SwiftUI

struct PasswordField: View {
    private enum Field {
        case secure
        case visible
    }

    let title: String
    let placeholder: String
    @Binding var text: String
    var textContentType: UITextContentType? = nil
    @State private var isSecure: Bool = true
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                ZStack {
                    SecureField(placeholder, text: $text)
                        .opacity(isSecure ? 1 : 0)
                        .focused($focusedField, equals: .secure)
                        .allowsHitTesting(isSecure)

                    TextField(placeholder, text: $text)
                        .opacity(isSecure ? 0 : 1)
                        .focused($focusedField, equals: .visible)
                        .allowsHitTesting(!isSecure)
                }
                .textContentType(textContentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)

                Button {
                    isSecure.toggle()
                    focusedField = isSecure ? .secure : .visible
                } label: {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isSecure ? "Show password" : "Hide password")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
