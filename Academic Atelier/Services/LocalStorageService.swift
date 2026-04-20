import Foundation

final class LocalStorageService {
    static let shared = LocalStorageService()

    private let userKey = "saved_user"
    private let settingsKey = "profile_settings"

    private init() {}

    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }

    func saveProfileSettings(_ settings: ProfileSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    func loadProfileSettings() -> ProfileSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(ProfileSettings.self, from: data) else {
            return .init()
        }
        return settings
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: settingsKey)
    }
}
