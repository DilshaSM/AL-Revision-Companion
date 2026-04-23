import Foundation

struct SubjectLessonsContent: Hashable {
    var id: String
    var title: String
    var hero: Hero
    var units: [Unit]

    static func placeholder(forID id: String) -> SubjectLessonsContent? {
        placeholderByID[id]
    }

    static let placeholderByID: [String: SubjectLessonsContent] = [
        "combined-science": .init(
            id: "combined-science",
            title: "Combined Science",
            hero: .init(
                eyebrow: "Current Study",
                title: "Combined Science",
                progress: 0.78,
                progressText: "78%",
                currentLessonTitle: "Unit 4: Chemical Bonding",
                backgroundSymbolName: "atom"
            ),
            units: [
                .init(
                    id: "chemistry-foundations",
                    title: "Unit 01: Chemistry Foundations",
                    lessonCountText: "2 Lessons",
                    lessons: [
                        .init(id: "atomic-structure", title: "Atomic Structure", state: .completed(detailText: "Completed • 35 mins")),
                        .init(id: "mole-concept", title: "Mole Concept", state: .completed(detailText: "Completed • 50 mins"))
                    ]
                ),
                .init(
                    id: "chemical-bonding",
                    title: "Unit 02: Chemical Bonding",
                    lessonCountText: "2 Lessons",
                    lessons: [
                        .init(id: "ionic-covalent", title: "Unit 4: Chemical Bonding", state: .inProgress(progress: 0.78, progressText: "78% done")),
                        .init(id: "intermolecular-forces", title: "Intermolecular Forces", state: .locked)
                    ]
                ),
                .init(
                    id: "energy-and-rates",
                    title: "Unit 03: Energy and Rates",
                    lessonCountText: nil,
                    lessons: [
                        .init(id: "reaction-energetics", title: "Reaction Energetics", state: .locked)
                    ]
                )
            ]
        ),
        "pure-mathematics": .init(
            id: "pure-mathematics",
            title: "Pure Mathematics",
            hero: .init(
                eyebrow: "Current Study",
                title: "Pure Mathematics",
                progress: 0.64,
                progressText: "64%",
                currentLessonTitle: "Trigonometric Functions II",
                backgroundSymbolName: "scope"
            ),
            units: [
                .init(
                    id: "algebra",
                    title: "Unit 01: Algebra",
                    lessonCountText: "2 Lessons",
                    lessons: [
                        .init(id: "indices", title: "Indices and Logarithms", state: .completed(detailText: "Completed • 45 mins")),
                        .init(id: "quadratics", title: "Quadratic Equations", state: .completed(detailText: "Completed • 1h 20m"))
                    ]
                ),
                .init(
                    id: "trigonometry",
                    title: "Unit 02: Trigonometry",
                    lessonCountText: nil,
                    lessons: [
                        .init(id: "trig-functions-2", title: "Trigonometric Functions II", state: .inProgress(progress: 0.40, progressText: "40% done")),
                        .init(id: "inverse-circular", title: "Inverse Circular Functions", state: .locked)
                    ]
                ),
                .init(
                    id: "calculus",
                    title: "Unit 03: Calculus",
                    lessonCountText: nil,
                    lessons: [
                        .init(id: "limits-continuity", title: "Limits and Continuity", state: .locked)
                    ]
                )
            ]
        ),
        "modern-physics": .init(
            id: "modern-physics",
            title: "Modern Physics",
            hero: .init(
                eyebrow: "Current Study",
                title: "Modern Physics",
                progress: 0.45,
                progressText: "45%",
                currentLessonTitle: "Wave-Particle Duality",
                backgroundSymbolName: "atom"
            ),
            units: [
                .init(
                    id: "relativity",
                    title: "Unit 01: Relativity",
                    lessonCountText: "2 Lessons",
                    lessons: [
                        .init(id: "frames-of-reference", title: "Frames of Reference", state: .completed(detailText: "Completed • 32 mins")),
                        .init(id: "time-dilation", title: "Time Dilation", state: .completed(detailText: "Completed • 48 mins"))
                    ]
                ),
                .init(
                    id: "quantum-theory",
                    title: "Unit 02: Quantum Theory",
                    lessonCountText: nil,
                    lessons: [
                        .init(id: "wave-particle", title: "Wave-Particle Duality", state: .inProgress(progress: 0.45, progressText: "45% done")),
                        .init(id: "photoelectric", title: "Photoelectric Effect", state: .locked)
                    ]
                ),
                .init(
                    id: "nuclear-physics",
                    title: "Unit 03: Nuclear Physics",
                    lessonCountText: nil,
                    lessons: [
                        .init(id: "radioactivity", title: "Radioactivity", state: .locked)
                    ]
                )
            ]
        )
    ]
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
        var id: String
        var title: String
        var lessonCountText: String?
        var lessons: [Lesson]
    }

    struct Lesson: Identifiable, Hashable {
        var id: String
        var title: String
        var state: State
    }

    enum State: Hashable {
        case completed(detailText: String)
        case inProgress(progress: Double, progressText: String)
        case locked
    }
}

extension SubjectLessonsContent {
    var currentLesson: Lesson? {
        allLessons.first(where: { $0.isInProgress }) ?? allLessons.first(where: { $0.isAccessible })
    }

    func quizContent(for lesson: Lesson) -> LessonQuizContent? {
        LessonQuizContent.placeholder(forSubjectID: id, subjectTitle: title, lesson: lesson)
    }

    private var allLessons: [Lesson] {
        units.flatMap(\.lessons)
    }
}

extension SubjectLessonsContent.Lesson {
    var isAccessible: Bool {
        switch state {
        case .locked:
            return false
        case .completed, .inProgress:
            return true
        }
    }

    var isInProgress: Bool {
        switch state {
        case .inProgress:
            return true
        case .completed, .locked:
            return false
        }
    }
}
