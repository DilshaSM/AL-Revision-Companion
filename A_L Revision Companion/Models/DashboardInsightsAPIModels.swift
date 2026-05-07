import Foundation

struct DashboardProgressPayload: Decodable {
    let weeklyEngagement: [DashboardProgressDay]
    let focusTimeMinutes: Int
    let chaptersCompleted: Int
    let subjectMastery: [DashboardSubjectMastery]
}

struct DashboardProgressDay: Decodable, Hashable {
    let day: String
    let minutes: Int
}

struct DashboardSubjectMastery: Decodable, Hashable {
    let subjectId: Int
    let subjectName: String
    let masteryPercent: Int
    let progressPercent: Int
}

struct DashboardRecommendationsPayload: Decodable {
    let recommendations: [DashboardRecommendation]
}
