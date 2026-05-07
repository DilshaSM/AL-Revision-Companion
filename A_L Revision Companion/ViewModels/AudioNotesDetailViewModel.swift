import Foundation

@MainActor
final class AudioNotesDetailViewModel: ObservableObject {
    @Published private(set) var content: AudioNotesDetailContent?
    @Published private(set) var isLoading = false
    @Published private(set) var isSavingProgress = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: RecallToolsService
    private let storage: LocalStorageService

    init(
        service: RecallToolsService = RecallToolsService(),
        storage: LocalStorageService = .shared
    ) {
        self.service = service
        self.storage = storage
    }

    func load(note: AudioNotesTopicSelectionContent.Note) async {
        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let detail = try await service.getAudioNoteDetail(audioNoteID: note.id)
            let localState = storage.loadAudioNotePlaybackState(audioNoteID: note.id)
            content = .build(detail: detail, localState: localState)
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func saveProgress(
        noteID: Int,
        lastPositionSeconds: Int,
        playbackSpeed: Double,
        durationMinutes: Int,
        ended: Bool
    ) async -> Bool {
        isSavingProgress = true
        errorMessage = ""
        requiresSignOut = false

        defer { isSavingProgress = false }

        do {
            let payload = try await service.saveAudioNoteProgress(
                audioNoteID: noteID,
                lastPositionSeconds: lastPositionSeconds,
                playbackSpeed: playbackSpeed,
                durationMinutes: durationMinutes,
                ended: ended
            )

            let updatedState = AudioNotePlaybackState(
                audioNoteId: payload.history.audioNoteId,
                lastPositionSeconds: payload.history.lastPositionSeconds,
                playbackSpeed: payload.history.playbackSpeed,
                lastPlayedAt: payload.history.lastPlayedAt
            )
            storage.saveAudioNotePlaybackState(updatedState)

            if let currentContent = content {
                content = AudioNotesDetailContent(
                    id: currentContent.id,
                    subjectID: currentContent.subjectID,
                    topicID: currentContent.topicID,
                    topBarLabel: currentContent.topBarLabel,
                    topBarTitle: currentContent.topBarTitle,
                    lessonTitle: currentContent.lessonTitle,
                    summary: currentContent.summary,
                    audioURLString: currentContent.audioURLString,
                    elapsedSeconds: payload.history.lastPositionSeconds,
                    totalSeconds: currentContent.totalSeconds,
                    playbackSpeed: payload.history.playbackSpeed,
                    waveformBars: currentContent.waveformBars,
                    audioUnavailableMessage: currentContent.audioUnavailableMessage
                )
            }

            if ended {
                storage.clearAudioNotePlaybackState(audioNoteID: noteID)
            }

            return true
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        let localState = AudioNotePlaybackState(
            audioNoteId: noteID,
            lastPositionSeconds: lastPositionSeconds,
            playbackSpeed: playbackSpeed,
            lastPlayedAt: Date()
        )
        storage.saveAudioNotePlaybackState(localState)
        return false
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
