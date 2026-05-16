import Foundation
import LocalAuthentication
import SwiftData
import Testing
@testable import AL_Revision_Companion

@MainActor
struct SessionViewModelTests {

    @Test
    func signInSuccessWithMissingStreamRoutesToStreamSelectionAndLoadsStreams() async throws {
        let user = makeUser(streamId: nil)
        let auth = MockAuthService(
            loginResult: .success(AuthPayload(user: user, token: "jwt-1", requiresStreamSelection: true)),
            currentUserResult: .success(CurrentUserPayload(user: user))
        )
        let storage = MockLocalStorageService()
        let keychain = MockKeychainService()
        let streams = [
            AL_Revision_Companion.Stream(id: 1, name: "SCIENCE"),
            AL_Revision_Companion.Stream(id: 2, name: "COMMERCE")
        ]
        let streamService = MockStreamService(getStreamsResult: .success(streams))
        let session = SessionViewModel(
            storage: storage,
            tokenStore: keychain,
            authService: auth,
            streamService: streamService,
            profileService: MockProfileService(),
            biometricAuthService: MockBiometricAuthService(),
            widgetSummarySyncService: MockWidgetSummarySyncService()
        )

        try await session.signIn(email: "test@example.com", password: "secret")

        #expect(session.authRoute == .streamSelection)
        #expect(session.currentUser?.email == "student@example.com")
        #expect(session.availableStreams == streams)
        #expect(keychain.savedToken == "jwt-1")
    }

    @Test
    func signInFailureDoesNotPersistUser() async {
        let storage = MockLocalStorageService()
        let session = SessionViewModel(
            storage: storage,
            tokenStore: MockKeychainService(),
            authService: MockAuthService(
                loginResult: .failure(APIError.server(message: "Invalid credentials", statusCode: 401))
            ),
            streamService: MockStreamService(),
            profileService: MockProfileService(),
            biometricAuthService: MockBiometricAuthService(),
            widgetSummarySyncService: MockWidgetSummarySyncService()
        )

        do {
            try await session.signIn(email: "wrong@example.com", password: "bad")
            Issue.record("Expected sign-in to fail")
        } catch {
            #expect(error.localizedDescription == "Invalid credentials")
        }

        #expect(session.currentUser == nil)
        #expect(storage.savedUser == nil)
    }

    @Test
    func signUpSuccessWithStreamRoutesToMain() async throws {
        let stream = AL_Revision_Companion.Stream(id: 4, name: "SCIENCE")
        var user = makeUser(streamId: 4)
        user.selectedStream = stream
        let session = SessionViewModel(
            storage: MockLocalStorageService(),
            tokenStore: MockKeychainService(),
            authService: MockAuthService(
                registerResult: .success(AuthPayload(user: user, token: "jwt-2", requiresStreamSelection: false)),
                currentUserResult: .success(CurrentUserPayload(user: user))
            ),
            streamService: MockStreamService(getStreamsResult: .success([stream])),
            profileService: MockProfileService(),
            biometricAuthService: MockBiometricAuthService(),
            widgetSummarySyncService: MockWidgetSummarySyncService()
        )

        try await session.signUp(fullName: "Student", email: "student@example.com", password: "secret")

        #expect(session.authRoute == .main)
        #expect(session.currentUser?.streamId == 4)
    }

    @Test
    func restoreSessionWithoutStreamLoadsStreamsAndRoutesToStreamSelection() async {
        let user = makeUser(streamId: nil)
        let session = SessionViewModel(
            storage: MockLocalStorageService(user: user),
            tokenStore: MockKeychainService(token: "jwt-restore"),
            authService: MockAuthService(currentUserResult: .success(CurrentUserPayload(user: user))),
            streamService: MockStreamService(getStreamsResult: .success([AL_Revision_Companion.Stream(id: 1, name: "SCIENCE")])),
            profileService: MockProfileService(),
            biometricAuthService: MockBiometricAuthService(),
            widgetSummarySyncService: MockWidgetSummarySyncService()
        )

        await session.restoreSession()

        #expect(session.authRoute == .streamSelection)
        #expect(session.currentUser?.id == user.id)
        #expect(session.availableStreams.count == 1)
        #expect(session.isRestoringSession == false)
    }

    @Test
    func restoreSessionWithStreamRoutesToMain() async {
        let stream = AL_Revision_Companion.Stream(id: 1, name: "SCIENCE")
        var user = makeUser(streamId: 1)
        user.selectedStream = stream
        let session = SessionViewModel(
            storage: MockLocalStorageService(user: user),
            tokenStore: MockKeychainService(token: "jwt-restore"),
            authService: MockAuthService(currentUserResult: .success(CurrentUserPayload(user: user))),
            streamService: MockStreamService(getStreamsResult: .success([stream])),
            profileService: MockProfileService(),
            biometricAuthService: MockBiometricAuthService(),
            widgetSummarySyncService: MockWidgetSummarySyncService()
        )

        await session.restoreSession()

        #expect(session.authRoute == .main)
        #expect(session.currentUser?.streamId == 1)
        #expect(session.availableStreams.map(\.id) == [1])
    }

    @Test
    func signOutClearsUserTokensPreferencesAndWidgetCache() async {
        let storage = MockLocalStorageService(
            user: makeUser(streamId: 1),
            settings: ProfileSettings(isFaceIDEnabled: true, areNotificationsEnabled: true)
        )
        let keychain = MockKeychainService(token: "jwt", biometricTokenPresent: true)
        let widgetSync = MockWidgetSummarySyncService()
        let session = SessionViewModel(
            storage: storage,
            tokenStore: keychain,
            authService: MockAuthService(logoutResult: .success(LogoutPayload(loggedOut: true))),
            streamService: MockStreamService(),
            profileService: MockProfileService(),
            biometricAuthService: MockBiometricAuthService(),
            widgetSummarySyncService: widgetSync
        )

        session.signOut()
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(session.currentUser == nil)
        #expect(session.authRoute == .signIn)
        #expect(storage.didClearAll == true)
        #expect(keychain.didRemoveToken == true)
        #expect(keychain.didRemoveBiometricToken == true)
        #expect(widgetSync.didClear == true)
    }

    private func makeUser(streamId: Int?) -> User {
        User(
            id: 1,
            fullName: "Student Example",
            email: "student@example.com",
            streamId: streamId,
            registrationNumber: "REG-001",
            isActive: true,
            createdAt: nil,
            updatedAt: nil,
            selectedStream: nil,
            preference: ProfileSettings(isFaceIDEnabled: false, areNotificationsEnabled: true)
        )
    }
}

private final class MockAuthService: AuthServiceProtocol {
    var loginResult: Result<AuthPayload, Error>
    var registerResult: Result<AuthPayload, Error>
    var forgotPasswordResult: Result<ForgotPasswordPayload, Error>
    var verifyResetCodeResult: Result<VerifyResetCodePayload, Error>
    var resetPasswordResult: Result<ResetPasswordPayload, Error>
    var currentUserResult: Result<CurrentUserPayload, Error>
    var logoutResult: Result<LogoutPayload, Error>

    init(
        loginResult: Result<AuthPayload, Error> = .failure(APIError.server(message: "Unconfigured login", statusCode: 500)),
        registerResult: Result<AuthPayload, Error> = .failure(APIError.server(message: "Unconfigured register", statusCode: 500)),
        forgotPasswordResult: Result<ForgotPasswordPayload, Error> = .failure(APIError.server(message: "Unconfigured forgot", statusCode: 500)),
        verifyResetCodeResult: Result<VerifyResetCodePayload, Error> = .failure(APIError.server(message: "Unconfigured verify", statusCode: 500)),
        resetPasswordResult: Result<ResetPasswordPayload, Error> = .failure(APIError.server(message: "Unconfigured reset", statusCode: 500)),
        currentUserResult: Result<CurrentUserPayload, Error> = .failure(APIError.server(message: "Unconfigured current user", statusCode: 500)),
        logoutResult: Result<LogoutPayload, Error> = .success(LogoutPayload(loggedOut: true))
    ) {
        self.loginResult = loginResult
        self.registerResult = registerResult
        self.forgotPasswordResult = forgotPasswordResult
        self.verifyResetCodeResult = verifyResetCodeResult
        self.resetPasswordResult = resetPasswordResult
        self.currentUserResult = currentUserResult
        self.logoutResult = logoutResult
    }

    func login(email: String, password: String) async throws -> AuthPayload { try loginResult.get() }
    func register(fullName: String, email: String, password: String) async throws -> AuthPayload { try registerResult.get() }
    func forgotPassword(email: String) async throws -> ForgotPasswordPayload { try forgotPasswordResult.get() }
    func verifyResetCode(email: String, code: String) async throws -> VerifyResetCodePayload { try verifyResetCodeResult.get() }
    func resetPassword(email: String, code: String, newPassword: String) async throws -> ResetPasswordPayload { try resetPasswordResult.get() }
    func currentUser() async throws -> CurrentUserPayload { try currentUserResult.get() }
    func logout() async throws -> LogoutPayload { try logoutResult.get() }
}

private final class MockStreamService: StreamServiceProtocol {
    var getStreamsResult: Result<[AL_Revision_Companion.Stream], Error>
    var selectStreamResult: Result<StreamSelectionPayload, Error>

    init(
        getStreamsResult: Result<[AL_Revision_Companion.Stream], Error> = .success([]),
        selectStreamResult: Result<StreamSelectionPayload, Error> = .failure(APIError.server(message: "Unconfigured stream selection", statusCode: 500))
    ) {
        self.getStreamsResult = getStreamsResult
        self.selectStreamResult = selectStreamResult
    }

    func getStreams() async throws -> [AL_Revision_Companion.Stream] { try getStreamsResult.get() }
    func selectStream(streamID: Int) async throws -> StreamSelectionPayload { try selectStreamResult.get() }
}

private final class MockProfileService: ProfileServiceProtocol {
    var profileResult: Result<CurrentUserPayload, Error>
    var preferencesResult: Result<PreferencesPayload, Error>
    var updatePreferencesResult: Result<PreferencesPayload, Error>

    init(
        profileResult: Result<CurrentUserPayload, Error> = .failure(APIError.server(message: "Unconfigured profile", statusCode: 500)),
        preferencesResult: Result<PreferencesPayload, Error> = .success(PreferencesPayload(preferences: .init())),
        updatePreferencesResult: Result<PreferencesPayload, Error> = .success(PreferencesPayload(preferences: .init()))
    ) {
        self.profileResult = profileResult
        self.preferencesResult = preferencesResult
        self.updatePreferencesResult = updatePreferencesResult
    }

    func getProfile() async throws -> CurrentUserPayload { try profileResult.get() }
    func getPreferences() async throws -> PreferencesPayload { try preferencesResult.get() }
    func updatePreferences(localNotificationsEnabled: Bool?, biometricEnabled: Bool?) async throws -> PreferencesPayload {
        try updatePreferencesResult.get()
    }
}

private final class MockLocalStorageService: LocalStorageServiceProtocol {
    var savedUser: User?
    var savedSettings: ProfileSettings
    var audioStates: [Int: AudioNotePlaybackState] = [:]
    var didClearAll = false

    init(user: User? = nil, settings: ProfileSettings = .init()) {
        savedUser = user
        savedSettings = settings
    }

    func saveUser(_ user: User) { savedUser = user }
    func loadUser() -> User? { savedUser }
    func saveProfileSettings(_ settings: ProfileSettings) { savedSettings = settings }
    func loadProfileSettings() -> ProfileSettings { savedSettings }
    func saveAudioNotePlaybackState(_ state: AudioNotePlaybackState) { audioStates[state.audioNoteId] = state }
    func loadAudioNotePlaybackState(audioNoteID: Int) -> AudioNotePlaybackState? { audioStates[audioNoteID] }
    func clearAudioNotePlaybackState(audioNoteID: Int) { audioStates.removeValue(forKey: audioNoteID) }
    func clearAll() {
        savedUser = nil
        savedSettings = .init()
        audioStates = [:]
        didClearAll = true
    }
}

private final class MockKeychainService: KeychainServiceProtocol {
    var savedToken: String?
    var biometricToken: String?
    var didRemoveToken = false
    var didRemoveBiometricToken = false

    init(token: String? = nil, biometricTokenPresent: Bool = false) {
        savedToken = token
        biometricToken = biometricTokenPresent ? token : nil
    }

    func saveToken(_ token: String) throws { savedToken = token }
    func loadToken() -> String? { savedToken }
    func removeToken() {
        savedToken = nil
        didRemoveToken = true
    }
    func saveBiometricToken(_ token: String) throws { biometricToken = token }
    func loadBiometricToken(using context: LAContext) throws -> String? { biometricToken }
    func hasBiometricToken() -> Bool { biometricToken != nil }
    func removeBiometricToken() {
        biometricToken = nil
        didRemoveBiometricToken = true
    }
}

private struct MockBiometricAuthService: BiometricAuthServiceProtocol {
    var type: BiometricType = .faceID

    func availableBiometricType() -> BiometricType { type }
    func authenticate(reason: String) async throws -> LAContext { LAContext() }
}

private final class MockWidgetSummarySyncService: WidgetSummarySyncServiceProtocol {
    private(set) var didClear = false
    private(set) var refreshCallCount = 0

    @MainActor
    func refresh(context: ModelContext?) async throws {
        refreshCallCount += 1
    }

    func clear() {
        didClear = true
    }
}
