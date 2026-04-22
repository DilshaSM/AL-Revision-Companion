import SwiftUI

struct QuickRevisionTopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    private let subject: QuickRevisionSubject
    private let actions: QuickRevisionTopicSelectionActions

    init(subject: QuickRevisionSubject, actions: QuickRevisionTopicSelectionActions = .init()) {
        self.subject = subject
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    topicsSection
                    recentlyOpenedSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension QuickRevisionTopicSelectionView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)
        }
        .frame(height: 96)
        .overlay {
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Text("Select Topic")
                    .font(AppTypography.quickRevisionTopBarTitle)
                    .tracking(-0.6)
                    .foregroundStyle(QuickRevisionPalette.topBarInk)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subject.title)
                .font(AppTypography.quickRevisionTopicTitle)
                .tracking(-0.9)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text("Select a topic for quick revision.")
                .font(AppTypography.quickRevisionTopicSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
        }
    }

    var topicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(subject.topicsSectionTitle.uppercased())
                .font(AppTypography.quickRevisionSectionLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            VStack(spacing: 12) {
                ForEach(subject.topics) { topic in
                    QuickRevisionTopicRow(topic: topic) {
                        actions.onTapTopic(topic)
                    }
                }
            }
        }
    }

    var recentlyOpenedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(subject.recentlyOpenedTitle.uppercased())
                .font(AppTypography.quickRevisionSectionLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(subject.recentlyOpened) { recent in
                    QuickRevisionRecentTopicCard(topic: recent) {
                        actions.onTapRecentTopic(recent)
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
}

struct QuickRevisionTopicSelectionActions {
    var onTapTopic: (QuickRevisionSubject.Topic) -> Void = { _ in }
    var onTapRecentTopic: (QuickRevisionSubject.RecentTopic) -> Void = { _ in }
}

private struct QuickRevisionTopicRow: View {
    let topic: QuickRevisionSubject.Topic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(QuickRevisionPalette.iconBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(topic.title)
                        .font(AppTypography.quickRevisionListTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(topic.subtitle)
                        .font(AppTypography.quickRevisionTopicRowSubtitle)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct QuickRevisionRecentTopicCard: View {
    let topic: QuickRevisionSubject.RecentTopic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.cardBackground)
                        .frame(width: 32, height: 32)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                }

                Spacer(minLength: 0)

                Text(topic.title)
                    .font(AppTypography.quickRevisionRecentTitle)
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
            .background(QuickRevisionPalette.iconBackgroundMuted)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
