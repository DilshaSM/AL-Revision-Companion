import Foundation
import SwiftData

@Model
final class RecentSubjectEntity {
    @Attribute(.unique) var subjectId: Int

    var subjectName: String
    var icon: String?
    var color: String?
    var lastOpenedAt: Date

    init(
        subjectId: Int,
        subjectName: String,
        icon: String? = nil,
        color: String? = nil,
        lastOpenedAt: Date = .now
    ) {
        self.subjectId = subjectId
        self.subjectName = subjectName
        self.icon = icon
        self.color = color
        self.lastOpenedAt = lastOpenedAt
    }
}
