import Foundation

struct ProgressTabContent: Hashable {
    var title: String
    var subtitle: String
    var weeklyEngagement: WeeklyEngagement
    var subjectMasteryTitle: String
    var subjectMasterySubtitle: String
    var subjectMasteries: [SubjectMastery]
    var featuredRecommendations: [String: RecommendationsContent]

    static let placeholder = ProgressTabContent(
        title: "Revision Insights",
        subtitle: "Quantifying your academic\nperformance over the last 7 days.",
        weeklyEngagement: .init(
            eyebrow: "Activity Tracking",
            title: "Weekly Engagement",
            days: [
                .init(id: "mon", shortLabel: "MON", hoursLabel: "3.0 H", hours: 3.0, barHeight: 40),
                .init(id: "tue", shortLabel: "TUE", hoursLabel: "4.5 H", hours: 4.5, barHeight: 60),
                .init(id: "wed", shortLabel: "WED", hoursLabel: "7.0 H", hours: 7.0, barHeight: 139, isHighlighted: true),
                .init(id: "thu", shortLabel: "THU", hoursLabel: "3.5 H", hours: 3.5, barHeight: 45),
                .init(id: "fri", shortLabel: "FRI", hoursLabel: "4.0 H", hours: 4.0, barHeight: 50),
                .init(id: "sat", shortLabel: "SAT", hoursLabel: "1.5 H", hours: 1.5, barHeight: 25),
                .init(id: "sun", shortLabel: "SUN", hoursLabel: "1.0 H", hours: 1.0, barHeight: 20)
            ],
            statCards: [
                .init(id: "focus-time", iconName: "timer", title: "Focus Time", valueText: "24.5h"),
                .init(id: "chapters", iconName: "book.closed", title: "Chapters", valueText: "18/42")
            ]
        ),
        subjectMasteryTitle: "Subject Mastery",
        subjectMasterySubtitle: "Real-time curriculum tracking",
        subjectMasteries: [
            .init(
                id: "physics",
                title: "Physics",
                unitTitle: "UNIT 4: MECHANICS",
                progress: 0.78,
                progressText: "78%",
                iconName: "atom",
                accentStyle: .brand,
                recommendationsID: "focus-foundations"
            ),
            .init(
                id: "chemistry",
                title: "Chemistry",
                unitTitle: "ORGANIC TRANSITIONS",
                progress: 0.42,
                progressText: "42%",
                iconName: "flask",
                accentStyle: .muted,
                recommendationsID: "focus-foundations"
            ),
            .init(
                id: "biology",
                title: "Biology",
                unitTitle: "GENETICS & EVOLUTION",
                progress: 0.92,
                progressText: "92%",
                iconName: "microscope",
                accentStyle: .brand,
                recommendationsID: "focus-foundations"
            )
        ],
        featuredRecommendations: [
            "focus-foundations": .placeholder
        ]
    )

    func recommendationsContent(for subjectMastery: SubjectMastery) -> RecommendationsContent? {
        featuredRecommendations[subjectMastery.recommendationsID]
    }
}

extension ProgressTabContent {
    struct WeeklyEngagement: Hashable {
        var eyebrow: String
        var title: String
        var days: [WeeklyDay]
        var statCards: [StatCard]
    }

    struct WeeklyDay: Identifiable, Hashable {
        var id: String
        var shortLabel: String
        var hoursLabel: String
        var hours: Double
        var barHeight: Double
        var isHighlighted: Bool = false
    }

    struct StatCard: Identifiable, Hashable {
        var id: String
        var iconName: String
        var title: String
        var valueText: String
    }

    struct SubjectMastery: Identifiable, Hashable {
        enum AccentStyle: String, Hashable {
            case brand
            case muted
        }

        var id: String
        var title: String
        var unitTitle: String
        var progress: Double
        var progressText: String
        var iconName: String
        var accentStyle: AccentStyle
        var recommendationsID: String
    }
}
