import Foundation

struct ProgressTabContent: Hashable {
    var title: String
    var subtitle: String
    var emptyStateMessage: String
    var weeklyEngagement: WeeklyEngagement
    var subjectMasteryTitle: String
    var subjectMasterySubtitle: String
    var subjectMasteries: [SubjectMastery]

    static func build(
        progress: DashboardProgressPayload,
        subjects: [APISubject]
    ) -> ProgressTabContent {
        let subjectMap = Dictionary(uniqueKeysWithValues: subjects.map { ($0.id, $0) })
        let mergedMasteries = mergeSubjectMastery(
            progress.subjectMastery,
            with: subjects
        )

        return ProgressTabContent(
            title: "Revision Insights",
            subtitle: "Track your weekly focus time and lesson completion across every subject in your stream.",
            emptyStateMessage: "Start a lesson and complete a quiz to see your progress.",
            weeklyEngagement: .init(
                eyebrow: "Activity Tracking",
                title: "Weekly Engagement",
                days: progress.weeklyEngagement.map { day in
                    WeeklyDay(
                        id: day.day.lowercased(),
                        shortLabel: day.day.uppercased(),
                        minuteLabel: "\(max(day.minutes, 0))m",
                        minutes: max(day.minutes, 0),
                        barHeight: barHeight(for: day.minutes, maxMinutes: progress.weeklyEngagement.map(\.minutes).max() ?? 0),
                        isHighlighted: day.minutes == progress.weeklyEngagement.map(\.minutes).max() && day.minutes > 0
                    )
                },
                statCards: [
                    .init(
                        id: "focus-time",
                        iconName: "timer",
                        title: "Focus Time",
                        valueText: durationText(minutes: progress.focusTimeMinutes)
                    ),
                    .init(
                        id: "chapters",
                        iconName: "book.closed",
                        title: "Lessons Completed",
                        valueText: "\(max(progress.chaptersCompleted, 0))"
                    )
                ]
            ),
            subjectMasteryTitle: "Subject Mastery",
            subjectMasterySubtitle: "Quiz mastery and lesson progress for your current stream",
            subjectMasteries: mergedMasteries.map { mastery in
                SubjectMastery(
                    subjectID: mastery.subjectId,
                    title: mastery.subjectName,
                    subtitle: masterySubtitle(
                        masteryPercent: mastery.masteryPercent,
                        progressPercent: mastery.progressPercent
                    ),
                    masteryPercent: clampedPercent(mastery.masteryPercent),
                    masteryText: "\(clampedPercent(mastery.masteryPercent))%",
                    progress: Double(clampedPercent(mastery.progressPercent)) / 100.0,
                    progressText: "\(clampedPercent(mastery.progressPercent))%",
                    iconName: iconName(for: subjectMap[mastery.subjectId]?.icon, subjectName: mastery.subjectName),
                    accentStyle: clampedPercent(mastery.masteryPercent) >= 60 ? .brand : .muted
                )
            }
        )
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
        var minuteLabel: String
        var minutes: Int
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

        var id: Int { subjectID }
        var subjectID: Int
        var title: String
        var subtitle: String
        var masteryPercent: Int
        var masteryText: String
        var progress: Double
        var progressText: String
        var iconName: String
        var accentStyle: AccentStyle
    }
}

private extension ProgressTabContent {
    static func mergeSubjectMastery(
        _ masteryRows: [DashboardSubjectMastery],
        with subjects: [APISubject]
    ) -> [DashboardSubjectMastery] {
        var merged = masteryRows
        let existingIDs = Set(masteryRows.map(\.subjectId))

        let missing = subjects
            .sorted { $0.orderIndex < $1.orderIndex }
            .filter { !existingIDs.contains($0.id) }
            .map {
                DashboardSubjectMastery(
                    subjectId: $0.id,
                    subjectName: $0.displayName,
                    masteryPercent: 0,
                    progressPercent: 0
                )
            }

        merged.append(contentsOf: missing)
        return merged
    }

    static func masterySubtitle(
        masteryPercent: Int,
        progressPercent: Int
    ) -> String {
        "Quiz mastery \(clampedPercent(masteryPercent))% • Lesson progress \(clampedPercent(progressPercent))%"
    }

    static func durationText(minutes: Int) -> String {
        let safeMinutes = max(minutes, 0)
        if safeMinutes >= 60 {
            let hours = safeMinutes / 60
            let remainder = safeMinutes % 60
            if remainder == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(remainder)m"
        }
        return "\(safeMinutes)m"
    }

    static func barHeight(for minutes: Int, maxMinutes: Int) -> Double {
        let safeMinutes = max(minutes, 0)
        let safeMax = max(maxMinutes, 0)
        guard safeMax > 0 else { return 16 }
        let normalized = Double(safeMinutes) / Double(safeMax)
        return max(16, normalized * 120)
    }

    static func clampedPercent(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }

    static func iconName(for backendIcon: String?, subjectName: String) -> String {
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
            switch subjectName.lowercased() {
            case let name where name.contains("chem"):
                return "flask.fill"
            case let name where name.contains("phys"):
                return "atom"
            case let name where name.contains("bio"):
                return "leaf.fill"
            case let name where name.contains("math"):
                return "function"
            default:
                return "book.closed.fill"
            }
        }
    }
}
