import Foundation

struct DashboardService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getHome() async throws -> DashboardHomePayload {
        try await client.send(
            path: "/dashboard/home",
            method: "GET",
            requiresAuth: true
        )
    }

    func getWidgetSummary() async throws -> WidgetSummaryPayload {
        try await client.send(
            path: "/widgets/summary",
            method: "GET",
            requiresAuth: true
        )
    }

    func getProgress() async throws -> DashboardProgressPayload {
        try await client.send(
            path: "/dashboard/progress",
            method: "GET",
            requiresAuth: true
        )
    }

    func getRecommendations() async throws -> DashboardRecommendationsPayload {
        try await client.send(
            path: "/dashboard/recommendations",
            method: "GET",
            requiresAuth: true
        )
    }
}
