import Foundation

@MainActor
final class ReviewAnswersViewModel: ObservableObject {
    @Published private(set) var review: ReviewAnswersContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: SubjectsService

    init(service: SubjectsService = SubjectsService()) {
        self.service = service
    }

    func load(for result: QuizResultContent, forceRefresh: Bool = false) async {
        guard forceRefresh || review?.attemptID != result.attemptID else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let payload = try await service.getAttemptReview(attemptID: result.attemptID)
            review = ReviewAnswersContent.build(from: payload, result: result)
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
