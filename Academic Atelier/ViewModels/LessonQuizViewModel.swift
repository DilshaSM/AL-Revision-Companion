import Foundation

@MainActor
final class LessonQuizViewModel: ObservableObject {
    @Published private(set) var attemptID: Int?
    @Published private(set) var isStartingAttempt = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: SubjectsService
    private let dashboardService: DashboardService
    private let notificationScheduler: RevisionNotificationScheduler
    private let widgetSummarySyncService: WidgetSummarySyncService
    private var startedQuizID: Int?

    init(
        service: SubjectsService = SubjectsService(),
        dashboardService: DashboardService = DashboardService(),
        notificationScheduler: RevisionNotificationScheduler = RevisionNotificationScheduler(),
        widgetSummarySyncService: WidgetSummarySyncService = WidgetSummarySyncService()
    ) {
        self.service = service
        self.dashboardService = dashboardService
        self.notificationScheduler = notificationScheduler
        self.widgetSummarySyncService = widgetSummarySyncService
    }

    func startAttemptIfNeeded(for content: LessonQuizContent) async {
        guard startedQuizID != content.quizID else { return }

        isStartingAttempt = true
        errorMessage = ""
        requiresSignOut = false

        defer { isStartingAttempt = false }

        do {
            let payload = try await service.startQuiz(quizID: content.quizID)
            attemptID = payload.attemptId
            startedQuizID = content.quizID
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

    func submit(
        content: LessonQuizContent,
        selectedOptionIDsByQuestionID: [Int: Int?],
        notificationsEnabled: Bool
    ) async -> QuizResultContent? {
        guard let attemptID else {
            errorMessage = "The quiz attempt is not ready yet. Please try again."
            return nil
        }

        isSubmitting = true
        errorMessage = ""
        requiresSignOut = false

        defer { isSubmitting = false }

        do {
            let answers = content.questions.map { question in
                SubmitQuizAnswerRequest(
                    questionId: question.id,
                    selectedOptionId: selectedOptionIDsByQuestionID[question.id] ?? nil
                )
            }

            let payload = try await service.submitQuiz(
                quizID: content.quizID,
                attemptID: attemptID,
                answers: answers
            )

            try? await widgetSummarySyncService.refresh()

            if notificationsEnabled {
                let dashboardPayload = try? await dashboardService.getHome()
                try? await notificationScheduler.rescheduleNotifications(
                    isEnabled: true,
                    homePayload: dashboardPayload
                )
            }

            return QuizResultContent.build(
                from: content,
                submission: payload
            )
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return nil
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
