import Foundation
import SwiftData

@Model
final class AudioProgressEntity {
    @Attribute(.unique) var audioNoteId: Int

    var title: String
    var lastPositionSeconds: Int
    var durationSeconds: Int
    var playbackSpeed: Double
    var lastPlayedAt: Date
    var isCompleted: Bool
    var needsSync: Bool

    init(
        audioNoteId: Int,
        title: String,
        lastPositionSeconds: Int = 0,
        durationSeconds: Int = 0,
        playbackSpeed: Double = 1.0,
        lastPlayedAt: Date = .now,
        isCompleted: Bool = false,
        needsSync: Bool = false
    ) {
        self.audioNoteId = audioNoteId
        self.title = title
        self.lastPositionSeconds = lastPositionSeconds
        self.durationSeconds = durationSeconds
        self.playbackSpeed = playbackSpeed
        self.lastPlayedAt = lastPlayedAt
        self.isCompleted = isCompleted
        self.needsSync = needsSync
    }
}
