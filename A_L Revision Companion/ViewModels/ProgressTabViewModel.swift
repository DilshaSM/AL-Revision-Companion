import Foundation

@MainActor
final class ProgressTabViewModel: ObservableObject {
    @Published private(set) var content: ProgressTabContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let dashboardService: DashboardService
    private let subjectsService: SubjectsService

    init(
        dashboardService: DashboardService = DashboardService(),
        subjectsService: SubjectsService = SubjectsService()
    ) {
        self.dashboardService = dashboardService
        self.subjectsService = subjectsService
    }

    func load(forceRefresh: Bool = false) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let progressPayload = try await dashboardService.getProgress()

            let subjects: [APISubject]
            do {
                subjects = try await subjectsService.getSubjects()
            } catch let error as APIError {
                if error.requiresSignOut {
                    throw error
                }
                subjects = []
            } catch {
                subjects = []
            }

            content = ProgressTabContent.build(
                progress: progressPayload,
                subjects: subjects
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
