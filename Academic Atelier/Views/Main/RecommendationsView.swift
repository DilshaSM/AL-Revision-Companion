import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    @StateObject private var viewModel = RecommendationsViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private let preferredSubject: ProgressTabContent.SubjectMastery?
    private let actions: RecommendationsActions

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    init(
        preferredSubject: ProgressTabContent.SubjectMastery? = nil,
        actions: RecommendationsActions = .init()
    ) {
        self.preferredSubject = preferredSubject
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroSection
                statusSection
                    .padding(.top, 20)
                pathwaysSection
                    .padding(.top, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
        .background(ProgressPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task(id: refreshCenter.recommendationsToken) {
            await load(forceRefresh: viewModel.content != nil)
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

private extension RecommendationsView {
    @ViewBuilder
    var heroSection: some View {
        let content = viewModel.content

        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10.8) {
                Text((content?.eyebrow ?? "Performance Analysis").uppercased())
                    .font(AppTypography.progressRecommendationsEyebrow)
                    .tracking(2.2)
                    .foregroundStyle(ProgressPalette.sectionLabel)

                Text(content?.title ?? "Study\nRecommendations")
                    .font(AppTypography.progressRecommendationsTitle)
                    .tracking(-0.9)
                    .foregroundStyle(ProgressPalette.textPrimary)
                    .accessibilityHeader()
                    .accessibilityFocused($focusedElement, equals: .title)

                Text(content?.summary ?? "Complete a quiz to receive personalized study recommendations.")
                    .font(AppTypography.progressRecommendationsSummary)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .lineSpacing(8)
                    .padding(.top, 13.2)
            }

            if let overview = content?.overview {
                overviewCard(overview)
            }
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading recommendations...")
                    .font(.footnote)
                    .foregroundStyle(ProgressPalette.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading recommendations.")
            .accessibilityFocused($focusedElement, equals: .status)
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
                .foregroundStyle(ProgressPalette.brand)
            }
            .accessibilityElement(children: .contain)
            .accessibilityFocused($focusedElement, equals: .status)
        } else if viewModel.isLoading {
            Text("Refreshing recommendations...")
                .font(.footnote)
                .foregroundStyle(ProgressPalette.textSecondary)
                .accessibilityFocused($focusedElement, equals: .status)
        }
    }

    func overviewCard(_ overview: RecommendationsContent.Overview) -> some View {
        HStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(ProgressPalette.cardBorder, lineWidth: 6)
                    .accessibilityHidden(true)

                Circle()
                    .trim(from: 0, to: overview.scoreValue)
                    .stroke(ProgressPalette.brand, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .accessibilityHidden(true)

                Text(overview.scoreText)
                    .font(AppTypography.progressRecommendationsScoreValue)
                    .foregroundStyle(ProgressPalette.textPrimary)
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(overview.title.uppercased())
                    .font(AppTypography.progressRecommendationsScoreLabel)
                    .tracking(1.0)
                    .foregroundStyle(ProgressPalette.sectionLabel)

                Text(overview.message)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(overview.title)
        .accessibilityValue("\(overview.scoreText). \(overview.message)")
    }

    @ViewBuilder
    var pathwaysSection: some View {
        if let content = viewModel.content {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .lastTextBaseline) {
                    Text(content.sectionTitle)
                        .font(AppTypography.progressRecommendationsSectionTitle)
                        .tracking(-0.5)
                        .foregroundStyle(ProgressPalette.textPrimary)
                        .accessibilityHeader()

                    Spacer(minLength: 12)

                    Text(content.sectionActionTitle.uppercased())
                        .font(AppTypography.progressRecommendationsSectionAction)
                        .tracking(0.9)
                        .foregroundStyle(ProgressPalette.brand.opacity(0.4))
                }

                if content.pathways.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(content.emptyStateTitle)
                            .font(AppTypography.progressRecommendationsSectionTitle)
                            .foregroundStyle(ProgressPalette.textPrimary)

                        Text(content.emptyStateMessage)
                            .font(AppTypography.progressRecommendationsPathwayBody)
                            .foregroundStyle(ProgressPalette.textSecondary)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ProgressPalette.secondaryRecommendationsCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    VStack(spacing: 16) {
                        ForEach(content.pathways) { pathway in
                            RecommendationPathwayCard(pathway: pathway) {
                                handleStartRevision(pathway)
                                actions.onTapStartRevision(pathway)
                            }
                        }
                    }
                }
            }
        }
    }

    func load(forceRefresh: Bool = false) async {
        await viewModel.load(
            preferredSubject: preferredSubject,
            forceRefresh: forceRefresh
        )

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }

    func handleStartRevision(_ pathway: RecommendationsContent.Pathway) {
        if pathway.subjectId == nil && pathway.topicId == nil {
            router.handle(.subjects)
            return
        }

        router.handle(
            .recommendation(
                subjectId: pathway.subjectId,
                topicId: pathway.topicId
            )
        )
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
                    .font(pathway.priority == .critical ? AppTypography.progressRecommendationsPathwayTitleCritical : AppTypography.progressRecommendationsPathwayTitle)
                    .foregroundStyle(ProgressPalette.textPrimary)
                    .padding(.top, pathway.priority == .critical ? 15.5 : 24)

                Text(pathway.subjectLine.uppercased())
                    .font(AppTypography.progressRecommendationsSecondaryEyebrow)
                    .tracking(1.1)
                    .foregroundStyle(ProgressPalette.brand.opacity(0.6))
                    .padding(.top, 8)

                Text(pathway.summary)
                    .font(AppTypography.progressRecommendationsPathwayBody)
                    .foregroundStyle(ProgressPalette.textSecondary)
                    .lineSpacing(7)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(pathway.title)
            .accessibilityValue(pathwaySummary)

            HStack {
                if let title = pathway.primaryActionTitle {
                    Button(action: onTapPrimary) {
                        Text(title)
                            .font(AppTypography.progressRecommendationsPrimaryButton)
                            .foregroundStyle(.white)
                            .frame(width: 132.67, height: 40)
                            .background(ProgressPalette.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Start this recommended revision path.")
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 6) {
                    if let durationText = pathway.durationText {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 13, weight: .medium))
                                .accessibilityHidden(true)
                            Text(durationText)
                                .font(AppTypography.progressRecommendationsDuration)
                                .tracking(1.0)
                        }
                        .foregroundStyle(ProgressPalette.textSecondary.opacity(0.6))
                    }

                    if let scoreText = pathway.scoreText {
                        Text(scoreText.uppercased())
                            .font(AppTypography.progressRecommendationsHistoryMeta)
                            .tracking(0.8)
                            .foregroundStyle(ProgressPalette.textSecondary.opacity(0.5))
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(pathway.priority == .critical ? ProgressPalette.recommendationsCard : ProgressPalette.secondaryRecommendationsCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
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
        .accessibilityHidden(true)
    }

    var pathwaySummary: String {
        var parts = [
            pathway.priority.label,
            pathway.subjectLine,
            pathway.summary
        ]

        if let durationText = pathway.durationText {
            parts.append("Estimated time \(durationText)")
        }

        if let scoreText = pathway.scoreText {
            parts.append(scoreText)
        }

        return parts.joined(separator: ". ")
    }
}
