import Foundation

@MainActor
final class QuickRevisionViewModel: ObservableObject {
    @Published private(set) var content: QuickRevisionContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: QuickRevisionService

    init(service: QuickRevisionService = QuickRevisionService()) {
        self.service = service
    }

    func load(forceRefresh: Bool = false) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let subjects = try await service.getSubjects()
            content = .build(subjects: subjects)
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
