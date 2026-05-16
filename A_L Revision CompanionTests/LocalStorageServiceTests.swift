import Foundation
import Testing
@testable import AL_Revision_Companion

struct LocalStorageServiceTests {

    @Test
    func savesAndLoadsUserSettingsAndAudioPlaybackState() {
        let storage = LocalStorageService.shared
        storage.clearAll()
        defer { storage.clearAll() }

        let user = User(
            id: 1,
            fullName: "Test Student",
            email: "student@example.com",
            streamId: 4,
            registrationNumber: "REG-001",
            isActive: true,
            createdAt: nil,
            updatedAt: nil,
            selectedStream: Stream(id: 4, name: "SCIENCE"),
            preference: ProfileSettings(isFaceIDEnabled: true, areNotificationsEnabled: false)
        )
        let settings = ProfileSettings(
            isFaceIDEnabled: true,
            areNotificationsEnabled: false,
            updatedAt: Date(timeIntervalSince1970: 123)
        )
        let playbackState = AudioNotePlaybackState(
            audioNoteId: 55,
            lastPositionSeconds: 87,
            playbackSpeed: 1.5,
            lastPlayedAt: Date(timeIntervalSince1970: 456)
        )

        storage.saveUser(user)
        storage.saveProfileSettings(settings)
        storage.saveAudioNotePlaybackState(playbackState)

        #expect(storage.loadUser() == user)
        #expect(storage.loadProfileSettings() == settings)
        #expect(storage.loadAudioNotePlaybackState(audioNoteID: 55) == playbackState)

        storage.clearAudioNotePlaybackState(audioNoteID: 55)
        #expect(storage.loadAudioNotePlaybackState(audioNoteID: 55) == nil)
    }
}
