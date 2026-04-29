import Foundation

@MainActor
final class AudioNotesTopicSelectionViewModel: ObservableObject {
    @Published private(set) var content: AudioNotesTopicSelectionContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: RecallToolsService

    init(service: RecallToolsService = RecallToolsService()) {
        self.service = service
    }

    func load(forceRefresh: Bool = false) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let audioNotes = try await service.getAudioNotes()
            content = .build(audioNotes: audioNotes)
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
