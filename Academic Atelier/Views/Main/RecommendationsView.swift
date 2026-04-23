import SwiftUI

struct RecommendationsView: View {
    private let content: RecommendationsContent
    private let actions: RecommendationsActions

    init(
        content: RecommendationsContent,
        actions: RecommendationsActions = .init()
    ) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroSection
                pathwaysSection
                    .padding(.top, 56)
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
        .background(ProgressPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension RecommendationsView {
    var heroSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10.8) {
                Text(content.eyebrow.uppercased())
                    .font(AppTypography.progressRecommendationsEyebrow)
                    .tracking(2.2)
                    .foregroundStyle(ProgressPalette.sectionLabel)

                Text(content.title)
                    .font(AppTypography.progressRecommendationsTitle)
                    .tracking(-0.9)
                    .foregroundStyle(ProgressPalette.textPrimary)

                summaryText
                    .font(AppTypography.progressRecommendationsSummary)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .lineSpacing(8)
                    .padding(.top, 13.2)
            }

            overallProficiencyCard
        }
    }

    var summaryText: Text {
        content.summarySegments.reduce(Text("")) { partial, segment in
            partial + Text(segment.text)
                .font(segment.isEmphasized ? AppTypography.progressRecommendationsSummaryEmphasis : AppTypography.progressRecommendationsSummary)
                .foregroundStyle(segment.isEmphasized ? ProgressPalette.brand : ProgressPalette.textSecondary)
        }
    }

    var overallProficiencyCard: some View {
        HStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(ProgressPalette.cardBorder, lineWidth: 6)

                Circle()
                    .trim(from: 0, to: content.overallProficiency.scoreValue)
                    .stroke(ProgressPalette.brand, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(content.overallProficiency.scoreText)
                    .font(AppTypography.progressRecommendationsScoreValue)
                    .foregroundStyle(ProgressPalette.textPrimary)
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(content.overallProficiency.title.uppercased())
                    .font(AppTypography.progressRecommendationsScoreLabel)
                    .tracking(1.0)
                    .foregroundStyle(ProgressPalette.sectionLabel)

                Text(content.overallProficiency.message)
                    .font(AppTypography.progressRecommendationsCardBody)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
        .background(ProgressPalette.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ProgressPalette.cardBorder.opacity(0.4), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: ProgressPalette.shadow, radius: 2, y: 1)
    }

    var pathwaysSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .lastTextBaseline) {
                Text(content.sectionTitle)
                    .font(AppTypography.progressRecommendationsSectionTitle)
                    .tracking(-0.5)
                    .foregroundStyle(ProgressPalette.textPrimary)

                Spacer(minLength: 12)

                Text(content.sectionActionTitle.uppercased())
                    .font(AppTypography.progressRecommendationsSectionAction)
                    .tracking(0.9)
                    .foregroundStyle(ProgressPalette.brand.opacity(0.4))
            }

            VStack(spacing: 16) {
                ForEach(content.pathways) { pathway in
                    RecommendationPathwayCard(pathway: pathway) {
                        actions.onTapStartRevision(pathway)
                    }
                }
            }
        }
    }
}

struct RecommendationsActions {
    var onTapStartRevision: (RecommendationsContent.Pathway) -> Void = { _ in }
}

private struct RecommendationPathwayCard: View {
    let pathway: RecommendationsContent.Pathway
    let onTapPrimary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                priorityPill

                Text(pathway.title)
                    .font(titleFont)
                    .tracking(titleTracking)
                    .foregroundStyle(ProgressPalette.textPrimary)
                    .padding(.top, titleTopPadding)

                Text(pathway.summary)
                    .font(AppTypography.progressRecommendationsPathwayBody)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .lineSpacing(7)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, bodyTopPadding)

                if let curriculumProgress = pathway.curriculumProgress {
                    curriculumProgressView(curriculumProgress)
                        .padding(.top, 24)
                }
            }

            if let title = pathway.primaryActionTitle {
                HStack {
                    Button(action: onTapPrimary) {
                        Text(title)
                            .font(AppTypography.progressRecommendationsPrimaryButton)
                            .foregroundStyle(.white)
                            .frame(width: 132.67, height: 40)
                            .background(ProgressPalette.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 12)

                    if let durationText = pathway.durationText {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 13, weight: .medium))
                            Text(durationText)
                                .font(AppTypography.progressRecommendationsDuration)
                                .tracking(1.0)
                        }
                        .foregroundStyle(ProgressPalette.textSecondary.opacity(0.6))
                    }
                }
            }

            if let reviewHistoryTitle = pathway.reviewHistoryTitle, !pathway.reviewHistory.isEmpty {
                reviewHistoryView(title: reviewHistoryTitle, items: pathway.reviewHistory)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var priorityPill: some View {
        Group {
            if pathway.priority == .critical {
                Text(pathway.priority.label.uppercased())
                    .font(AppTypography.progressRecommendationsPriorityPill)
                    .tracking(0.45)
                    .foregroundStyle(ProgressPalette.criticalPillForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(ProgressPalette.criticalPillBackground)
                    .clipShape(Capsule())
            } else {
                Text(pathway.priority.label.uppercased())
                    .font(AppTypography.progressRecommendationsSecondaryEyebrow)
                    .tracking(1.35)
                    .foregroundStyle(ProgressPalette.textSecondary.opacity(0.4))
            }
        }
    }

    private func curriculumProgressView(_ progress: RecommendationsContent.CurriculumProgress) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(progress.label.uppercased())
                    .font(AppTypography.progressRecommendationsProgressLabel)
                    .tracking(0.9)
                    .foregroundStyle(ProgressPalette.textSecondary.opacity(0.5))

                Spacer(minLength: 12)

                Text(progress.valueText.uppercased())
                    .font(AppTypography.progressRecommendationsProgressLabel)
                    .tracking(0.9)
                    .foregroundStyle(ProgressPalette.textSecondary.opacity(0.5))
            }

            ProgressFillBar(progress: progress.progress, fill: ProgressPalette.brand.opacity(0.6))
        }
    }

    private func reviewHistoryView(title: String, items: [RecommendationsContent.ReviewHistoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(AppTypography.progressRecommendationsNestedTitle)
                .tracking(0.9)
                .foregroundStyle(ProgressPalette.textSecondary.opacity(0.4))

            VStack(spacing: 12) {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(ProgressPalette.brand.opacity(0.05))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: item.iconName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(ProgressPalette.brand)
                            }

                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.title)
                                .font(AppTypography.progressRecommendationsHistoryTitle)
                                .foregroundStyle(ProgressPalette.textPrimary)

                            Text(item.timeAgoText)
                                .font(AppTypography.progressRecommendationsHistoryMeta)
                                .tracking(0.8)
                                .foregroundStyle(ProgressPalette.textSecondary.opacity(0.5))
                        }

                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .background(ProgressPalette.nestedSurface)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ProgressPalette.cardBorder.opacity(0.4), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var titleFont: Font {
        pathway.priority == .critical
            ? AppTypography.progressRecommendationsPathwayTitleCritical
            : AppTypography.progressRecommendationsPathwayTitle
    }

    private var titleTracking: CGFloat {
        pathway.priority == .critical ? 0 : 0
    }

    private var titleTopPadding: CGFloat {
        pathway.priority == .critical ? 15.5 : 29.5
    }

    private var bodyTopPadding: CGFloat {
        pathway.priority == .critical ? 6.75 : 6.375
    }

    private var backgroundColor: Color {
        pathway.priority == .critical
            ? ProgressPalette.recommendationsCard
            : ProgressPalette.secondaryRecommendationsCard
    }
}
