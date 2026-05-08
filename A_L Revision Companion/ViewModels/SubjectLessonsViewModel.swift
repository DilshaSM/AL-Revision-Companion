import Foundation
import SwiftData

@MainActor
final class SubjectLessonsViewModel: ObservableObject {
    @Published private(set) var content: SubjectLessonsContent?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var pendingLessonID: Int?
    @Published private(set) var requiresSignOut = false

    private let subject: SubjectsTabContent.Subject
    private let service: SubjectsService
    private let widgetSummarySyncService: WidgetSummarySyncService

    init(
        subject: SubjectsTabContent.Subject,
        service: SubjectsService = SubjectsService(),
        widgetSummarySyncService: WidgetSummarySyncService = WidgetSummarySyncService()
    ) {
        self.subject = subject
        self.service = service
        self.widgetSummarySyncService = widgetSummarySyncService
    }

    func load(forceRefresh: Bool = false) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let tree = try await service.getSubjectUnits(subjectID: subject.id)
            content = SubjectLessonsContent.build(from: tree)
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

    func startLesson(
        _ lesson: SubjectLessonsContent.Lesson,
        modelContext: ModelContext? = nil
    ) async -> LessonQuizContent? {
        guard let topic = lesson.firstActiveTopic else {
            errorMessage = "No active topic is available for this lesson yet."
            return nil
        }

        errorMessage = ""
        pendingLessonID = lesson.id

        defer { pendingLessonID = nil }

        do {
            let openPayload = try await service.openLesson(lessonID: lesson.id)
            if let currentContent = content {
                content = currentContent.applying(progress: openPayload.lessonProgress)
            }

            try? await widgetSummarySyncService.refresh(context: modelContext)

            let quizPayload = try await service.getTopicQuiz(topicID: topic.id)
            let refreshedLesson = content?.units
                .flatMap(\.lessons)
                .first(where: { $0.id == lesson.id }) ?? lesson
            let nextLesson = content?.nextLesson(after: lesson.id)
            return LessonQuizContent.build(
                from: quizPayload,
                lesson: refreshedLesson,
                nextLesson: nextLesson
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
