import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var availableStreams: [Stream] = []
    @Published private(set) var profileSettings: ProfileSettings = .init()
    @Published private(set) var authRoute: AppRoute = .signIn
    @Published private(set) var isRestoringSession = true
    @Published private(set) var isLoadingStreams = false
    @Published private(set) var activeStreamSelectionID: Int?
    @Published var streamErrorMessage: String = ""

    private let storage: LocalStorageService
    private let tokenStore: KeychainService
    private let authService: AuthService
    private let streamService: StreamService
    private let profileService: ProfileService

    init(
        storage: LocalStorageService = .shared,
        tokenStore: KeychainService = .shared,
        authService: AuthService = AuthService(),
        streamService: StreamService = StreamService(),
        profileService: ProfileService = ProfileService()
    ) {
        self.storage = storage
        self.tokenStore = tokenStore
        self.authService = authService
        self.streamService = streamService
        self.profileService = profileService
        currentUser = storage.loadUser()
        profileSettings = storage.loadProfileSettings()
        updateRoute(for: currentUser)

        Task { [weak self] in
            await self?.restoreSession()
        }
    }

    func showSignIn() {
        authRoute = .signIn
    }

    func showSignUp() {
        authRoute = .signUp
    }

    func restoreSession() async {
        defer { isRestoringSession = false }

        guard tokenStore.loadToken() != nil else {
            clearStoredSession()
            return
        }

        do {
            let payload = try await authService.currentUser()
            let hydratedUser = try await hydrateSelectedStreamIfNeeded(for: payload.user)
            applyAuthenticatedUser(hydratedUser)

            if hydratedUser.streamId == nil {
                await loadAvailableStreams()
            }
        } catch let error as APIError {
            if error.requiresSignOut {
                clearStoredSession()
                return
            }

            if currentUser?.streamId == nil {
                await loadAvailableStreams()
            }

            updateRoute(for: currentUser)
        } catch {
            if currentUser?.streamId == nil {
                await loadAvailableStreams()
            }

            updateRoute(for: currentUser)
        }
    }

    func signIn(email: String, password: String) async throws {
        let payload = try await authService.login(email: email, password: password)
        try await establishAuthenticatedSession(with: payload)
    }

    func signUp(fullName: String, email: String, password: String) async throws {
        let payload = try await authService.register(fullName: fullName, email: email, password: password)
        try await establishAuthenticatedSession(with: payload)
    }

    func ensureAvailableStreams() async {
        guard tokenStore.loadToken() != nil else { return }
        guard availableStreams.isEmpty else { return }
        await loadAvailableStreams()
    }

    func selectStream(_ stream: Stream) async {
        activeStreamSelectionID = stream.id
        streamErrorMessage = ""

        defer { activeStreamSelectionID = nil }

        do {
            let payload = try await streamService.selectStream(streamID: stream.id)
            var user = payload.user

            if user.selectedStream == nil {
                user.selectedStream = stream
            }

            applyAuthenticatedUser(user)
            availableStreams = []
            authRoute = .main
        } catch let error as APIError {
            if error.requiresSignOut {
                clearStoredSession()
            } else {
                streamErrorMessage = error.localizedDescription
            }
        } catch {
            streamErrorMessage = error.localizedDescription
        }
    }

    func signOut() {
        Task {
            try? await authService.logout()
        }

        clearStoredSession()
    }

    func updateProfileSettings(_ settings: ProfileSettings) {
        profileSettings = settings
        storage.saveProfileSettings(settings)
    }

    func refreshProfile() async throws -> User {
        let payload = try await profileService.getProfile()
        let hydratedUser = try await hydrateSelectedStreamIfNeeded(for: payload.user)
        applyAuthenticatedUser(hydratedUser)
        return hydratedUser
    }

    func refreshPreferences() async throws -> ProfileSettings {
        let payload = try await profileService.getPreferences()
        applyPreferences(payload.preferences)
        return payload.preferences
    }

    func savePreferences(
        localNotificationsEnabled: Bool? = nil,
        biometricEnabled: Bool? = nil
    ) async throws -> ProfileSettings {
        let payload = try await profileService.updatePreferences(
            localNotificationsEnabled: localNotificationsEnabled,
            biometricEnabled: biometricEnabled
        )
        applyPreferences(payload.preferences)
        return payload.preferences
    }

    private func establishAuthenticatedSession(with payload: AuthPayload) async throws {
        try tokenStore.saveToken(payload.token)
        applyAuthenticatedUser(payload.user)

        if payload.requiresStreamSelection || payload.user.streamId == nil {
            authRoute = .streamSelection
            await loadAvailableStreams()
            return
        }

        authRoute = .main

        do {
            let refreshedPayload = try await authService.currentUser()
            let hydratedUser = try await hydrateSelectedStreamIfNeeded(for: refreshedPayload.user)
            applyAuthenticatedUser(hydratedUser)
        } catch let error as APIError {
            if error.requiresSignOut {
                clearStoredSession()
                throw error
            }

            let hydratedUser = try? await hydrateSelectedStreamIfNeeded(for: payload.user)
            applyAuthenticatedUser(hydratedUser ?? payload.user)
        } catch {
            let hydratedUser = try? await hydrateSelectedStreamIfNeeded(for: payload.user)
            applyAuthenticatedUser(hydratedUser ?? payload.user)
        }
    }

    private func loadAvailableStreams() async {
        isLoadingStreams = true
        streamErrorMessage = ""

        defer { isLoadingStreams = false }

        do {
            availableStreams = try await streamService.getStreams()
                .sorted { ($0.orderIndex ?? .max) < ($1.orderIndex ?? .max) }

            if let user = currentUser, let streamID = user.streamId,
               let selectedStream = availableStreams.first(where: { $0.id == streamID }) {
                var hydratedUser = user
                hydratedUser.selectedStream = selectedStream
                applyAuthenticatedUser(hydratedUser)
            }
        } catch let error as APIError {
            if error.requiresSignOut {
                clearStoredSession()
            } else {
                streamErrorMessage = error.localizedDescription
            }
        } catch {
            streamErrorMessage = error.localizedDescription
        }
    }

    private func hydrateSelectedStreamIfNeeded(for user: User) async throws -> User {
        guard let streamID = user.streamId else { return user }

        if availableStreams.isEmpty {
            availableStreams = try await streamService.getStreams()
                .sorted { ($0.orderIndex ?? .max) < ($1.orderIndex ?? .max) }
        }

        guard let selectedStream = availableStreams.first(where: { $0.id == streamID }) else {
            return user
        }

        var hydratedUser = user
        hydratedUser.selectedStream = selectedStream
        return hydratedUser
    }

    private func applyAuthenticatedUser(_ user: User) {
        currentUser = user
        storage.saveUser(user)

        if let preference = user.preference {
            updateProfileSettings(preference)
        }

        updateRoute(for: user)
    }

    private func applyPreferences(_ preferences: ProfileSettings) {
        profileSettings = preferences
        storage.saveProfileSettings(preferences)

        if var user = currentUser {
            user.preference = preferences
            currentUser = user
            storage.saveUser(user)
        }
    }

    private func clearStoredSession() {
        currentUser = nil
        availableStreams = []
        profileSettings = .init()
        streamErrorMessage = ""
        tokenStore.removeToken()
        storage.clearAll()
        authRoute = .signIn
    }

    private func updateRoute(for user: User?) {
        guard let user else {
            authRoute = .signIn
            return
        }

        authRoute = user.streamId == nil ? .streamSelection : .main
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
