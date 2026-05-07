import Foundation
import SwiftData

struct WidgetSummaryService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getWidgetSummary() async throws -> WidgetSummaryPayload {
        try await client.send(
            path: "/widgets/summary",
            method: "GET",
            requiresAuth: true
        )
    }
}

struct WidgetSummarySyncService {
    private let widgetSummaryService: WidgetSummaryService
    private let widgetCacheService: WidgetCacheService

    init(
        widgetSummaryService: WidgetSummaryService = WidgetSummaryService(),
        widgetCacheService: WidgetCacheService = .shared
    ) {
        self.widgetSummaryService = widgetSummaryService
        self.widgetCacheService = widgetCacheService
    }

    @MainActor
    func refresh(context: ModelContext? = nil) async throws {
        let payload = try await widgetSummaryService.getWidgetSummary()
        widgetCacheService.save(CachedWidgetSummary(payload: payload))

        if let context {
            try LocalPersistenceService(context: context).saveWidgetSummary(
                WidgetSummaryEntity(payload: payload)
            )
        }
    }

    func clear() {
        widgetCacheService.clear()
    }
}

extension CachedWidgetSummary {
    init(payload: WidgetSummaryPayload) {
        let widgets = payload.widgets

        continueLearning = widgets.continueLearning.map {
            CachedContinueLearning(
                title: $0.title,
                subtitle: $0.subtitle,
                progressPercent: $0.progressPercent,
                lessonId: $0.lessonId,
                topicId: $0.topicId,
                subjectId: $0.subjectId
            )
        }

        todaysFocus = widgets.todaysFocus.map {
            CachedTodaysFocus(
                title: $0.title,
                subtitle: $0.subtitle,
                topicId: $0.topicId,
                subjectId: $0.subjectId
            )
        }

        revisionProgress = CachedRevisionProgress(
            weeklyGoalPercent: widgets.revisionProgress.weeklyGoalPercent,
            focusTimeMinutes: widgets.revisionProgress.focusTimeMinutes,
            activeDays: widgets.revisionProgress.activeDays,
            chaptersCompleted: widgets.revisionProgress.chaptersCompleted
        )

        updatedAt = payload.updatedAt
    }
}
