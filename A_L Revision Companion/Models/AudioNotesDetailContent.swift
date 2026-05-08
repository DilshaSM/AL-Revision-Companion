import Foundation

struct AudioNotesDetailContent: Hashable {
    let id: Int
    let subjectID: Int
    let topicID: Int
    let topBarLabel: String
    let topBarTitle: String
    let lessonTitle: String
    let summary: String
    let audioURLString: String?
    let elapsedSeconds: Int
    let totalSeconds: Int
    let playbackSpeed: Double
    let waveformBars: [WaveformBar]
    let audioUnavailableMessage: String

    var audioURL: URL? {
        guard let audioURLString,
              !audioURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return URL(string: audioURLString.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var playbackSpeedLabel: String {
        String(format: "%.2fx", playbackSpeed)
            .replacingOccurrences(of: ".00", with: "")
            .replacingOccurrences(of: ".50", with: ".5")
    }

    static func build(
        detail: APIAudioNoteDetail,
        localState: AudioNotePlaybackState?
    ) -> AudioNotesDetailContent {
        AudioNotesDetailContent(
            id: detail.id,
            subjectID: detail.subjectId,
            topicID: detail.playbackTopicId,
            topBarLabel: "AUDIO NOTES · \(detail.subjectName.uppercased())",
            topBarTitle: "Audio Recall",
            lessonTitle: detail.title,
            summary: detail.description ?? "Listen to a concise revision summary for this topic.",
            audioURLString: detail.audioUrl,
            elapsedSeconds: localState?.lastPositionSeconds ?? 0,
            totalSeconds: detail.durationSeconds,
            playbackSpeed: localState?.playbackSpeed ?? 1,
            waveformBars: waveformTemplate,
            audioUnavailableMessage: "Audio is currently unavailable. Please try again later."
        )
    }

    private static let waveformTemplate: [WaveformBar] = [
        .init(id: "bar-1", height: 32, tone: .soft),
        .init(id: "bar-2", height: 48, tone: .soft),
        .init(id: "bar-3", height: 64, tone: .medium),
        .init(id: "bar-4", height: 40, tone: .accentSoft),
        .init(id: "bar-5", height: 80, tone: .accent),
        .init(id: "bar-6", height: 56, tone: .accent),
        .init(id: "bar-7", height: 96, tone: .accentDark),
        .init(id: "bar-8", height: 48, tone: .accent),
        .init(id: "bar-9", height: 32, tone: .accentSoft),
        .init(id: "bar-10", height: 56, tone: .medium),
        .init(id: "bar-11", height: 40, tone: .muted),
        .init(id: "bar-12", height: 64, tone: .pale),
        .init(id: "bar-13", height: 48, tone: .pale),
        .init(id: "bar-14", height: 32, tone: .faint)
    ]
}

struct AudioNotePlaybackState: Codable, Hashable {
    let audioNoteId: Int
    let lastPositionSeconds: Int
    let playbackSpeed: Double
    let lastPlayedAt: Date?
}

extension AudioNotesDetailContent {
    struct WaveformBar: Identifiable, Hashable {
        enum Tone: Hashable {
            case faint
            case pale
            case soft
            case medium
            case muted
            case accentSoft
            case accent
            case accentDark
        }

        let id: String
        let height: Double
        let tone: Tone
    }
}
