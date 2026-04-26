import Foundation

@MainActor
final class RecommendationsViewModel: ObservableObject {
    @Published private(set) var content: RecommendationsContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let dashboardService: DashboardService

    init(dashboardService: DashboardService = DashboardService()) {
        self.dashboardService = dashboardService
    }

    func load(
        preferredSubject: ProgressTabContent.SubjectMastery?,
        forceRefresh: Bool = false
    ) async {
        guard forceRefresh || content == nil || content?.preferredSubjectID != preferredSubject?.subjectID else {
            return
        }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let payload = try await dashboardService.getRecommendations()
            content = RecommendationsContent.build(
                recommendations: payload.recommendations,
                preferredSubject: preferredSubject
            )
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
