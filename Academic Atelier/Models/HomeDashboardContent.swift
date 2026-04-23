import Foundation

struct HomeDashboardContent {
    var appTitle: String
    var greetingLine: String
    var greetingHeadline: String
    var continueLearning: ContinueLearningContent
    var todaysFocus: TodaysFocusContent
    var quickToolsTitle: String
    var quickTools: [QuickToolContent]
    var weeklyProgress: WeeklyProgressContent
    var weakness: WeaknessContent
    var recentSubjectsTitle: String
    var recentSubjects: RecentSubjectsContent

    static func placeholder(for user: User?, date: Date = Date()) -> HomeDashboardContent {
        let name = firstName(from: user)
        let greeting = greetingPrefix(for: date)

        return HomeDashboardContent(
            appTitle: "A/L Revision Companion",
            greetingLine: "\(greeting), \(name).",
            greetingHeadline: "Ready for today's\nsession?",
            continueLearning: .init(
                eyebrow: "Continue Learning",
                title: "Pure Mathematics:\nTrigonometric\nFunctions II",
                progress: 0.64,
                progressText: "64%",
                actionTitle: "Resume"
            ),
            todaysFocus: .init(
                eyebrow: "Today's Focus",
                timerText: "15M REMAINING",
                title: "Organic\nChemistry:\nReaction\nMechanisms",
                subtitle: "Master the nucleophilic substitution\npatterns before the mock exam.",
                actionTitle: "Start Revision"
            ),
            quickToolsTitle: "Quick Tools",
            quickTools: [
                .init(
                    id: "quick-revision",
                    title: "Quick Revision",
                    subtitle: "Short notes & formulas",
                    icon: "doc.text.fill",
                    accentStyle: .blue,
                    destination: .quickRevision
                ),
                .init(
                    id: "recall-tools",
                    title: "Recall Tools",
                    subtitle: "Flashcards & Audio",
                    icon: "speaker.wave.2.fill",
                    accentStyle: .orange,
                    destination: .recallTools
                )
            ],
            weeklyProgress: .init(
                eyebrow: "Your Performance",
                title: "Weekly Progress",
                scoreText: "72%",
                statusText: "GOAL REACHED",
                days: [
                    .init(id: "mon", label: "M", value: 0.47),
                    .init(id: "tue", label: "T", value: 0.71),
                    .init(id: "wed", label: "W", value: 0.35),
                    .init(id: "thu", label: "T", value: 1.0),
                    .init(id: "fri", label: "F", value: 0.85, isHighlighted: true),
                    .init(id: "sat", label: "S", value: 0.0),
                    .init(id: "sun", label: "S", value: 0.0)
                ]
            ),
            weakness: .init(
                eyebrow: "Your Weakness",
                statusText: "Needs Attention",
                title: "Organic Chemistry: Reaction\nMechanisms",
                metricLabel: "Accuracy",
                metricValueText: "45%",
                progress: 0.45,
                note: "Focus on nucleophilic substitution & past MCQs to improve faster.",
                actionTitle: "Practice now"
            ),
            recentSubjectsTitle: "Recent Subjects",
            recentSubjects: .init(
                compactCards: [
                    .init(
                        id: "physics",
                        title: "Physics",
                        detail: "2H AGO",
                        progress: 0.45,
                        progressText: "45%",
                        icon: "bolt.fill",
                        accentStyle: .blue
                    ),
                    .init(
                        id: "chemistry",
                        title: "Chemistry",
                        detail: "5H AGO",
                        progress: 0.82,
                        progressText: "82%",
                        icon: "drop.fill",
                        accentStyle: .orange
                    )
                ],
                featuredCard: .init(
                    title: "Biology",
                    detail: "NEXT: MOLECULAR GENETICS",
                    icon: "leaf.fill",
                    accentStyle: .biology,
                    valueText: "12/18",
                    trailingLabel: "UNITS"
                )
            )
        )
    }
}

extension HomeDashboardContent {
    struct ContinueLearningContent {
        var eyebrow: String
        var title: String
        var progress: Double
        var progressText: String
        var actionTitle: String
    }

    struct TodaysFocusContent {
        var eyebrow: String
        var timerText: String
        var title: String
        var subtitle: String
        var actionTitle: String
    }

    struct QuickToolContent: Identifiable {
        var id: String
        var title: String
        var subtitle: String
        var icon: String
        var accentStyle: HomeAccentStyle
        var destination: HomeQuickToolDestination?
    }

    struct WeeklyProgressContent {
        var eyebrow: String
        var title: String
        var scoreText: String
        var statusText: String
        var days: [DayProgress]
    }

    struct DayProgress: Identifiable {
        var id: String
        var label: String
        var value: Double
        var isHighlighted: Bool = false
    }

    struct WeaknessContent {
        var eyebrow: String
        var statusText: String
        var title: String
        var metricLabel: String
        var metricValueText: String
        var progress: Double
        var note: String
        var actionTitle: String
    }

    struct RecentSubjectsContent {
        var compactCards: [CompactRecentSubjectContent]
        var featuredCard: FeaturedRecentSubjectContent
    }

    struct CompactRecentSubjectContent: Identifiable {
        var id: String
        var title: String
        var detail: String
        var progress: Double
        var progressText: String
        var icon: String
        var accentStyle: HomeAccentStyle
    }

    struct FeaturedRecentSubjectContent {
        var title: String
        var detail: String
        var icon: String
        var accentStyle: HomeAccentStyle
        var valueText: String
        var trailingLabel: String
    }
}

enum HomeAccentStyle {
    case blue
    case orange
    case biology
}

enum HomeQuickToolDestination {
    case quickRevision
    case recallTools
}

private extension HomeDashboardContent {
    static func firstName(from user: User?) -> String {
        user?.fullName
            .split(separator: " ")
            .first
            .map(String.init) ?? "Student"
    }

    static func greetingPrefix(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
}
