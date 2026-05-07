import Foundation
import SwiftData

@Model
final class RecentStudyActivityEntity {
    var activityType: String

    var subjectId: Int?
    var subjectName: String?

    var topicId: Int?
    var topicTitle: String?

    var durationMinutes: Int?
    var timestamp: Date

    init(
        activityType: String,
        subjectId: Int? = nil,
        subjectName: String? = nil,
        topicId: Int? = nil,
        topicTitle: String? = nil,
        durationMinutes: Int? = nil,
        timestamp: Date = .now
    ) {
        self.activityType = activityType
        self.subjectId = subjectId
        self.subjectName = subjectName
        self.topicId = topicId
        self.topicTitle = topicTitle
        self.durationMinutes = durationMinutes
        self.timestamp = timestamp
    }
}
