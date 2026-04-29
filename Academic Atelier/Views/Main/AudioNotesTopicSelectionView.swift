import SwiftUI

struct AudioNotesTopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel

    @StateObject private var viewModel = AudioNotesTopicSelectionViewModel()

    private let actions: AudioNotesTopicSelectionActions

    init(actions: AudioNotesTopicSelectionActions = .init()) {
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    statusSection
                        .padding(.top, 20)
                    availableTopicsSection
                        .padding(.top, 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)
                .padding(.bottom, 56)
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

private extension AudioNotesTopicSelectionView {
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
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.content?.title ?? "Audio Notes")
                .font(AppTypography.audioNotesTopicSelectionTitle)
                .tracking(-0.9)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(viewModel.content?.subtitle ?? "Choose a topic to start an audio revision session.")
                .font(AppTypography.audioNotesTopicSelectionSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading audio notes...")
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
            Text("Refreshing audio notes...")
                .font(.footnote)
                .foregroundStyle(QuickRevisionPalette.muted)
        }
    }

    var availableTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text((viewModel.content?.availableTopicsTitle ?? "Available Notes").uppercased())
                .font(AppTypography.audioNotesTopicSelectionSectionLabel)
                .tracking(1.6)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            if let content = viewModel.content, content.availableTopics.isEmpty {
                Text(content.emptyStateMessage)
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            } else if let content = viewModel.content {
                VStack(spacing: 12) {
                    ForEach(content.availableTopics) { topic in
                        AudioNotesTopicRow(topic: topic) {
                            actions.onTapNote(topic)
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

struct AudioNotesTopicSelectionActions {
    var onTapNote: (AudioNotesTopicSelectionContent.Note) -> Void = { _ in }
}

private struct AudioNotesTopicRow: View {
    let topic: AudioNotesTopicSelectionContent.Note
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AudioNotesPalette.iconBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AudioNotesPalette.iconAccent)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(topic.title)
                        .font(AppTypography.audioNotesTopicSelectionRowTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(topic.detailText)
                        .font(AppTypography.audioNotesTopicSelectionRowDetail)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .padding(.top, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let description = topic.description, !description.isEmpty {
                        Text(description)
                            .font(AppTypography.audioNotesTopicSelectionRecentDetail)
                            .foregroundStyle(QuickRevisionPalette.muted)
                            .padding(.top, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private enum AudioNotesPalette {
    static let iconAccent = QuickRevisionPalette.brand
    static let iconBackground = QuickRevisionPalette.iconBackground
}
