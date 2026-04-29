import SwiftUI

struct FlashcardsTopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel

    @StateObject private var viewModel = FlashcardsTopicSelectionViewModel()

    private let actions: FlashcardsTopicSelectionActions

    init(actions: FlashcardsTopicSelectionActions = .init()) {
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    statusSection
                    availableTopicsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await load(forceRefresh: false)
        }
        .refreshable {
            await load(forceRefresh: true)
        }
    }
}

private extension FlashcardsTopicSelectionView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)
        }
        .frame(height: 96)
        .overlay(alignment: .leading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .padding(.leading, 24)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.content?.title ?? "Flashcards")
                .font(AppTypography.flashcardsTopicSelectionTitle)
                .tracking(-1.1)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(viewModel.content?.subtitle ?? "Choose a topic to start a quick recall session.")
                .font(AppTypography.flashcardsTopicSelectionSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading flashcard decks...")
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            }
        } else if !viewModel.errorMessage.isEmpty && viewModel.content == nil {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)

                Button("Retry") {
                    Task {
                        await load(forceRefresh: true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(QuickRevisionPalette.brand)
            }
        } else if !viewModel.errorMessage.isEmpty {
            Text(viewModel.errorMessage)
                .font(.footnote)
                .foregroundStyle(SubjectsPalette.resultIncorrect)
        } else if viewModel.isLoading {
            Text("Refreshing flashcard decks...")
                .font(.footnote)
                .foregroundStyle(QuickRevisionPalette.muted)
        }
    }

    var availableTopicsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text((viewModel.content?.availableTopicsTitle ?? "Available Topics").uppercased())
                .font(AppTypography.flashcardsTopicSelectionSectionLabel)
                .tracking(2.0)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            if let content = viewModel.content, content.availableTopics.isEmpty {
                Text(content.emptyStateMessage)
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            } else if let content = viewModel.content {
                VStack(spacing: 20) {
                    ForEach(content.availableTopics) { topic in
                        FlashcardsTopicRow(
                            topic: topic,
                            isStarting: viewModel.startingDeckID == topic.id && viewModel.isStartingDeck
                        ) {
                            Task {
                                if let sessionContent = await viewModel.startSession(for: topic) {
                                    actions.onStartSession(sessionContent)
                                } else if viewModel.requiresSignOut {
                                    session.signOut()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func load(forceRefresh: Bool) async {
        await viewModel.load(forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }
}

struct FlashcardsTopicSelectionActions {
    var onStartSession: (FlashcardsSessionContent) -> Void = { _ in }
}

private struct FlashcardsTopicRow: View {
    let topic: FlashcardsTopicSelectionContent.Deck
    let isStarting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(QuickRevisionPalette.iconBackground)
                        .frame(width: 84, height: 84)

                    if isStarting {
                        ProgressView()
                            .tint(QuickRevisionPalette.brand)
                    } else {
                        Image(systemName: topic.symbolName)
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(QuickRevisionPalette.brand)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(topic.title)
                        .font(AppTypography.flashcardsTopicSelectionRowTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(topic.detailText)
                        .font(AppTypography.flashcardsTopicSelectionRowDetail)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let description = topic.description, !description.isEmpty {
                        Text(description)
                            .font(AppTypography.flashcardsTopicSelectionRecentDetail)
                            .foregroundStyle(QuickRevisionPalette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isStarting)
    }
}
