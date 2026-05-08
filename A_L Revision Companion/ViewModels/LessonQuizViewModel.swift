import Foundation
import SwiftData

@MainActor
final class LessonQuizViewModel: ObservableObject {
    @Published private(set) var attemptID: Int?
    @Published private(set) var currentAttempt: QuizAttemptState?
    @Published private(set) var isStartingAttempt = false
    @Published private(set) var isSavingProgress = false
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

    func prepareAttemptIfNeeded(for content: LessonQuizContent) async {
        guard startedQuizID != content.quizID else { return }

        errorMessage = ""
        requiresSignOut = false

        if let resumeAttempt = content.resumeAttempt {
            applyAttempt(resumeAttempt)
            startedQuizID = content.quizID
            return
        }

        isStartingAttempt = true

        defer { isStartingAttempt = false }

        do {
            let payload = try await service.startQuiz(quizID: content.quizID)
            applyAttempt(payload)
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

    func saveProgress(
        content: LessonQuizContent,
        selectedOptionIDsByQuestionID: [Int: Int]
    ) async -> Bool {
        guard let attemptID else { return false }

        isSavingProgress = true
        errorMessage = ""
        requiresSignOut = false

        defer { isSavingProgress = false }

        do {
            let answers: [SubmitQuizAnswerRequest] = content.questions.compactMap { question in
                guard let selectedOptionID = selectedOptionIDsByQuestionID[question.id] else {
                    return nil
                }

                return SubmitQuizAnswerRequest(
                    questionId: question.id,
                    selectedOptionId: selectedOptionID
                )
            }

            let payload = try await service.saveQuizProgress(
                quizID: content.quizID,
                attemptID: attemptID,
                answers: answers
            )

            applyAttempt(payload.attempt)
            return true
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func submit(
        content: LessonQuizContent,
        selectedOptionIDsByQuestionID: [Int: Int?],
        notificationsEnabled: Bool,
        modelContext: ModelContext? = nil
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

            try? await widgetSummarySyncService.refresh(context: modelContext)

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

    private func applyAttempt(_ attempt: QuizAttemptState) {
        currentAttempt = attempt
        attemptID = attempt.attemptId
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
