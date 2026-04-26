import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject private var session: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = ProfileSettingsViewModel()

    private let content = ProfileSettingsContent.placeholder

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    statusSection

                    Text(content.sectionTitle.uppercased())
                        .font(AppTypography.profileSettingsSectionLabel)
                        .tracking(1.8)
                        .foregroundStyle(ProfilePalette.sectionLabel)

                    VStack(spacing: 28) {
                        ForEach(content.preferences) { preference in
                            PreferenceRow(
                                preference: preference,
                                isOn: binding(for: preference),
                                isDisabled: isDisabled(preference)
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
        .task {
            await loadPreferences()
        }
        .onChange(of: session.profileSettings) { _, newSettings in
            guard newSettings != viewModel.settings else { return }
            viewModel.applyExternalSettings(newSettings)
        }
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

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading preferences...")
                    .font(.footnote)
                    .foregroundStyle(ProfilePalette.textSecondary)
            }
        } else if !viewModel.errorMessage.isEmpty {
            Text(viewModel.errorMessage)
                .font(.footnote)
                .foregroundStyle(SubjectsPalette.resultIncorrect)
        }
    }

    func binding(for preference: ProfileSettingsContent.PreferenceItem) -> Binding<Bool> {
        Binding(
            get: {
                switch preference.id {
                case .notifications:
                    return viewModel.settings.areNotificationsEnabled
                case .biometricAuthentication:
                    return viewModel.settings.isFaceIDEnabled
                }
            },
            set: { isEnabled in
                Task {
                    await update(preference: preference, isEnabled: isEnabled)
                }
            }
        )
    }

    func isDisabled(_ preference: ProfileSettingsContent.PreferenceItem) -> Bool {
        switch preference.id {
        case .notifications:
            return viewModel.isLoading || viewModel.isSavingNotifications
        case .biometricAuthentication:
            return viewModel.isLoading || viewModel.isSavingBiometric
        }
    }

    func loadPreferences() async {
        do {
            try await viewModel.load(from: session)
        } catch let error as APIError {
            if error.requiresSignOut {
                session.signOut()
            } else {
                viewModel.setErrorMessage(error.localizedDescription)
            }
        } catch {
            viewModel.setErrorMessage(error.localizedDescription)
        }
    }

    func update(preference: ProfileSettingsContent.PreferenceItem, isEnabled: Bool) async {
        do {
            switch preference.id {
            case .notifications:
                try await viewModel.setNotificationsEnabled(isEnabled, session: session)
            case .biometricAuthentication:
                try await viewModel.setBiometricEnabled(isEnabled, session: session)
            }
        } catch let error as APIError {
            if error.requiresSignOut {
                session.signOut()
            } else {
                viewModel.setErrorMessage(error.localizedDescription)
            }
        } catch {
            viewModel.setErrorMessage(error.localizedDescription)
        }
    }
}

private struct PreferenceRow: View {
    let preference: ProfileSettingsContent.PreferenceItem
    @Binding var isOn: Bool
    let isDisabled: Bool

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
                .disabled(isDisabled)
        }
        .opacity(isDisabled ? 0.7 : 1)
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

private extension APIError {
    var requiresSignOut: Bool {
        switch self {
        case .missingToken, .unauthorized:
            return true
        default:
            return false
        }
    }
}
