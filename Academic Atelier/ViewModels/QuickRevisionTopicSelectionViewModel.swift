import Foundation

@MainActor
final class QuickRevisionTopicSelectionViewModel: ObservableObject {
    @Published private(set) var topics: [QuickRevisionTopic] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: QuickRevisionService

    init(service: QuickRevisionService = QuickRevisionService()) {
        self.service = service
    }

    func load(subject: QuickRevisionSubject, forceRefresh: Bool = false) async {
        guard forceRefresh || topics.isEmpty else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let payload = try await service.getTopics(subjectID: subject.id)
            topics = payload.quickRevisionTopics.map {
                QuickRevisionTopic(apiTopic: $0, symbolName: subject.symbolName)
            }
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
