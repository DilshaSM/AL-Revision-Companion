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

            if dashboard.recentSubjects.isEmpty,
               let modelContext,
               let localSubjects = try? LocalPersistenceService(context: modelContext).loadRecentSubjects(),
               !localSubjects.isEmpty {
                dashboard = dashboard.applyingLocalRecentSubjects(localSubjects)
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
                if content == nil,
                   let modelContext,
                   let localSubjects = try? LocalPersistenceService(context: modelContext).loadRecentSubjects(),
                   !localSubjects.isEmpty {
                    content = HomeDashboardContent
                        .placeholder(for: user)
                        .applyingLocalRecentSubjects(localSubjects)
                }
                errorMessage = error.localizedDescription
            }
        } catch {
            if content == nil,
               let modelContext,
               let localSubjects = try? LocalPersistenceService(context: modelContext).loadRecentSubjects(),
               !localSubjects.isEmpty {
                content = HomeDashboardContent
                    .placeholder(for: user)
                    .applyingLocalRecentSubjects(localSubjects)
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
