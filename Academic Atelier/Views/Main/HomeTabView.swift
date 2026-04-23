import SwiftUI

struct HomeTabView: View {
    @State private var path: [HomeTabRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                actions: .init(
                    onTapWeeklyProgress: handleWeeklyProgressTap,
                    onTapQuickTool: handleQuickToolTap
                )
            )
            .navigationDestination(for: HomeTabRoute.self) { destination in
                switch destination {
                case .quickRevision:
                    QuickRevisionView(
                        actions: .init(
                            onTapStudyMaterial: handleStudyMaterialTap
                        )
                    )
                case .recallTools:
                    RecallToolsView(
                        actions: .init(
                            onTapFlashcards: handleFlashcardsTap,
                            onTapAudioNotes: handleAudioNotesTap,
                            onTapRecentItem: handleRecallToolsRecentItemTap
                        )
                    )
                case .flashcardsTopicSelection:
                    FlashcardsTopicSelectionView(
                        actions: .init(
                            onTapTopic: handleFlashcardsTopicTap,
                            onTapRecentTopic: handleFlashcardsRecentTap
                        )
                    )
                case .audioNotesTopicSelection:
                    AudioNotesTopicSelectionView(
                        actions: .init(
                            onTapTopic: handleAudioNotesTopicTap,
                            onTapRecentAudioNote: handleAudioNotesRecentTap
                        )
                    )
                case let .audioNotesDetail(content):
                    AudioNotesDetailView(content: content)
                case let .topicSelection(subject):
                    QuickRevisionTopicSelectionView(
                        subject: subject,
                        actions: .init(
                            onTapTopic: handleTopicTap,
                            onTapRecentTopic: { handleRecentTopicTap($0, in: subject) }
                        )
                    )
                case let .topicContent(topic):
                    QuickRevisionContentView(topic: topic)
                case let .flashcardsSession(content):
                    FlashcardsSessionView(content: content)
                case .progressInsights:
                    ProgressTabView(
                        actions: .init(
                            onTapSubjectMastery: handleProgressSubjectTap
                        )
                    )
                case let .progressRecommendations(content):
                    RecommendationsView(content: content)
                }
            }
        }
    }

    private func handleQuickToolTap(_ tool: HomeDashboardContent.QuickToolContent) {
        guard let destination = tool.destination else { return }

        switch destination {
        case .quickRevision:
            path.append(.quickRevision)
        case .recallTools:
            path.append(.recallTools)
        }
    }

    private func handleWeeklyProgressTap() {
        path.append(.progressInsights)
    }

    private func handleProgressSubjectTap(_ subjectMastery: ProgressTabContent.SubjectMastery) {
        guard let content = ProgressTabContent.placeholder.recommendationsContent(for: subjectMastery) else { return }
        path.append(.progressRecommendations(content))
    }

    private func handleStudyMaterialTap(_ subject: QuickRevisionSubject) {
        path.append(.topicSelection(subject))
    }

    private func handleTopicTap(_ topic: QuickRevisionSubject.Topic) {
        path.append(.topicContent(topic))
    }

    private func handleRecentTopicTap(_ recentTopic: QuickRevisionSubject.RecentTopic, in subject: QuickRevisionSubject) {
        guard let topic = subject.topic(withID: recentTopic.id) else { return }
        path.append(.topicContent(topic))
    }

    private func handleFlashcardsTap() {
        path.append(.flashcardsTopicSelection)
    }

    private func handleAudioNotesTap() {
        path.append(.audioNotesTopicSelection)
    }

    private func handleRecallToolsRecentItemTap(_ item: RecallToolsContent.RecentItem) {
        switch item.accent {
        case .blue:
            handleFlashcardsTap()
        case .orange:
            handleAudioNotesTap()
        }
    }

    private func handleFlashcardsTopicTap(_ topic: FlashcardsTopicSelectionContent.Topic) {
        guard let content = FlashcardsTopicSelectionContent.placeholder.sessionContent(for: topic) else { return }
        path.append(.flashcardsSession(content))
    }

    private func handleFlashcardsRecentTap(_ recentTopic: FlashcardsTopicSelectionContent.RecentTopic) {
        guard let content = FlashcardsTopicSelectionContent.placeholder.sessionContent(for: recentTopic) else { return }
        path.append(.flashcardsSession(content))
    }

    private func handleAudioNotesTopicTap(_ topic: AudioNotesTopicSelectionContent.Topic) {
        guard let content = AudioNotesTopicSelectionContent.placeholder.detailContent(for: topic) else { return }
        path.append(.audioNotesDetail(content))
    }

    private func handleAudioNotesRecentTap(_ recentAudioNote: AudioNotesTopicSelectionContent.RecentAudioNote) {
        guard let content = AudioNotesTopicSelectionContent.placeholder.detailContent(for: recentAudioNote) else { return }
        path.append(.audioNotesDetail(content))
    }
}

private enum HomeTabRoute: Hashable {
    case quickRevision
    case recallTools
    case flashcardsTopicSelection
    case audioNotesTopicSelection
    case audioNotesDetail(AudioNotesDetailContent)
    case flashcardsSession(FlashcardsSessionContent)
    case topicSelection(QuickRevisionSubject)
    case topicContent(QuickRevisionSubject.Topic)
    case progressInsights
    case progressRecommendations(RecommendationsContent)
}
