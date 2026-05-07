import Foundation

struct SubjectLessonsContent: Hashable {
    var id: Int
    var title: String
    var hero: Hero
    var units: [Unit]

    static func build(from subject: APISubjectTree) -> SubjectLessonsContent {
        let orderedUnits = subject.units
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { Unit(apiUnit: $0) }
        let lessons = orderedUnits.flatMap(\.lessons)
        let completedCount = lessons.filter(\.isCompleted).count
        let totalCount = max(lessons.count, 1)
        let currentLesson = lessons.first(where: \.isInProgress)
            ?? lessons.first(where: \.canStart)
            ?? lessons.first
        let progressValue = Double(completedCount) / Double(totalCount)

        return SubjectLessonsContent(
            id: subject.id,
            title: subject.displayName,
            hero: .init(
                eyebrow: "Current Study",
                title: subject.displayName,
                progress: progressValue,
                progressText: "\(Int((progressValue * 100).rounded()))%",
                currentLessonTitle: currentLesson?.title ?? "No lessons available",
                backgroundSymbolName: Self.symbolName(for: subject.icon)
            ),
            units: orderedUnits
        )
    }

    func applying(progress: UserLessonProgress) -> SubjectLessonsContent {
        var updated = self
        updated.units = units.map { unit in
            var unit = unit
            unit.lessons = unit.lessons.map { lesson in
                guard lesson.id == progress.lessonId else { return lesson }
                var lesson = lesson
                lesson.status = progress.status
                lesson.progressPercent = progress.progressPercent
                lesson.isLocked = false
                return lesson
            }
            return unit
        }

        let lessons = updated.units.flatMap(\.lessons)
        let completedCount = lessons.filter(\.isCompleted).count
        let totalCount = max(lessons.count, 1)
        let currentLesson = lessons.first(where: \.isInProgress)
            ?? lessons.first(where: \.canStart)
            ?? lessons.first
        let progressValue = Double(completedCount) / Double(totalCount)
        updated.hero = .init(
            eyebrow: hero.eyebrow,
            title: title,
            progress: progressValue,
            progressText: "\(Int((progressValue * 100).rounded()))%",
            currentLessonTitle: currentLesson?.title ?? "No lessons available",
            backgroundSymbolName: hero.backgroundSymbolName
        )

        return updated
    }

    func nextLesson(after lessonID: Int) -> Lesson? {
        let lessons = units.flatMap(\.lessons)
        guard let currentIndex = lessons.firstIndex(where: { $0.id == lessonID }) else {
            return nil
        }

        for lesson in lessons.dropFirst(currentIndex + 1) where lesson.firstActiveTopic != nil {
            return lesson
        }

        return nil
    }

    private static func symbolName(for backendIcon: String?) -> String {
        switch backendIcon?.lowercased() {
        case "flask":
            return "flask.fill"
        case "atom":
            return "atom"
        case "bolt":
            return "bolt.fill"
        case "leaf":
            return "leaf.fill"
        case "function":
            return "function"
        default:
            return "book.fill"
        }
    }
}

extension SubjectLessonsContent {
    struct Hero: Hashable {
        var eyebrow: String
        var title: String
        var progress: Double
        var progressText: String
        var currentLessonTitle: String
        var backgroundSymbolName: String
    }

    struct Unit: Identifiable, Hashable {
        var id: Int
        var title: String
        var description: String?
        var lessonCountText: String?
        var lessons: [Lesson]

        init(apiUnit: APISubjectUnit) {
            id = apiUnit.id
            title = apiUnit.title
            description = apiUnit.description
            let lessonCount = apiUnit.lessons.count
            lessonCountText = lessonCount == 0 ? nil : "\(lessonCount) " + (lessonCount == 1 ? "Lesson" : "Lessons")
            lessons = apiUnit.lessons
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { Lesson(apiLesson: $0) }
        }
    }

    struct Lesson: Identifiable, Hashable {
        var id: Int
        var title: String
        var description: String?
        var estimatedDurationMinutes: Int?
        var status: String
        var progressPercent: Int
        var isLocked: Bool
        var topics: [Topic]

        init(apiLesson: APISubjectLesson) {
            id = apiLesson.id
            title = apiLesson.title
            description = apiLesson.description
            estimatedDurationMinutes = apiLesson.estimatedDurationMinutes
            status = apiLesson.status
            progressPercent = apiLesson.progressPercent
            isLocked = apiLesson.isLocked
            topics = apiLesson.topics
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { Topic(apiTopic: $0) }
        }
    }

    struct Topic: Identifiable, Hashable {
        var id: Int
        var title: String
        var subtitle: String?
        var estimatedDurationMinutes: Int?
        var isActive: Bool

        init(apiTopic: APISubjectTopic) {
            id = apiTopic.id
            title = apiTopic.title
            subtitle = apiTopic.subtitle
            estimatedDurationMinutes = apiTopic.estimatedDurationMinutes
            isActive = apiTopic.isActive
        }
    }

    enum State: Hashable {
        case available(detailText: String)
        case completed(detailText: String)
        case inProgress(progress: Double, progressText: String)
        case locked(detailText: String)
    }
}

extension SubjectLessonsContent.Lesson {
    var firstActiveTopic: SubjectLessonsContent.Topic? {
        topics.first(where: \.isActive)
    }

    var canStart: Bool {
        !isLocked && firstActiveTopic != nil
    }

    var isCompleted: Bool {
        status.uppercased() == "COMPLETED" || progressPercent >= 100
    }

    var isInProgress: Bool {
        status.uppercased() == "IN_PROGRESS" || (!isCompleted && progressPercent > 0)
    }

    var state: SubjectLessonsContent.State {
        if isLocked {
            return .locked(detailText: "Complete the previous lesson quiz to unlock.")
        }

        if isCompleted {
            return .completed(detailText: completionDetailText)
        }

        if isInProgress {
            return .inProgress(
                progress: Double(progressPercent) / 100.0,
                progressText: "\(progressPercent)% done"
            )
        }

        return .available(detailText: estimatedDurationText ?? "Ready to start")
    }

    var nextActionTitle: String {
        firstActiveTopic?.title ?? title
    }

    private var estimatedDurationText: String? {
        guard let estimatedDurationMinutes else { return nil }

        if estimatedDurationMinutes == 1 {
            return "1 min"
        }

        return "\(estimatedDurationMinutes) mins"
    }

    private var completionDetailText: String {
        if let estimatedDurationText {
            return "Completed • \(estimatedDurationText)"
        }

        return "Completed"
    }
}
