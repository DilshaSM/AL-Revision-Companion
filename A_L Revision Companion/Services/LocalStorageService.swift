import Foundation

protocol LocalStorageServiceProtocol: AnyObject {
    func saveUser(_ user: User)
    func loadUser() -> User?
    func saveProfileSettings(_ settings: ProfileSettings)
    func loadProfileSettings() -> ProfileSettings
    func saveAudioNotePlaybackState(_ state: AudioNotePlaybackState)
    func loadAudioNotePlaybackState(audioNoteID: Int) -> AudioNotePlaybackState?
    func clearAudioNotePlaybackState(audioNoteID: Int)
    func clearAll()
}

final class LocalStorageService {
    static let shared = LocalStorageService()

    private let userKey = "saved_user"
    private let settingsKey = "profile_settings"
    private let audioNotePlaybackStateKey = "audio_note_playback_state"

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

    func saveAudioNotePlaybackState(_ state: AudioNotePlaybackState) {
        var states = loadAudioNotePlaybackStates()
        states["\(state.audioNoteId)"] = state

        if let data = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(data, forKey: audioNotePlaybackStateKey)
        }
    }

    func loadAudioNotePlaybackState(audioNoteID: Int) -> AudioNotePlaybackState? {
        loadAudioNotePlaybackStates()["\(audioNoteID)"]
    }

    func clearAudioNotePlaybackState(audioNoteID: Int) {
        var states = loadAudioNotePlaybackStates()
        states.removeValue(forKey: "\(audioNoteID)")

        if let data = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(data, forKey: audioNotePlaybackStateKey)
        }
    }

    private func loadAudioNotePlaybackStates() -> [String: AudioNotePlaybackState] {
        guard let data = UserDefaults.standard.data(forKey: audioNotePlaybackStateKey),
              let states = try? JSONDecoder().decode([String: AudioNotePlaybackState].self, from: data) else {
            return [:]
        }

        return states
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: settingsKey)
        UserDefaults.standard.removeObject(forKey: audioNotePlaybackStateKey)
    }
}

extension LocalStorageService: LocalStorageServiceProtocol {}
