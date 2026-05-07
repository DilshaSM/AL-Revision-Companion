import Foundation
import SwiftData

@MainActor
final class LocalPersistenceService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Widget Summary

    func saveWidgetSummary(_ summary: WidgetSummaryEntity) throws {
        let descriptor = FetchDescriptor<WidgetSummaryEntity>(
            predicate: #Predicate { $0.id == "latest" }
        )

        let existing = try context.fetch(descriptor).first

        if let existing {
            existing.continueTitle = summary.continueTitle
            existing.continueSubtitle = summary.continueSubtitle
            existing.continueProgressPercent = summary.continueProgressPercent
            existing.continueLessonId = summary.continueLessonId
            existing.continueTopicId = summary.continueTopicId
            existing.continueSubjectId = summary.continueSubjectId

            existing.focusTitle = summary.focusTitle
            existing.focusSubtitle = summary.focusSubtitle
            existing.focusTopicId = summary.focusTopicId
            existing.focusSubjectId = summary.focusSubjectId

            existing.weeklyGoalPercent = summary.weeklyGoalPercent
            existing.focusTimeMinutes = summary.focusTimeMinutes
            existing.activeDays = summary.activeDays
            existing.chaptersCompleted = summary.chaptersCompleted
            existing.updatedAt = summary.updatedAt
        } else {
            context.insert(summary)
        }

        try context.save()
    }

    func loadWidgetSummary() throws -> WidgetSummaryEntity? {
        var descriptor = FetchDescriptor<WidgetSummaryEntity>(
            predicate: #Predicate { $0.id == "latest" }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    // MARK: - Recent Study Activity

    func saveStudyActivity(
        activityType: String,
        subjectId: Int? = nil,
        subjectName: String? = nil,
        topicId: Int? = nil,
        topicTitle: String? = nil,
        durationMinutes: Int? = nil
    ) throws {
        let activity = RecentStudyActivityEntity(
            activityType: activityType,
            subjectId: subjectId,
            subjectName: subjectName,
            topicId: topicId,
            topicTitle: topicTitle,
            durationMinutes: durationMinutes,
            timestamp: .now
        )

        context.insert(activity)
        try context.save()
        try trimRecentActivities(limit: 30)
    }

    func loadRecentActivities(limit: Int = 10) throws -> [RecentStudyActivityEntity] {
        var descriptor = FetchDescriptor<RecentStudyActivityEntity>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    private func trimRecentActivities(limit: Int) throws {
        let all = try context.fetch(
            FetchDescriptor<RecentStudyActivityEntity>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        )

        guard all.count > limit else { return }

        for item in all.dropFirst(limit) {
            context.delete(item)
        }

        try context.save()
    }

    // MARK: - Audio Progress

    func saveAudioProgress(
        audioNoteId: Int,
        title: String,
        lastPositionSeconds: Int,
        durationSeconds: Int,
        playbackSpeed: Double,
        isCompleted: Bool,
        needsSync: Bool
    ) throws {
        let descriptor = FetchDescriptor<AudioProgressEntity>(
            predicate: #Predicate { $0.audioNoteId == audioNoteId }
        )

        if let existing = try context.fetch(descriptor).first {
            existing.title = title
            existing.lastPositionSeconds = lastPositionSeconds
            existing.durationSeconds = durationSeconds
            existing.playbackSpeed = playbackSpeed
            existing.lastPlayedAt = .now
            existing.isCompleted = isCompleted
            existing.needsSync = needsSync
        } else {
            let progress = AudioProgressEntity(
                audioNoteId: audioNoteId,
                title: title,
                lastPositionSeconds: lastPositionSeconds,
                durationSeconds: durationSeconds,
                playbackSpeed: playbackSpeed,
                lastPlayedAt: .now,
                isCompleted: isCompleted,
                needsSync: needsSync
            )
            context.insert(progress)
        }

        try context.save()
    }

    func loadAudioProgress(audioNoteId: Int) throws -> AudioProgressEntity? {
        var descriptor = FetchDescriptor<AudioProgressEntity>(
            predicate: #Predicate { $0.audioNoteId == audioNoteId }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func loadUnsyncedAudioProgress() throws -> [AudioProgressEntity] {
        let descriptor = FetchDescriptor<AudioProgressEntity>(
            predicate: #Predicate { $0.needsSync == true },
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func markAudioProgressSynced(audioNoteId: Int) throws {
        guard let item = try loadAudioProgress(audioNoteId: audioNoteId) else { return }
        item.needsSync = false
        try context.save()
    }

    // MARK: - Recent Subjects

    func saveRecentSubject(
        subjectId: Int,
        subjectName: String,
        icon: String? = nil,
        color: String? = nil
    ) throws {
        let descriptor = FetchDescriptor<RecentSubjectEntity>(
            predicate: #Predicate { $0.subjectId == subjectId }
        )

        if let existing = try context.fetch(descriptor).first {
            existing.subjectName = subjectName
            existing.icon = icon
            existing.color = color
            existing.lastOpenedAt = .now
        } else {
            context.insert(
                RecentSubjectEntity(
                    subjectId: subjectId,
                    subjectName: subjectName,
                    icon: icon,
                    color: color,
                    lastOpenedAt: .now
                )
            )
        }

        try context.save()
        try trimRecentSubjects(limit: 8)
    }

    func loadRecentSubjects(limit: Int = 5) throws -> [RecentSubjectEntity] {
        var descriptor = FetchDescriptor<RecentSubjectEntity>(
            sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    private func trimRecentSubjects(limit: Int) throws {
        let all = try context.fetch(
            FetchDescriptor<RecentSubjectEntity>(
                sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)]
            )
        )

        guard all.count > limit else { return }

        for item in all.dropFirst(limit) {
            context.delete(item)
        }

        try context.save()
    }

    // MARK: - Clear User Data

    func clearUserSpecificData() throws {
        try deleteAll(WidgetSummaryEntity.self)
        try deleteAll(RecentStudyActivityEntity.self)
        try deleteAll(AudioProgressEntity.self)
        try deleteAll(RecentSubjectEntity.self)
        try context.save()
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let records = try context.fetch(descriptor)

        for record in records {
            context.delete(record)
        }
    }
}
