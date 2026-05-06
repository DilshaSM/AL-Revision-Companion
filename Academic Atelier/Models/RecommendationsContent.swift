import Foundation

struct RecommendationsContent: Hashable {
    var preferredSubjectID: Int?
    var eyebrow: String
    var title: String
    var summary: String
    var overview: Overview
    var sectionTitle: String
    var sectionActionTitle: String
    var emptyStateTitle: String
    var emptyStateMessage: String
    var pathways: [Pathway]

    static func build(
        recommendations: [DashboardRecommendation],
        preferredSubject: ProgressTabContent.SubjectMastery?
    ) -> RecommendationsContent {
        let filteredRecommendations: [DashboardRecommendation]
        if let preferredSubject,
           recommendations.contains(where: { $0.subjectId == preferredSubject.subjectID }) {
            filteredRecommendations = recommendations.filter { $0.subjectId == preferredSubject.subjectID }
        } else {
            filteredRecommendations = recommendations
        }

        let title: String
        let summary: String
        if let preferredSubject {
            title = "Focus on\n\(preferredSubject.title)"
            if filteredRecommendations.isEmpty {
                summary = "There are no subject-specific recommendations yet. Complete a quiz to receive personalized study guidance."
            } else {
                summary = "These recommendations are prioritized for \(preferredSubject.title) based on your latest activity and quiz performance."
            }
        } else {
            title = "Study\nRecommendations"
            summary = filteredRecommendations.isEmpty
                ? "Complete a quiz to receive personalized study recommendations."
                : "Your next best study topics are ranked from recent lesson activity and quiz performance."
        }

        return RecommendationsContent(
            preferredSubjectID: preferredSubject?.subjectID,
            eyebrow: "Performance Analysis",
            title: title,
            summary: summary,
            overview: .init(
                title: "Recommended Topics",
                scoreText: "\(filteredRecommendations.count)",
                scoreValue: min(max(Double(filteredRecommendations.count) / 3.0, 0), 1),
                message: filteredRecommendations.isEmpty
                    ? "No recommendation signals yet."
                    : "Ordered by backend priority score."
            ),
            sectionTitle: "Priority Pathways",
            sectionActionTitle: "Sorted by Impact",
            emptyStateTitle: "No Recommendations Yet",
            emptyStateMessage: "Complete a quiz to receive personalized study recommendations.",
            pathways: filteredRecommendations.enumerated().map { index, recommendation in
                Pathway(
                    id: "\(recommendation.topicId)-\(index)",
                    priority: index == 0 ? .critical : .medium,
                    title: recommendation.topicTitle,
                    subjectLine: recommendation.subjectName,
                    summary: recommendation.reason,
                    primaryActionTitle: "Start Revision",
                    durationText: "\(max(recommendation.estimatedMinutes, 0)) MIN",
                    scoreText: "Priority \(recommendation.priorityScore)",
                    subjectId: recommendation.subjectId,
                    topicId: recommendation.topicId
                )
            }
        )
    }
}

extension RecommendationsContent {
    struct Overview: Hashable {
        var title: String
        var scoreText: String
        var scoreValue: Double
        var message: String
    }

    struct Pathway: Identifiable, Hashable {
        enum Priority: String, Hashable {
            case critical
            case medium

            var label: String {
                switch self {
                case .critical:
                    return "Top Recommendation"
                case .medium:
                    return "Recommended Next"
                }
            }
        }

        var id: String
        var priority: Priority
        var title: String
        var subjectLine: String
        var summary: String
        var primaryActionTitle: String? = nil
        var durationText: String? = nil
        var scoreText: String? = nil
        var subjectId: Int? = nil
        var topicId: Int? = nil
    }
}
