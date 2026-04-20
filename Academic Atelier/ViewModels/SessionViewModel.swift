import Foundation

final class SessionViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var profileSettings: ProfileSettings = .init()
    @Published var authRoute: AppRoute = .signIn

    private let storage = LocalStorageService.shared

    init() {
        loadSession()
    }

    func loadSession() {
        if let savedUser = storage.loadUser() {
            currentUser = savedUser
            profileSettings = storage.loadProfileSettings()

            if savedUser.selectedStream == nil {
                authRoute = .streamSelection
            } else {
                authRoute = .main
            }
        } else {
            authRoute = .signIn
        }
    }

    func signIn(user: User) {
        currentUser = user
        storage.saveUser(user)

        if user.selectedStream == nil {
            authRoute = .streamSelection
        } else {
            authRoute = .main
        }
    }

    func signOut() {
        currentUser = nil
        profileSettings = .init()
        storage.clearAll()
        authRoute = .signIn
    }

    func updateSelectedStream(_ stream: Stream) {
        guard var user = currentUser else { return }
        user.selectedStream = stream
        currentUser = user
        storage.saveUser(user)
        authRoute = .main
    }

    func updateProfileSettings(_ settings: ProfileSettings) {
        profileSettings = settings
        storage.saveProfileSettings(settings)
    }
}
