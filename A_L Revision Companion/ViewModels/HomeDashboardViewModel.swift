import Foundation
import SwiftData

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    @Published private(set) var content: HomeDashboardContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: DashboardService
    private let widgetSummarySyncService: WidgetSummarySyncService

    init(
        service: DashboardService = DashboardService(),
        widgetSummarySyncService: WidgetSummarySyncService = WidgetSummarySyncService()
    ) {
        self.service = service
        self.widgetSummarySyncService = widgetSummarySyncService
    }

    func load(for user: User?, forceRefresh: Bool = false) async {
        await load(for: user, forceRefresh: forceRefresh, modelContext: nil)
    }

    func load(for user: User?, forceRefresh: Bool = false, modelContext: ModelContext?) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let payload = try await service.getHome()
            var dashboard = HomeDashboardContent.dashboard(from: payload, for: user)

            if let modelContext {
                let persistence = LocalPersistenceService(context: modelContext)

                if let localWidgetSummary = try? persistence.loadWidgetSummary() {
                    dashboard = dashboard.applyingLocalContinueLearning(localWidgetSummary)
                }

                if dashboard.recentSubjects.isEmpty,
                   let localSubjects = try? persistence.loadRecentSubjects(),
                   !localSubjects.isEmpty {
                    dashboard = dashboard.applyingLocalRecentSubjects(localSubjects)
                }
            }

            content = dashboard
            try? await widgetSummarySyncService.refresh(context: modelContext)

            if user?.preference?.areNotificationsEnabled == true {
                try? await RevisionNotificationScheduler().rescheduleNotifications(
                    isEnabled: true,
                    homePayload: payload
                )
            }
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                if content == nil, let modelContext {
                    let persistence = LocalPersistenceService(context: modelContext)
                    var fallbackContent = HomeDashboardContent.placeholder(for: user)

                    if let localWidgetSummary = try? persistence.loadWidgetSummary() {
                        fallbackContent = fallbackContent.applyingLocalContinueLearning(localWidgetSummary)
                    }

                    if let localSubjects = try? persistence.loadRecentSubjects(),
                       !localSubjects.isEmpty {
                        fallbackContent = fallbackContent.applyingLocalRecentSubjects(localSubjects)
                    }

                    content = fallbackContent
                }
                errorMessage = error.localizedDescription
            }
        } catch {
            if content == nil, let modelContext {
                let persistence = LocalPersistenceService(context: modelContext)
                var fallbackContent = HomeDashboardContent.placeholder(for: user)

                if let localWidgetSummary = try? persistence.loadWidgetSummary() {
                    fallbackContent = fallbackContent.applyingLocalContinueLearning(localWidgetSummary)
                }

                if let localSubjects = try? persistence.loadRecentSubjects(),
                   !localSubjects.isEmpty {
                    fallbackContent = fallbackContent.applyingLocalRecentSubjects(localSubjects)
                }

                content = fallbackContent
            }
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
