import SwiftUI

struct ProgressTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    @StateObject private var viewModel = ProgressTabViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private let actions: ProgressTabActions

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    init(actions: ProgressTabActions = .init()) {
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                headerSection
                statusSection

                if let content = viewModel.content {
                    weeklyEngagementSection(content: content)
                    subjectMasterySection(content: content)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            .padding(.bottom, 28)
        }
        .background(ProgressPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task(id: refreshCenter.progressToken) {
            await load(forceRefresh: viewModel.content != nil)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, viewModel.content != nil else { return }
            Task {
                await load(forceRefresh: true)
            }
        }
        .refreshable {
            await load(forceRefresh: true)
        }
        .onAppear {
            focusedElement = .title
        }
        .onChange(of: viewModel.errorMessage) { _, message in
            guard !message.isEmpty else { return }
            focusedElement = .status
            Task { @MainActor in
                AccessibilitySupport.announce(message)
            }
        }
    }
}

private extension ProgressTabView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.content?.title ?? "Revision Insights")
                .font(AppTypography.progressTitle)
                .tracking(-0.75)
                .foregroundStyle(ProgressPalette.textPrimary)
                .accessibilityHeader()
                .accessibilityFocused($focusedElement, equals: .title)

            Text(viewModel.content?.subtitle ?? "Track your weekly study progress.")
                .font(AppTypography.progressSubtitle)
                .foregroundStyle(ProgressPalette.textSecondary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading progress...")
                    .font(.footnote)
                    .foregroundStyle(ProgressPalette.textSecondary)
            }
        } else if !viewModel.errorMessage.isEmpty && viewModel.content == nil {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)
                    .accessibilityFocused($focusedElement, equals: .status)

                Button("Retry") {
                    Task {
                        await load(forceRefresh: true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(ProgressPalette.brand)
            }
        } else if viewModel.isLoading {
            Text("Refreshing progress...")
                .font(.footnote)
                .foregroundStyle(ProgressPalette.textSecondary)
        }
    }

    func weeklyEngagementSection(content: ProgressTabContent) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 4) {
                Text(content.weeklyEngagement.eyebrow.uppercased())
                    .font(AppTypography.progressCardEyebrow)
                    .tracking(2)
                    .foregroundStyle(ProgressPalette.brand)

                Text(content.weeklyEngagement.title)
                    .font(AppTypography.progressCardTitle)
                    .tracking(-0.5)
                    .foregroundStyle(ProgressPalette.textPrimary)
            }

            WeeklyEngagementChart(days: content.weeklyEngagement.days)

            HStack(spacing: 12) {
                ForEach(content.weeklyEngagement.statCards) { card in
                    WeeklyStatCard(card: card)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ProgressPalette.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ProgressPalette.cardBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func subjectMasterySection(content: ProgressTabContent) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text(content.subjectMasteryTitle)
                    .font(AppTypography.progressSectionTitle)
                    .tracking(-0.6)
                    .foregroundStyle(ProgressPalette.textPrimary)
                    .accessibilityHeader()

                Text(content.subjectMasterySubtitle)
                    .font(AppTypography.progressSectionSubtitle)
                    .foregroundStyle(ProgressPalette.textSecondary)
            }
            .padding(.horizontal, 8)

            if content.subjectMasteries.isEmpty {
                Text(content.emptyStateMessage)
                    .font(.footnote)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .padding(.horizontal, 8)
            } else {
                VStack(spacing: 16) {
                    ForEach(content.subjectMasteries) { mastery in
                        SubjectMasteryRow(mastery: mastery) {
                            actions.onTapSubjectMastery(mastery)
                        }
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    func load(forceRefresh: Bool = false) async {
        await viewModel.load(forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }
}

struct ProgressTabActions {
    var onTapSubjectMastery: (ProgressTabContent.SubjectMastery) -> Void = { _ in }
}

private struct WeeklyEngagementChart: View {
    let days: [ProgressTabContent.WeeklyDay]

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(days) { day in
                    VStack(spacing: 0) {
                        Text(day.minuteLabel)
                            .font(AppTypography.progressChartValue)
                            .foregroundStyle(ProgressPalette.textPrimary)
                            .padding(.bottom, 4)

                        Rectangle()
                            .fill(day.isHighlighted ? ProgressPalette.brand : ProgressPalette.barFill)
                            .frame(width: 30, height: day.barHeight)

                        Text(day.shortLabel)
                            .font(day.isHighlighted ? AppTypography.progressChartLabelHighlighted : AppTypography.progressChartLabel)
                            .foregroundStyle(day.isHighlighted ? ProgressPalette.brand : ProgressPalette.textSecondary.opacity(0.6))
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .frame(height: 176, alignment: .bottom)
            .padding(.horizontal, 8)

            Rectangle()
                .fill(ProgressPalette.cardBorder)
                .frame(height: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weekly engagement chart")
        .accessibilityValue(days.map { "\($0.shortLabel) \($0.minuteLabel)" }.joined(separator: ", "))
    }
}

private struct WeeklyStatCard: View {
    let card: ProgressTabContent.StatCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: card.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(ProgressPalette.brand)

                Text(card.title.uppercased())
                    .font(AppTypography.progressStatLabel)
                    .tracking(0.9)
                    .foregroundStyle(ProgressPalette.textSecondary.opacity(0.7))
            }

            Text(card.valueText)
                .font(AppTypography.progressStatValue)
                .foregroundStyle(ProgressPalette.textPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 91, alignment: .leading)
        .background(ProgressPalette.mutedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.title)
        .accessibilityValue(card.valueText)
    }
}

private struct SubjectMasteryRow: View {
    let mastery: ProgressTabContent.SubjectMastery
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(iconBackground)
                            .frame(width: 36, height: 36)
                            .overlay {
                                Image(systemName: mastery.iconName)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(iconForeground)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(mastery.title)
                                .font(AppTypography.progressMasteryTitle)
                                .foregroundStyle(ProgressPalette.textPrimary)

                            Text(mastery.subtitle)
                                .font(AppTypography.progressMasterySubtitle)
                                .tracking(0.2)
                                .foregroundStyle(ProgressPalette.textSecondary.opacity(0.7))
                        }
                    }

                    Spacer(minLength: 12)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(mastery.progressText)
                            .font(AppTypography.progressMasteryValue)
                            .foregroundStyle(valueColor)

                        Text("MASTERY \(mastery.masteryText)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ProgressPalette.textSecondary.opacity(0.6))
                    }
                }

                ProgressFillBar(progress: mastery.progress, fill: barFill)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .background(ProgressPalette.rowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(mastery.title)
        .accessibilityValue("\(mastery.subtitle). \(mastery.progressText). Mastery \(mastery.masteryText)")
        .accessibilityHint("Open recommendations for this subject.")
    }

    private var iconBackground: Color {
        mastery.accentStyle == .brand ? ProgressPalette.iconTile : ProgressPalette.iconTileMuted
    }

    private var iconForeground: Color {
        mastery.accentStyle == .brand ? ProgressPalette.brand : ProgressPalette.mutedBlue
    }

    private var valueColor: Color {
        mastery.accentStyle == .brand ? ProgressPalette.brand : ProgressPalette.textSecondary.opacity(0.7)
    }

    private var barFill: Color {
        mastery.accentStyle == .brand ? ProgressPalette.brand : ProgressPalette.mutedBlue
    }
}
