import SwiftUI

struct ProgressTabView: View {
    private let content: ProgressTabContent
    private let actions: ProgressTabActions

    init(
        content: ProgressTabContent = .placeholder,
        actions: ProgressTabActions = .init()
    ) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                headerSection
                weeklyEngagementSection
                subjectMasterySection
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            .padding(.bottom, 28)
        }
        .background(ProgressPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension ProgressTabView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(content.title)
                .font(AppTypography.progressTitle)
                .tracking(-0.75)
                .foregroundStyle(ProgressPalette.textPrimary)

            Text(content.subtitle)
                .font(AppTypography.progressSubtitle)
                .foregroundStyle(ProgressPalette.textSecondary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var weeklyEngagementSection: some View {
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
        .shadow(color: ProgressPalette.cardBorder.opacity(0.5), radius: 0, x: 0, y: 0)
    }

    var subjectMasterySection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text(content.subjectMasteryTitle)
                    .font(AppTypography.progressSectionTitle)
                    .tracking(-0.6)
                    .foregroundStyle(ProgressPalette.textPrimary)

                Text(content.subjectMasterySubtitle)
                    .font(AppTypography.progressSectionSubtitle)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .padding(.top, 0)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 16) {
                ForEach(content.subjectMasteries) { mastery in
                    SubjectMasteryRow(mastery: mastery) {
                        handleTapSubjectMastery(mastery)
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    func handleTapSubjectMastery(_ mastery: ProgressTabContent.SubjectMastery) {
        actions.onTapSubjectMastery(mastery)
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
                        Text(day.hoursLabel)
                            .font(AppTypography.progressChartValue)
                            .foregroundStyle(ProgressPalette.textPrimary)
                            .padding(.bottom, 4)

                        Rectangle()
                            .fill(ProgressPalette.barFill)
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
                .padding(.top, 0)
        }
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

                        VStack(alignment: .leading, spacing: 0) {
                            Text(mastery.title)
                                .font(AppTypography.progressMasteryTitle)
                                .foregroundStyle(ProgressPalette.textPrimary)

                            Text(mastery.unitTitle)
                                .font(AppTypography.progressMasterySubtitle)
                                .tracking(0.45)
                                .foregroundStyle(ProgressPalette.textSecondary.opacity(0.5))
                        }
                    }

                    Spacer(minLength: 12)

                    Text(mastery.progressText)
                        .font(AppTypography.progressMasteryValue)
                        .foregroundStyle(valueColor)
                }

                ProgressFillBar(progress: mastery.progress, fill: barFill)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .background(ProgressPalette.rowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
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
