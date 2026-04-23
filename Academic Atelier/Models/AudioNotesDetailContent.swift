import Foundation

struct AudioNotesDetailContent: Hashable {
    var id: String
    var topBarLabel: String
    var topBarTitle: String
    var lessonTitle: String
    var summary: String
    var audioURLString: String?
    var elapsedSeconds: Int
    var totalSeconds: Int
    var playbackSpeedLabel: String
    var waveformBars: [WaveformBar]

    var audioURL: URL? {
        guard let audioURLString else { return nil }
        return URL(string: audioURLString)
    }

    var playbackRate: Float {
        let normalized = playbackSpeedLabel
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "x", with: "", options: .caseInsensitive)
        return Float(normalized) ?? 1
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(max(Double(elapsedSeconds) / Double(totalSeconds), 0), 1)
    }

    var elapsedTimeText: String {
        Self.formatTime(elapsedSeconds)
    }

    var totalTimeText: String {
        Self.formatTime(totalSeconds)
    }

    static func placeholder(forTopicID topicID: String) -> AudioNotesDetailContent? {
        placeholderByTopicID[topicID]
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

    private static let placeholderByTopicID: [String: AudioNotesDetailContent] = [
        "genetics-inheritance": .init(
            id: "genetics-inheritance",
            topBarLabel: "AUDIO NOTES · GENETICS",
            topBarTitle: "Biology Quick Recall",
            lessonTitle: "Genetics & Inheritance",
            summary: "Key concepts, gene expression, and inheritance patterns.",
            audioURLString: nil,
            elapsedSeconds: 105,
            totalSeconds: 200,
            playbackSpeedLabel: "1.25x",
            waveformBars: waveformTemplate
        ),
        "entropy-explained": .init(
            id: "entropy-explained",
            topBarLabel: "AUDIO NOTES · CHEMISTRY",
            topBarTitle: "Chemistry Quick Recall",
            lessonTitle: "Entropy Explained",
            summary: "Energy dispersal, spontaneity, and second-law intuition in one short lesson.",
            audioURLString: nil,
            elapsedSeconds: 78,
            totalSeconds: 180,
            playbackSpeedLabel: "1.0x",
            waveformBars: waveformTemplate
        ),
        "integration-techniques": .init(
            id: "integration-techniques",
            topBarLabel: "AUDIO NOTES · MATHEMATICS",
            topBarTitle: "Maths Quick Recall",
            lessonTitle: "Integration Techniques",
            summary: "Substitution, parts, and partial fractions with fast cues for exam recall.",
            audioURLString: nil,
            elapsedSeconds: 132,
            totalSeconds: 240,
            playbackSpeedLabel: "1.25x",
            waveformBars: waveformTemplate
        ),
        "newtons-laws": .init(
            id: "newtons-laws",
            topBarLabel: "AUDIO NOTES · PHYSICS",
            topBarTitle: "Physics Quick Recall",
            lessonTitle: "Newton's Laws",
            summary: "Forces, inertia, and action-reaction explained as an exam-speed recap.",
            audioURLString: nil,
            elapsedSeconds: 94,
            totalSeconds: 216,
            playbackSpeedLabel: "1.5x",
            waveformBars: waveformTemplate
        )
    ]

    private static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = max(totalSeconds, 0) / 60
        let seconds = max(totalSeconds, 0) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
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

        var id: String
        var height: Double
        var tone: Tone
    }
}
