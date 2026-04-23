import Foundation

struct SubjectsTabContent: Hashable {
    var title: String
    var assessment: Assessment
    var subjectsSectionTitle: String
    var subjectsActionTitle: String
    var subjects: [Subject]

    static let placeholder = SubjectsTabContent(
        title: "Your Subjects",
        assessment: .init(
            eyebrow: "Upcoming Assessment",
            title: "Weekly Mock Exam",
            subtitle: "Sunday, 09:00 AM • All Subjects",
            badgeCountText: "7"
        ),
        subjectsSectionTitle: "Active Curriculum",
        subjectsActionTitle: "View All",
        subjects: [
            .init(
                id: "combined-science",
                title: "Combined Science",
                lastActiveText: "Last active: 2 hours ago",
                levelText: "A-Level",
                nextLessonLabel: "Next Lesson",
                nextLessonTitle: "Unit 4: Chemical Bonding",
                progress: 0.78,
                progressText: "78%"
            ),
            .init(
                id: "pure-mathematics",
                title: "Pure Mathematics",
                lastActiveText: "Last active: Yesterday",
                levelText: "A-Level",
                nextLessonLabel: "Next Lesson",
                nextLessonTitle: "Integration: Areas",
                progress: 0.62,
                progressText: "62%"
            ),
            .init(
                id: "modern-physics",
                title: "Modern Physics",
                lastActiveText: "Last active: 3 days ago",
                levelText: "A-Level",
                nextLessonLabel: "Next Lesson",
                nextLessonTitle: "Wave-Particle Duality",
                progress: 0.45,
                progressText: "45%"
            )
        ]
    )

    func lessonsContent(for subject: Subject) -> SubjectLessonsContent? {
        SubjectLessonsContent.placeholderByID[subject.id]
    }

    func lessonsContent(forID id: String) -> SubjectLessonsContent? {
        SubjectLessonsContent.placeholderByID[id]
    }
}

extension SubjectsTabContent {
    struct Assessment: Hashable {
        var eyebrow: String
        var title: String
        var subtitle: String
        var badgeCountText: String
        var symbolName: String = "calendar"
    }

    struct Subject: Identifiable, Hashable {
        var id: String
        var title: String
        var lastActiveText: String
        var levelText: String
        var nextLessonLabel: String
        var nextLessonTitle: String
        var progress: Double
        var progressText: String
    }
}
