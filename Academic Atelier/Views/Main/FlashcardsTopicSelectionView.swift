import SwiftUI

struct FlashcardsTopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: FlashcardsTopicSelectionContent
    private let actions: FlashcardsTopicSelectionActions

    init(
        content: FlashcardsTopicSelectionContent = .placeholder,
        actions: FlashcardsTopicSelectionActions = .init()
    ) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 44) {
                    headerSection
                    availableTopicsSection
                    recentlyPracticedSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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
            Text(content.title)
                .font(AppTypography.flashcardsTopicSelectionTitle)
                .tracking(-1.1)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(content.subtitle)
                .font(AppTypography.flashcardsTopicSelectionSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var availableTopicsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(content.availableTopicsTitle.uppercased())
                .font(AppTypography.flashcardsTopicSelectionSectionLabel)
                .tracking(2.0)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            VStack(spacing: 20) {
                ForEach(content.availableTopics) { topic in
                    FlashcardsTopicRow(topic: topic) {
                        actions.onTapTopic(topic)
                    }
                }
            }
        }
    }

    var recentlyPracticedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(content.recentlyPracticedTitle.uppercased())
                .font(AppTypography.flashcardsTopicSelectionSectionLabel)
                .tracking(2.0)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(content.recentlyPracticed) { topic in
                    FlashcardsRecentCard(topic: topic) {
                        actions.onTapRecentTopic(topic)
                    }
                }
            }
        }
    }
}

struct FlashcardsTopicSelectionActions {
    var onTapTopic: (FlashcardsTopicSelectionContent.Topic) -> Void = { _ in }
    var onTapRecentTopic: (FlashcardsTopicSelectionContent.RecentTopic) -> Void = { _ in }
}

private struct FlashcardsTopicRow: View {
    let topic: FlashcardsTopicSelectionContent.Topic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(QuickRevisionPalette.iconBackground)
                        .frame(width: 84, height: 84)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
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
    }
}

private struct FlashcardsRecentCard: View {
    let topic: FlashcardsTopicSelectionContent.RecentTopic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(QuickRevisionPalette.iconBackground)
                        .frame(width: 52, height: 52)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(topic.title)
                        .font(AppTypography.flashcardsTopicSelectionRecentTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(topic.subjectCode)
                        .font(AppTypography.flashcardsTopicSelectionRecentDetail)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .background(QuickRevisionPalette.iconBackgroundMuted)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
