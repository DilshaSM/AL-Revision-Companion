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
    @Published private(set) var isAuthenticatingWithBiometrics = false
    @Published private(set) var biometricErrorMessage = ""
    @Published private(set) var biometricType: BiometricType = .none
    @Published var streamErrorMessage: String = ""

    private let storage: LocalStorageService
    private let tokenStore: KeychainService
    private let authService: AuthService
    private let streamService: StreamService
    private let profileService: ProfileService
    private let biometricAuthService: BiometricAuthService

    init(
        storage: LocalStorageService = .shared,
        tokenStore: KeychainService = .shared,
        authService: AuthService = AuthService(),
        streamService: StreamService = StreamService(),
        profileService: ProfileService = ProfileService(),
        biometricAuthService: BiometricAuthService = BiometricAuthService()
    ) {
        self.storage = storage
        self.tokenStore = tokenStore
        self.authService = authService
        self.streamService = streamService
        self.profileService = profileService
        self.biometricAuthService = biometricAuthService
        currentUser = storage.loadUser()
        profileSettings = storage.loadProfileSettings()
        biometricType = biometricAuthService.availableBiometricType()
        updateRoute(for: currentUser)

        Task { [weak self] in
            await self?.restoreSession()
        }
    }

    var canUseBiometricQuickLogin: Bool {
        profileSettings.isFaceIDEnabled && tokenStore.hasBiometricToken() && biometricType != .none
    }

    var biometricButtonTitle: String {
        "\(biometricType.displayName) Login"
    }

    var biometricButtonSubtitle: String {
        "Use \(biometricType.displayName) for faster access"
    }

    func showSignIn() {
        biometricErrorMessage = ""
        authRoute = .signIn
    }

    func showSignUp() {
        biometricErrorMessage = ""
        authRoute = .signUp
    }

    func restoreSession() async {
        defer { isRestoringSession = false }

        guard tokenStore.loadToken() != nil || tokenStore.hasBiometricToken() else {
            clearStoredSession()
            return
        }

        biometricType = biometricAuthService.availableBiometricType()
        biometricErrorMessage = ""

        do {
            try await prepareAuthenticatedTokenForSessionRestore()
        } catch {
            lockSessionForManualSignIn(message: error.localizedDescription)
            return
        }

        do {
            try await resumeAuthenticatedSession()
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

    func signInWithBiometrics() async {
        guard canUseBiometricQuickLogin else {
            biometricErrorMessage = "Enable biometric login in Settings before using quick access."
            return
        }

        isAuthenticatingWithBiometrics = true
        defer { isAuthenticatingWithBiometrics = false }

        do {
            biometricErrorMessage = ""
            let token = try await unlockTokenWithBiometrics()
            try tokenStore.saveToken(token)
            try await resumeAuthenticatedSession()
        } catch let error as APIError {
            if error.requiresSignOut {
                clearStoredSession()
                return
            }

            biometricErrorMessage = error.localizedDescription
        } catch {
            biometricErrorMessage = error.localizedDescription
            authRoute = .signIn
        }
    }

    func signIn(email: String, password: String) async throws {
        biometricErrorMessage = ""
        let payload = try await authService.login(email: email, password: password)
        try await establishAuthenticatedSession(with: payload)
    }

    func signUp(fullName: String, email: String, password: String) async throws {
        biometricErrorMessage = ""
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
        biometricType = biometricAuthService.availableBiometricType()
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
        let hadBiometricToken = tokenStore.hasBiometricToken()

        if biometricEnabled == true {
            try tokenStore.saveBiometricToken(activeTokenForBiometricSetup())
        }

        do {
            let payload = try await profileService.updatePreferences(
                localNotificationsEnabled: localNotificationsEnabled,
                biometricEnabled: biometricEnabled
            )
            applyPreferences(payload.preferences)

            if payload.preferences.isFaceIDEnabled {
                try? tokenStore.saveBiometricToken(activeTokenForBiometricSetup())
            } else {
                tokenStore.removeBiometricToken()
            }

            biometricType = biometricAuthService.availableBiometricType()
            return payload.preferences
        } catch {
            if biometricEnabled == true && !hadBiometricToken {
                tokenStore.removeBiometricToken()
            }

            throw error
        }
    }

    private func establishAuthenticatedSession(with payload: AuthPayload) async throws {
        try tokenStore.saveToken(payload.token)
        applyAuthenticatedUser(payload.user)
        synchronizeBiometricTokenWithCurrentPreferences()

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
            synchronizeBiometricTokenWithCurrentPreferences()
        } catch let error as APIError {
            if error.requiresSignOut {
                clearStoredSession()
                throw error
            }

            let hydratedUser = try? await hydrateSelectedStreamIfNeeded(for: payload.user)
            applyAuthenticatedUser(hydratedUser ?? payload.user)
            synchronizeBiometricTokenWithCurrentPreferences()
        } catch {
            let hydratedUser = try? await hydrateSelectedStreamIfNeeded(for: payload.user)
            applyAuthenticatedUser(hydratedUser ?? payload.user)
            synchronizeBiometricTokenWithCurrentPreferences()
        }
    }

    private func prepareAuthenticatedTokenForSessionRestore() async throws {
        guard profileSettings.isFaceIDEnabled else {
            guard tokenStore.loadToken() != nil else {
                throw DeviceSessionError(message: "Your session expired. Sign in again.")
            }
            return
        }

        guard tokenStore.hasBiometricToken() else {
            throw DeviceSessionError(message: "Biometric login needs to be set up again. Sign in with your password.")
        }

        let token = try await unlockTokenWithBiometrics()
        try tokenStore.saveToken(token)
    }

    private func resumeAuthenticatedSession() async throws {
        let payload = try await authService.currentUser()
        let hydratedUser = try await hydrateSelectedStreamIfNeeded(for: payload.user)
        applyAuthenticatedUser(hydratedUser)
        synchronizeBiometricTokenWithCurrentPreferences()

        if hydratedUser.streamId == nil {
            await loadAvailableStreams()
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
        biometricType = biometricAuthService.availableBiometricType()

        if var user = currentUser {
            user.preference = preferences
            currentUser = user
            storage.saveUser(user)
        }
    }

    private func activeTokenForBiometricSetup() throws -> String {
        guard let token = tokenStore.loadToken(), !token.isEmpty else {
            throw DeviceSessionError(message: "Sign in again before enabling biometric login.")
        }

        return token
    }

    private func unlockTokenWithBiometrics() async throws -> String {
        let reason = "Unlock your account with \(biometricType.displayName)."
        let context = try await biometricAuthService.authenticate(reason: reason)

        guard let token = try tokenStore.loadBiometricToken(using: context), !token.isEmpty else {
            throw DeviceSessionError(message: "Biometric login needs to be set up again. Sign in with your password.")
        }

        return token
    }

    private func synchronizeBiometricTokenWithCurrentPreferences() {
        if profileSettings.isFaceIDEnabled {
            guard let token = tokenStore.loadToken(), !token.isEmpty else { return }
            try? tokenStore.saveBiometricToken(token)
        } else {
            tokenStore.removeBiometricToken()
        }
    }

    private func lockSessionForManualSignIn(message: String) {
        currentUser = nil
        availableStreams = []
        streamErrorMessage = ""
        biometricErrorMessage = message
        authRoute = .signIn
    }

    private func clearStoredSession() {
        currentUser = nil
        availableStreams = []
        profileSettings = .init()
        streamErrorMessage = ""
        biometricErrorMessage = ""
        tokenStore.removeToken()
        tokenStore.removeBiometricToken()
        storage.clearAll()
        NotificationService.shared.cancelRevisionNotifications()
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

private struct DeviceSessionError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}
