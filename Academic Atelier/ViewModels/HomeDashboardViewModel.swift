import Foundation

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
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let payload = try await service.getHome()
            content = .dashboard(from: payload, for: user)
            try? await widgetSummarySyncService.refresh()

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
