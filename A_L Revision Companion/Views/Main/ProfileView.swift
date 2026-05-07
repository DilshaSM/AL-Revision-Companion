import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?
    @State private var path: [ProfileRoute] = []

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    topBar
                    statusSection
                    profileHeader
                    academicIdentitySection
                    signOutButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 128)
            }
            .background(ProfilePalette.canvas.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .settings:
                    ProfileSettingsView()
                }
            }
            .task {
                await refreshProfile(forceRefresh: session.currentUser != nil)
            }
            .refreshable {
                await refreshProfile(forceRefresh: true)
            }
        }
        .onAppear {
            focusedElement = .title
        }
        .onChange(of: viewModel.errorMessage) { _, message in
            guard !message.isEmpty else { return }
            focusedElement = .status
            Task { @MainActor in
                AccessibilitySupport.announce(message)
            }
        }
    }
}

private extension ProfileView {
    var content: ProfileContent {
        .build(user: session.currentUser)
    }

    var topBar: some View {
        HStack(alignment: .center) {
            Text(content.title)
                .font(AppTypography.profileTitle)
                .foregroundStyle(ProfilePalette.textPrimary)
                .accessibilityHeader()
                .accessibilityFocused($focusedElement, equals: .title)

            Spacer(minLength: 12)

            Button {
                path.append(.settings)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(ProfilePalette.buttonChrome)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
            .accessibilityHint("Open profile settings.")
        }
        .frame(height: 40)
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && session.currentUser == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading profile...")
                    .font(.footnote)
                    .foregroundStyle(ProfilePalette.textSecondary)
            }
        } else if !viewModel.errorMessage.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)
                    .accessibilityFocused($focusedElement, equals: .status)

                Button("Retry") {
                    Task {
                        await refreshProfile(forceRefresh: true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ProfilePalette.blueIcon)
            }
        } else if viewModel.isLoading {
            Text("Refreshing profile...")
                .font(.footnote)
                .foregroundStyle(ProfilePalette.textSecondary)
        }
    }

    var profileHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileAvatarView(fullName: content.fullName)
                .padding(.top, 18)

            Text(content.fullName)
                .font(AppTypography.profileName)
                .foregroundStyle(ProfilePalette.textPrimary)
                .padding(.top, 10)

            Text(content.streamTitle)
                .font(AppTypography.profileSubtitle)
                .foregroundStyle(ProfilePalette.textSecondary)
        }
    }

    var academicIdentitySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(content.academicSectionTitle.uppercased())
                .font(AppTypography.profileSectionLabel)
                .tracking(1.8)
                .foregroundStyle(ProfilePalette.sectionLabel)
                .accessibilityHeader()

            VStack(spacing: 30) {
                ForEach(content.identityItems) { item in
                    ProfileIdentityRow(item: item)
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
    }

    var signOutButton: some View {
        Button(role: .destructive) {
            session.signOut()
        } label: {
            Text(content.signOutTitle)
                .font(AppTypography.profileSignOut)
                .foregroundStyle(ProfilePalette.signOut)
                .frame(maxWidth: .infinity, minHeight: 102)
                .background(ProfilePalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ProfilePalette.cardStroke, lineWidth: 1)
                )
                .shadow(color: ProfilePalette.cardShadow, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
        .accessibilityHint("Sign out of your account.")
    }

    func refreshProfile(forceRefresh: Bool) async {
        guard forceRefresh || session.currentUser == nil else { return }

        viewModel.setLoading(true)
        viewModel.setErrorMessage("")
        defer { viewModel.setLoading(false) }

        do {
            _ = try await session.refreshProfile()
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

private enum ProfileRoute: Hashable {
    case settings
}

private struct ProfileAvatarView: View {
    let fullName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(ProfilePalette.avatarOuter)
                .frame(width: 120, height: 120)

            Circle()
                .stroke(ProfilePalette.avatarRing, lineWidth: 10)
                .frame(width: 108, height: 108)

            Circle()
                .fill(ProfilePalette.avatarInner)
                .frame(width: 92, height: 92)

            Text(initials)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(ProfilePalette.avatarText)
        }
        .accessibilityHidden(true)
    }

    private var initials: String {
        let components = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        return components.isEmpty ? "CG" : String(components)
    }
}

private struct ProfileIdentityRow: View {
    let item: ProfileContent.IdentityItem

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                Circle()
                    .fill(ProfilePalette.blueTile)
                    .frame(width: 52, height: 52)

                Image(systemName: iconName)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(ProfilePalette.blueIcon)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(AppTypography.profileIdentityTitle)
                    .foregroundStyle(ProfilePalette.textPrimary)

                Text(item.detail)
                    .font(AppTypography.profileIdentityValue)
                    .foregroundStyle(ProfilePalette.textSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.detail)
    }

    private var iconName: String {
        switch item.id {
        case .emailAddress:
            return "envelope.fill"
        case .subjectStream:
            return "graduationcap.fill"
        case .registrationNumber:
            return "person.text.rectangle.fill"
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
