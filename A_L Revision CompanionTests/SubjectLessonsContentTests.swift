import Foundation
import Testing
@testable import AL_Revision_Companion

struct SubjectLessonsContentTests {

    @Test
    func buildSortsUnitsLessonsAndComputesCurrentProgress() {
        let subject = APISubjectTree(
            id: 10,
            name: "physics",
            displayName: "Physics",
            icon: "atom",
            color: "#123456",
            units: [
                APISubjectUnit(
                    id: 2,
                    title: "Unit B",
                    description: nil,
                    orderIndex: 2,
                    lessons: [
                        APISubjectLesson(
                            id: 22,
                            title: "Lesson 2",
                            description: nil,
                            estimatedDurationMinutes: 20,
                            orderIndex: 2,
                            isLockedByDefault: false,
                            topics: [
                                APISubjectTopic(
                                    id: 222,
                                    title: "Topic 2",
                                    subtitle: nil,
                                    estimatedDurationMinutes: 10,
                                    orderIndex: 2,
                                    isActive: true
                                )
                            ],
                            status: "NOT_STARTED",
                            progressPercent: 0,
                            isLocked: false
                        )
                    ]
                ),
                APISubjectUnit(
                    id: 1,
                    title: "Unit A",
                    description: nil,
                    orderIndex: 1,
                    lessons: [
                        APISubjectLesson(
                            id: 12,
                            title: "Lesson 1B",
                            description: nil,
                            estimatedDurationMinutes: 15,
                            orderIndex: 2,
                            isLockedByDefault: false,
                            topics: [
                                APISubjectTopic(
                                    id: 122,
                                    title: "Topic 1B",
                                    subtitle: nil,
                                    estimatedDurationMinutes: 10,
                                    orderIndex: 2,
                                    isActive: true
                                )
                            ],
                            status: "IN_PROGRESS",
                            progressPercent: 40,
                            isLocked: false
                        ),
                        APISubjectLesson(
                            id: 11,
                            title: "Lesson 1A",
                            description: nil,
                            estimatedDurationMinutes: 15,
                            orderIndex: 1,
                            isLockedByDefault: false,
                            topics: [
                                APISubjectTopic(
                                    id: 121,
                                    title: "Topic 1A",
                                    subtitle: nil,
                                    estimatedDurationMinutes: 10,
                                    orderIndex: 1,
                                    isActive: true
                                )
                            ],
                            status: "COMPLETED",
                            progressPercent: 100,
                            isLocked: false
                        )
                    ]
                )
            ]
        )

        let content = SubjectLessonsContent.build(from: subject)

        #expect(content.units.map(\.title) == ["Unit A", "Unit B"])
        #expect(content.units[0].lessons.map(\.title) == ["Lesson 1A", "Lesson 1B"])
        #expect(content.hero.currentLessonTitle == "Lesson 1B")
        #expect(content.hero.progressText == "33%")
        #expect(content.hero.backgroundSymbolName == "atom")
    }

    @Test
    func lessonStateReflectsLockedCompletedInProgressAndAvailable() {
        let lockedLesson = makeLesson(
            id: 1,
            title: "Locked",
            estimatedDurationMinutes: 10,
            status: "NOT_STARTED",
            progressPercent: 0,
            isLocked: true,
            topics: []
        )
        let completedLesson = makeLesson(
            id: 2,
            title: "Completed",
            estimatedDurationMinutes: 12,
            status: "COMPLETED",
            progressPercent: 100,
            isLocked: false,
            topics: []
        )
        let inProgressLesson = makeLesson(
            id: 3,
            title: "In Progress",
            estimatedDurationMinutes: 12,
            status: "IN_PROGRESS",
            progressPercent: 45,
            isLocked: false,
            topics: []
        )
        let availableLesson = makeLesson(
            id: 4,
            title: "Available",
            estimatedDurationMinutes: 8,
            status: "NOT_STARTED",
            progressPercent: 0,
            isLocked: false,
            topics: [
                makeTopic(id: 41, title: "Active Topic", estimatedDurationMinutes: 8, orderIndex: 1, isActive: true)
            ]
        )

        if case let .locked(detailText) = lockedLesson.state {
            #expect(detailText.contains("unlock"))
        } else {
            Issue.record("Expected locked state")
        }

        if case let .completed(detailText) = completedLesson.state {
            #expect(detailText.contains("Completed"))
        } else {
            Issue.record("Expected completed state")
        }

        if case let .inProgress(progress, progressText) = inProgressLesson.state {
            #expect(progress == 0.45)
            #expect(progressText == "45% done")
        } else {
            Issue.record("Expected in-progress state")
        }

        if case let .available(detailText) = availableLesson.state {
            #expect(detailText == "8 mins")
        } else {
            Issue.record("Expected available state")
        }
    }

    @Test
    func applyingProgressUnlocksLessonAndUpdatesHero() {
        let content = SubjectLessonsContent.build(
            from: APISubjectTree(
                id: 1,
                name: "chemistry",
                displayName: "Chemistry",
                icon: "flask",
                color: nil,
                units: [
                    APISubjectUnit(
                        id: 1,
                        title: "Unit 1",
                        description: nil,
                        orderIndex: 1,
                        lessons: [
                            makeAPILesson(
                                id: 1,
                                title: "Lesson 1",
                                estimatedDurationMinutes: 12,
                                orderIndex: 1,
                                topics: [makeTopic(id: 10, title: "Topic 1", estimatedDurationMinutes: nil, orderIndex: 1, isActive: true)],
                                status: "NOT_STARTED",
                                progressPercent: 0,
                                isLocked: false
                            ),
                            makeAPILesson(
                                id: 2,
                                title: "Lesson 2",
                                estimatedDurationMinutes: 15,
                                orderIndex: 2,
                                topics: [makeTopic(id: 20, title: "Topic 2", estimatedDurationMinutes: nil, orderIndex: 1, isActive: true)],
                                status: "LOCKED",
                                progressPercent: 0,
                                isLocked: true
                            )
                        ]
                    )
                ]
            )
        )

        let updated = content.applying(
            progress: UserLessonProgress(
                lessonId: 2,
                status: "IN_PROGRESS",
                progressPercent: 60,
                lastAccessedAt: nil
            )
        )

        #expect(updated.units[0].lessons[1].isLocked == false)
        #expect(updated.units[0].lessons[1].progressPercent == 60)
        #expect(updated.hero.currentLessonTitle == "Lesson 2")
    }
}

private extension SubjectLessonsContentTests {
    func makeLesson(
        id: Int,
        title: String,
        estimatedDurationMinutes: Int?,
        status: String,
        progressPercent: Int,
        isLocked: Bool,
        topics: [APISubjectTopic]
    ) -> SubjectLessonsContent.Lesson {
        SubjectLessonsContent.Lesson(
            apiLesson: makeAPILesson(
                id: id,
                title: title,
                estimatedDurationMinutes: estimatedDurationMinutes,
                orderIndex: id,
                topics: topics,
                status: status,
                progressPercent: progressPercent,
                isLocked: isLocked
            )
        )
    }

    func makeAPILesson(
        id: Int,
        title: String,
        estimatedDurationMinutes: Int?,
        orderIndex: Int,
        topics: [APISubjectTopic],
        status: String,
        progressPercent: Int,
        isLocked: Bool
    ) -> APISubjectLesson {
        APISubjectLesson(
            id: id,
            title: title,
            description: nil,
            estimatedDurationMinutes: estimatedDurationMinutes,
            orderIndex: orderIndex,
            isLockedByDefault: isLocked,
            topics: topics,
            status: status,
            progressPercent: progressPercent,
            isLocked: isLocked
        )
    }

    func makeTopic(
        id: Int,
        title: String,
        estimatedDurationMinutes: Int?,
        orderIndex: Int,
        isActive: Bool
    ) -> APISubjectTopic {
        APISubjectTopic(
            id: id,
            title: title,
            subtitle: nil,
            estimatedDurationMinutes: estimatedDurationMinutes,
            orderIndex: orderIndex,
            isActive: isActive
        )
    }
}
