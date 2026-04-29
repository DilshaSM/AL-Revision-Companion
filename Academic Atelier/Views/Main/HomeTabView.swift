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
                            onTapAudioNotes: handleAudioNotesTap
                        )
                    )
                case .flashcardsTopicSelection:
                    FlashcardsTopicSelectionView(
                        actions: .init(
                            onStartSession: handleFlashcardsSessionStart
                        )
                    )
                case .audioNotesTopicSelection:
                    AudioNotesTopicSelectionView(
                        actions: .init(
                            onTapNote: handleAudioNoteTap
                        )
                    )
                case let .audioNotesDetail(note):
                    AudioNotesDetailView(note: note)
                case let .topicSelection(subject):
                    QuickRevisionTopicSelectionView(
                        subject: subject,
                        actions: .init(
                            onTapTopic: handleTopicTap
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
                case let .progressRecommendations(subject):
                    RecommendationsView(preferredSubject: subject)
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
        path.append(.progressRecommendations(subjectMastery))
    }

    private func handleStudyMaterialTap(_ subject: QuickRevisionSubject) {
        path.append(.topicSelection(subject))
    }

    private func handleTopicTap(_ topic: QuickRevisionTopic) {
        path.append(.topicContent(topic))
    }

    private func handleFlashcardsTap() {
        path.append(.flashcardsTopicSelection)
    }

    private func handleAudioNotesTap() {
        path.append(.audioNotesTopicSelection)
    }

    private func handleFlashcardsSessionStart(_ content: FlashcardsSessionContent) {
        path.append(.flashcardsSession(content))
    }

    private func handleAudioNoteTap(_ note: AudioNotesTopicSelectionContent.Note) {
        path.append(.audioNotesDetail(note))
    }
}

private enum HomeTabRoute: Hashable {
    case quickRevision
    case recallTools
    case flashcardsTopicSelection
    case audioNotesTopicSelection
    case audioNotesDetail(AudioNotesTopicSelectionContent.Note)
    case flashcardsSession(FlashcardsSessionContent)
    case topicSelection(QuickRevisionSubject)
    case topicContent(QuickRevisionTopic)
    case progressInsights
    case progressRecommendations(ProgressTabContent.SubjectMastery)
}
