import Foundation

@MainActor
final class QuickRevisionContentViewModel: ObservableObject {
    @Published private(set) var content: QuickRevisionTopicDetailContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: QuickRevisionService

    init(service: QuickRevisionService = QuickRevisionService()) {
        self.service = service
    }

    @discardableResult
    func load(topic: QuickRevisionTopic) async -> Bool {
        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let payload = try await service.getTopicDetail(topicID: topic.id)
            content = QuickRevisionTopicDetailContent(apiTopic: payload)
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
