import Foundation

@MainActor
final class SubjectsViewModel: ObservableObject {
    @Published private(set) var content: SubjectsTabContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: SubjectsService

    init(service: SubjectsService = SubjectsService()) {
        self.service = service
    }

    func load(for user: User?, forceRefresh: Bool = false) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let subjects = try await service.getSubjects()
            content = SubjectsTabContent.build(subjects: subjects, user: user)
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
