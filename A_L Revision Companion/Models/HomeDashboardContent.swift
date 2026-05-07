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
                        subjectId: 1,
                        title: "Physics",
                        detail: "2H AGO",
                        progress: 0.45,
                        progressText: "45%",
                        icon: "bolt.fill",
                        accentStyle: .blue
                    ),
                    .init(
                        id: "chemistry",
                        subjectId: 2,
                        title: "Chemistry",
                        detail: "5H AGO",
                        progress: 0.82,
                        progressText: "82%",
                        icon: "drop.fill",
                        accentStyle: .orange
                    )
                ],
                featuredCard: .init(
                    subjectId: 3,
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

    static func dashboard(
        from payload: DashboardHomePayload,
        for user: User?,
        date: Date = Date()
    ) -> HomeDashboardContent {
        let name = firstName(from: user)
        let greeting = greetingPrefix(for: date)

        return HomeDashboardContent(
            appTitle: "A/L Revision Companion",
            greetingLine: "\(greeting), \(name).",
            greetingHeadline: "Ready for today's\nsession?",
            continueLearning: continueLearningContent(from: payload.continueLearning),
            todaysFocus: todaysFocusContent(from: payload.todaysFocus),
            quickToolsTitle: "Quick Tools",
            quickTools: quickTools,
            weeklyProgress: weeklyProgressContent(from: payload.weeklyProgress, date: date),
            weakness: weaknessContent(from: payload.weakArea),
            recentSubjectsTitle: "Recent Subjects",
            recentSubjects: recentSubjectsContent(from: payload.recentSubjects, date: date)
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
        var lessonId: Int? = nil
        var topicId: Int? = nil
        var subjectId: Int? = nil
    }

    struct TodaysFocusContent {
        var eyebrow: String
        var timerText: String
        var title: String
        var subtitle: String
        var actionTitle: String
        var topicId: Int? = nil
        var subjectId: Int? = nil
        var priorityScore: Int? = nil
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
        var topicId: Int? = nil
        var subjectId: Int? = nil
    }

    struct RecentSubjectsContent {
        var compactCards: [CompactRecentSubjectContent]
        var featuredCard: FeaturedRecentSubjectContent?

        var isEmpty: Bool {
            compactCards.isEmpty && featuredCard == nil
        }
    }

    struct CompactRecentSubjectContent: Identifiable {
        var id: String
        var subjectId: Int
        var title: String
        var detail: String
        var progress: Double
        var progressText: String
        var icon: String
        var accentStyle: HomeAccentStyle
    }

    struct FeaturedRecentSubjectContent {
        var subjectId: Int
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

    static var quickTools: [QuickToolContent] {
        [
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
        ]
    }

    static func continueLearningContent(
        from item: DashboardContinueLearning?
    ) -> ContinueLearningContent {
        guard let item else {
            return .init(
                eyebrow: "Continue Learning",
                title: "No lesson in progress",
                progress: 0,
                progressText: "0%",
                actionTitle: "Browse Lessons"
            )
        }

        return .init(
            eyebrow: "Continue Learning",
            title: "\(item.subjectName):\n\(item.topicTitle ?? item.lessonTitle)",
            progress: percentageValue(item.progressPercent),
            progressText: "\(clampedPercent(item.progressPercent))%",
            actionTitle: "Resume",
            lessonId: item.lessonId,
            topicId: item.topicId,
            subjectId: item.subjectId
        )
    }

    static func todaysFocusContent(
        from item: DashboardRecommendation?
    ) -> TodaysFocusContent {
        guard let item else {
            return .init(
                eyebrow: "Today's Focus",
                timerText: "READY WHEN YOU ARE",
                title: "No revision\nfocus yet",
                subtitle: "Complete lessons and quizzes to unlock a recommended topic.",
                actionTitle: "Start Revision"
            )
        }

        let subtitle = nonEmpty(item.reason)
            ?? nonEmpty(item.topicSubtitle)
            ?? item.reasons.first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
            ?? "Recommended revision"

        return .init(
            eyebrow: "Today's Focus",
            timerText: "\(item.estimatedMinutes)M REMAINING",
            title: "\(item.subjectName):\n\(item.topicTitle)",
            subtitle: subtitle,
            actionTitle: "Start Revision",
            topicId: item.topicId,
            subjectId: item.subjectId,
            priorityScore: item.priorityScore
        )
    }

    static func weeklyProgressContent(
        from progress: DashboardWeeklyProgress,
        date: Date
    ) -> WeeklyProgressContent {
        let percent = clampedPercent(progress.percent)
        let status = percent >= 100
            ? "GOAL REACHED"
            : "\(progress.activeDays) ACTIVE DAYS"

        return .init(
            eyebrow: "Your Performance",
            title: "Weekly Progress",
            scoreText: "\(percent)%",
            statusText: status,
            days: weeklyDayProgress(percent: percent, activeDays: progress.activeDays, date: date)
        )
    }

    static func weaknessContent(from weakArea: DashboardWeakArea?) -> WeaknessContent {
        guard let weakArea else {
            return .init(
                eyebrow: "Your Weakness",
                statusText: "No Data Yet",
                title: "Take a quiz to reveal weak areas",
                metricLabel: "Accuracy",
                metricValueText: "0%",
                progress: 0,
                note: "Submitted quiz attempts will surface topics that need attention.",
                actionTitle: "Practice now"
            )
        }

        return .init(
            eyebrow: "Your Weakness",
            statusText: weakArea.masteryLevel == "Weak" ? "Needs Attention" : weakArea.masteryLevel,
            title: "\(weakArea.subjectName): \(weakArea.title)",
            metricLabel: "Accuracy",
            metricValueText: "\(clampedPercent(weakArea.averageScore))%",
            progress: percentageValue(weakArea.averageScore),
            note: "Review this topic with focused revision and quiz practice.",
            actionTitle: "Practice now",
            topicId: weakArea.topicId,
            subjectId: weakArea.subjectId
        )
    }

    static func recentSubjectsContent(
        from subjects: [DashboardRecentSubject],
        date: Date
    ) -> RecentSubjectsContent {
        let cards = subjects.prefix(5).map { subject in
            CompactRecentSubjectContent(
                id: "\(subject.subjectId)",
                subjectId: subject.subjectId,
                title: subject.subjectName,
                detail: relativeTimeText(from: subject.lastAccessedAt, to: date),
                progress: 0,
                progressText: "Recent",
                icon: iconName(for: subject),
                accentStyle: accentStyle(for: subject)
            )
        }

        return .init(
            compactCards: Array(cards.prefix(2)),
            featuredCard: cards.dropFirst(2).first.map { card in
                FeaturedRecentSubjectContent(
                    subjectId: card.subjectId,
                    title: card.title,
                    detail: card.detail,
                    icon: card.icon,
                    accentStyle: card.accentStyle,
                    valueText: "\(subjects.count)",
                    trailingLabel: "RECENT"
                )
            }
        )
    }

    static func weeklyDayProgress(
        percent: Int,
        activeDays: Int,
        date: Date
    ) -> [DayProgress] {
        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        let weekday = Calendar.current.component(.weekday, from: date)
        let mondayBasedIndex = (weekday + 5) % 7
        let activeDayCount = min(max(activeDays, 0), labels.count)
        let activeValue = max(0.12, percentageValue(percent))

        return labels.enumerated().map { index, label in
            DayProgress(
                id: "\(index)",
                label: label,
                value: index < activeDayCount ? activeValue : 0,
                isHighlighted: index == mondayBasedIndex
            )
        }
    }

    static func relativeTimeText(from date: Date, to referenceDate: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: referenceDate).uppercased()
    }

    static func iconName(for subject: DashboardRecentSubject) -> String {
        let rawIcon = subject.icon?.lowercased() ?? subject.subjectName.lowercased()

        if rawIcon.contains("chem") || rawIcon.contains("flask") {
            return "drop.fill"
        }

        if rawIcon.contains("phys") || rawIcon.contains("bolt") {
            return "bolt.fill"
        }

        if rawIcon.contains("bio") || rawIcon.contains("leaf") {
            return "leaf.fill"
        }

        if rawIcon.contains("math") || rawIcon.contains("calc") {
            return "sum"
        }

        return "book.closed.fill"
    }

    static func accentStyle(for subject: DashboardRecentSubject) -> HomeAccentStyle {
        let rawValue = "\(subject.subjectName) \(subject.icon ?? "")".lowercased()

        if rawValue.contains("chem") || rawValue.contains("commerce") {
            return .orange
        }

        if rawValue.contains("bio") || rawValue.contains("arts") {
            return .biology
        }

        return .blue
    }

    static func percentageValue(_ percent: Int) -> Double {
        Double(clampedPercent(percent)) / 100.0
    }

    static func clampedPercent(_ percent: Int) -> Int {
        min(max(percent, 0), 100)
    }

    static func nonEmpty(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }
}

extension HomeDashboardContent {
    func applyingLocalRecentSubjects(
        _ subjects: [RecentSubjectEntity],
        date: Date = Date()
    ) -> HomeDashboardContent {
        var updated = self
        updated.recentSubjects = Self.localRecentSubjectsContent(from: subjects, date: date)
        return updated
    }

    static func localRecentSubjectsContent(
        from subjects: [RecentSubjectEntity],
        date: Date = Date()
    ) -> RecentSubjectsContent {
        let cards = subjects.prefix(5).enumerated().map { index, subject in
            CompactRecentSubjectContent(
                id: "local-\(subject.subjectId)-\(index)",
                subjectId: subject.subjectId,
                title: subject.subjectName,
                detail: relativeRecentSubjectText(from: subject.lastOpenedAt, now: date),
                progress: 0,
                progressText: "RECENT",
                icon: subject.icon ?? "book.fill",
                accentStyle: accentStyle(for: subject)
            )
        }

        return .init(compactCards: cards, featuredCard: nil)
    }

    private static func accentStyle(for subject: RecentSubjectEntity) -> HomeAccentStyle {
        let icon = subject.icon?.lowercased() ?? ""
        let name = subject.subjectName.lowercased()

        if icon.contains("leaf") || name.contains("bio") {
            return .biology
        }

        if icon.contains("flask") || name.contains("chem") {
            return .orange
        }

        return .blue
    }

    private static func relativeRecentSubjectText(from date: Date, now: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: now).uppercased()
    }
}
