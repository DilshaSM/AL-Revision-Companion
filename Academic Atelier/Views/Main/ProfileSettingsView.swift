import SwiftUI

struct ProfileSettingsView: View {
    @Binding var settings: ProfileSettings
    @Environment(\.dismiss) private var dismiss

    private let content = ProfileSettingsContent.placeholder

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Text(content.sectionTitle.uppercased())
                        .font(AppTypography.profileSettingsSectionLabel)
                        .tracking(1.8)
                        .foregroundStyle(ProfilePalette.sectionLabel)

                    VStack(spacing: 28) {
                        ForEach(content.preferences) { preference in
                            PreferenceRow(
                                preference: preference,
                                isOn: binding(for: preference)
                            )
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ProfilePalette.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(ProfilePalette.cardStroke, lineWidth: 1)
                    )
                    .shadow(color: ProfilePalette.cardShadow, radius: 12, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 128)
            }
        }
        .background(ProfilePalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension ProfileSettingsView {
    var topBar: some View {
        HStack(alignment: .center) {
            Text(content.title)
                .font(AppTypography.profileSettingsTitle)
                .foregroundStyle(ProfilePalette.textPrimary)

            Spacer(minLength: 12)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ProfilePalette.buttonChrome)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 16)
        .background(ProfilePalette.canvas.opacity(0.92))
    }

    func binding(for preference: ProfileSettingsContent.PreferenceItem) -> Binding<Bool> {
        switch preference.id {
        case .notifications:
            return $settings.areNotificationsEnabled
        case .biometricAuthentication:
            return $settings.isFaceIDEnabled
        }
    }
}

private struct PreferenceRow: View {
    let preference: ProfileSettingsContent.PreferenceItem
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            iconTile

            VStack(alignment: .leading, spacing: 6) {
                Text(preference.title)
                    .font(AppTypography.profileSettingsRowTitle)
                    .foregroundStyle(ProfilePalette.textPrimary)

                Text(preference.subtitle)
                    .font(AppTypography.profileSettingsRowSubtitle)
                    .foregroundStyle(ProfilePalette.textSecondary)
            }

            Spacer(minLength: 12)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ProfilePalette.toggleTint)
        }
    }

    @ViewBuilder
    private var iconTile: some View {
        let palette = iconPalette

        ZStack {
            Circle()
                .fill(palette.background)
                .frame(width: 52, height: 52)

            Image(systemName: palette.symbolName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(palette.foreground)
        }
    }

    private var iconPalette: (background: Color, foreground: Color, symbolName: String) {
        switch preference.id {
        case .notifications:
            return (ProfilePalette.orangeTile, ProfilePalette.orangeIcon, "bell.fill")
        case .biometricAuthentication:
            return (ProfilePalette.greenTile, ProfilePalette.greenIcon, "faceid")
        }
    }
}
