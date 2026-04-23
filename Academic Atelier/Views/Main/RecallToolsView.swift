import SwiftUI

struct RecallToolsView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: RecallToolsContent
    private let actions: RecallToolsViewActions

    init(content: RecallToolsContent = .placeholder, actions: RecallToolsViewActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    headerSection
                    supportToolsSection
                    recentlyUsedSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension RecallToolsView {
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

                Text("Recall Tools")
                    .font(AppTypography.recallToolsTopBarTitle)
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
        VStack(alignment: .leading, spacing: 20) {
            Text("REVISION SUPPORT")
                .font(AppTypography.recallToolsEyebrow)
                .tracking(2.0)
                .foregroundStyle(QuickRevisionPalette.brand)

            VStack(alignment: .leading, spacing: 18) {
                Text("Recall Tools")
                    .font(AppTypography.recallToolsTitle)
                    .tracking(-1.1)
                    .foregroundStyle(QuickRevisionPalette.ink)

                Text("Strengthen memory with flashcards and audio-based revision.")
                    .font(AppTypography.recallToolsSubtitle)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var supportToolsSection: some View {
        VStack(spacing: 20) {
            RecallSupportCard(
                iconName: "rectangle.on.rectangle",
                accent: .blue,
                title: "Flashcards",
                description: "Review definitions, formulas, and key concepts one card at a time.",
                metadata: "QUICK RECALL • ACTIVE REVIEW",
                action: actions.onTapFlashcards
            )

            RecallSupportCard(
                iconName: "headphones",
                accent: .orange,
                title: "Audio Notes",
                description: "Listen to concise topic summaries for revision on the go.",
                metadata: "HANDS-FREE • LISTEN & REVISE",
                action: actions.onTapAudioNotes
            )
        }
    }

    var recentlyUsedSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Recently Used")
                .font(AppTypography.recallToolsSectionTitle)
                .foregroundStyle(QuickRevisionPalette.ink)

            VStack(spacing: 20) {
                ForEach(content.recentItems) { item in
                    RecallRecentItemCard(item: item) {
                        actions.onTapRecentItem(item)
                    }
                }
            }
        }
    }
}

struct RecallToolsViewActions {
    var onTapFlashcards: () -> Void = {}
    var onTapAudioNotes: () -> Void = {}
    var onTapRecentItem: (RecallToolsContent.RecentItem) -> Void = { _ in }
}

private struct RecallSupportCard: View {
    let iconName: String
    let accent: RecallToolsContent.Accent
    let title: String
    let description: String
    let metadata: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(backgroundColor)
                        .frame(width: 84, height: 84)

                    Image(systemName: iconName)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text(title)
                        .font(AppTypography.recallToolsCardTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)

                    Text(description)
                        .font(AppTypography.recallToolsCardBody)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(metadata)
                        .font(AppTypography.recallToolsMetadata)
                        .foregroundStyle(QuickRevisionPalette.sectionLabel.opacity(0.75))
                        .tracking(0.3)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron.opacity(0.5))
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var accentColor: Color {
        switch accent {
        case .blue:
            return QuickRevisionPalette.brand
        case .orange:
            return RecallToolsPalette.orange
        }
    }

    private var backgroundColor: Color {
        switch accent {
        case .blue:
            return QuickRevisionPalette.iconBackground
        case .orange:
            return RecallToolsPalette.orangeTint
        }
    }
}

private struct RecallRecentItemCard: View {
    let item: RecallToolsContent.RecentItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(AppColors.cardBackground)
                        .frame(width: 52, height: 52)

                    Image(systemName: item.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(item.title)
                        .font(AppTypography.recallToolsRecentTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.detail)
                        .font(AppTypography.recallToolsRecentDetail)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: "ellipsis.vertical")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(QuickRevisionPalette.chevron.opacity(0.55))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(QuickRevisionPalette.iconBackgroundMuted)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch item.accent {
        case .blue:
            return QuickRevisionPalette.brand
        case .orange:
            return RecallToolsPalette.orange
        }
    }
}

private enum RecallToolsPalette {
    static let orange = Color(uiColor: .init(red: 180.0 / 255.0, green: 87.0 / 255.0, blue: 14.0 / 255.0, alpha: 1))
    static let orangeTint = Color(uiColor: .init(red: 243.0 / 255.0, green: 233.0 / 255.0, blue: 225.0 / 255.0, alpha: 1))
}
