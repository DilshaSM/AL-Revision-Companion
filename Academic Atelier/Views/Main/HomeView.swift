import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter
    @StateObject private var dashboardViewModel = HomeDashboardViewModel()

    private let providedContent: HomeDashboardContent?
    private let actions: HomeViewActions

    init(content: HomeDashboardContent? = nil, actions: HomeViewActions = .init()) {
        providedContent = content
        self.actions = actions
    }

    private var dashboard: HomeDashboardContent {
        providedContent ?? dashboardViewModel.content ?? .placeholder(for: session.currentUser)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    greetingSection
                    dashboardStatusSection
                    continueLearningSection
                    todaysFocusSection
                    quickToolsSection
                    weeklyProgressSection
                    weaknessSection
                    recentSubjectsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .refreshable {
                await loadDashboard(forceRefresh: true)
            }
        }
        .background(HomePalette.canvas.ignoresSafeArea())
        .task(id: refreshCenter.dashboardToken) {
            await loadDashboard(forceRefresh: dashboardViewModel.content != nil)
        }
    }

    private func loadDashboard(forceRefresh: Bool = false) async {
        guard providedContent == nil else { return }

        await dashboardViewModel.load(for: session.currentUser, forceRefresh: forceRefresh)

        if dashboardViewModel.requiresSignOut {
            session.signOut()
        }
    }
}

// MARK: - Sections
private extension HomeView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(HomePalette.topBarTint)

            Rectangle()
                .fill(.black.opacity(0.06))
                .frame(height: 0.5)
        }
        .frame(height: 96)
        .overlay {
            HStack(spacing: 16) {
                Text(dashboard.appTitle)
                    .font(AppTypography.homeTopBarTitle)
                    .tracking(-1.2)
                    .foregroundStyle(HomePalette.brand)

                Spacer()

                Button {
                    actions.onTapSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(HomePalette.muted)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 24)
            .padding(.trailing, 24)
            .padding(.bottom, 16)
        }
    }

    var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dashboard.greetingLine)
                .font(AppTypography.homeGreetingLine)
                .tracking(-0.4)
                .foregroundStyle(HomePalette.muted)

            Text(dashboard.greetingHeadline)
                .font(AppTypography.homeGreetingHeadline)
                .tracking(-0.75)
                .foregroundStyle(HomePalette.ink)
        }
    }

    @ViewBuilder
    var dashboardStatusSection: some View {
        if dashboardViewModel.isLoading && dashboardViewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading dashboard...")
                    .font(.footnote)
                    .foregroundStyle(HomePalette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if !dashboardViewModel.errorMessage.isEmpty {
            Text(dashboardViewModel.errorMessage)
                .font(.footnote)
                .foregroundStyle(HomePalette.dangerText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HomeEyebrow(title: dashboard.continueLearning.eyebrow, color: HomePalette.brand)

                    Text(dashboard.continueLearning.title)
                        .font(AppTypography.homeCardTitle)
                        .foregroundStyle(HomePalette.ink)
                        .lineSpacing(2)
                }

                Spacer(minLength: 0)

                SmallBlueButton(
                    title: dashboard.continueLearning.actionTitle,
                    action: actions.onTapContinueLearning
                )
            }

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                HomeProgressTrack(
                    value: dashboard.continueLearning.progress,
                    tint: HomePalette.brand,
                    background: HomePalette.track,
                    height: 6
                )

                Text(dashboard.continueLearning.progressText)
                    .font(AppTypography.homeCaption)
                    .foregroundStyle(HomePalette.muted)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 196, alignment: .topLeading)
        .homeCardStyle(cornerRadius: 20, shadowColor: .black.opacity(0.05), shadowRadius: 2, shadowY: 1)
    }

    var todaysFocusSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "water.waves")
                .font(.system(size: 180, weight: .regular))
                .foregroundStyle(.white.opacity(0.08))
                .rotationEffect(.degrees(12))
                .offset(x: 50, y: -22)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    FrostedPill(title: dashboard.todaysFocus.eyebrow)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11, weight: .bold))

                        Text(dashboard.todaysFocus.timerText)
                            .font(AppTypography.homeCaption)
                            .tracking(1.2)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .textCase(.uppercase)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(dashboard.todaysFocus.title)
                        .font(AppTypography.homeHeroTitle)
                        .tracking(-0.9)
                        .foregroundStyle(.white)
                        .lineSpacing(3)

                    Text(dashboard.todaysFocus.subtitle)
                        .font(AppTypography.homeHeroBody)
                        .foregroundStyle(.white.opacity(0.72))
                        .lineSpacing(2)
                }
                .padding(.top, 24)

                Spacer(minLength: 0)

                WhiteFocusButton(
                    title: dashboard.todaysFocus.actionTitle,
                    action: actions.onTapTodaysFocus
                )
                    .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity, minHeight: 340, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [HomePalette.brand, HomePalette.brandBright],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: HomePalette.brand.opacity(0.20), radius: 25, x: 0, y: 12)
    }

    var quickToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HomeEyebrow(title: dashboard.quickToolsTitle, color: HomePalette.muted)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(dashboard.quickTools) { tool in
                    QuickToolCard(tool: tool, action: actions.onTapQuickTool)
                }
            }
        }
    }

    var weeklyProgressSection: some View {
        Button(action: actions.onTapWeeklyProgress) {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        HomeEyebrow(title: dashboard.weeklyProgress.eyebrow, color: HomePalette.muted)

                        Text(dashboard.weeklyProgress.title)
                            .font(AppTypography.homeFeatureTitle)
                            .foregroundStyle(HomePalette.ink)
                    }

                    Spacer(minLength: 16)

                    VStack(alignment: .trailing, spacing: 0) {
                        Text(dashboard.weeklyProgress.scoreText)
                            .font(AppTypography.homeMetric)
                            .foregroundStyle(HomePalette.brand)

                        Text(dashboard.weeklyProgress.statusText)
                            .font(AppTypography.homeMeta)
                            .foregroundStyle(HomePalette.muted)
                    }
                }

                VStack(spacing: 12) {
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(dashboard.weeklyProgress.days) { day in
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(day.isHighlighted ? HomePalette.brand : HomePalette.track)
                                .frame(maxWidth: .infinity, minHeight: CGFloat(max(2.0, 54.0 * day.value)))
                                .shadow(
                                    color: day.isHighlighted ? HomePalette.brand.opacity(0.2) : .clear,
                                    radius: 12,
                                    x: 0,
                                    y: -4
                                )
                        }
                    }
                    .frame(height: 54, alignment: .bottom)

                    HStack {
                        ForEach(dashboard.weeklyProgress.days) { day in
                            Text(day.label)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(day.isHighlighted ? HomePalette.brand : HomePalette.muted)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(25)
            .homeCardStyle(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    var weaknessSection: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(alignment: .top) {
                HomeEyebrow(title: dashboard.weakness.eyebrow, color: HomePalette.muted)

                Spacer()

                Text(dashboard.weakness.statusText)
                    .font(AppTypography.homeCaption)
                    .foregroundStyle(HomePalette.dangerText)
            }

            Text(dashboard.weakness.title)
                .font(AppTypography.homeBody)
                .foregroundStyle(.black)

            VStack(alignment: .leading, spacing: 4) {
                Text(dashboard.weakness.metricLabel)
                    .font(AppTypography.homeMeta)
                    .foregroundStyle(HomePalette.supportingGray)

                HomeProgressTrack(
                    value: dashboard.weakness.progress,
                    tint: HomePalette.danger,
                    background: HomePalette.soft,
                    height: 4
                )

                Text(dashboard.weakness.metricValueText)
                    .font(AppTypography.homeMeta)
                    .foregroundStyle(HomePalette.danger)
            }

            Text(dashboard.weakness.note)
                .font(AppTypography.homeMetaRegular)
                .foregroundStyle(HomePalette.supportingGray)
                .lineSpacing(2)

            DangerActionButton(
                title: dashboard.weakness.actionTitle,
                action: actions.onTapWeakness
            )
        }
        .padding(25)
        .frame(maxWidth: .infinity, minHeight: 302, alignment: .topLeading)
        .homeCardStyle(cornerRadius: 20, shadowColor: .black.opacity(0.05), shadowRadius: 20, shadowY: 10)
    }

    var recentSubjectsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(dashboard.recentSubjectsTitle)
                .font(AppTypography.homeSectionTitle)
                .foregroundStyle(HomePalette.ink)

            VStack(spacing: 16) {
                if dashboard.recentSubjects.isEmpty {
                    emptyRecentSubjectsCard
                } else {
                    if !dashboard.recentSubjects.compactCards.isEmpty {
                        HStack(spacing: 16) {
                            ForEach(dashboard.recentSubjects.compactCards) { subject in
                                SubjectCard(subject: subject)
                            }
                        }
                    }

                    if let featuredCard = dashboard.recentSubjects.featuredCard {
                        BiologySubjectCard(subject: featuredCard)
                    }
                }
            }
        }
    }

    var emptyRecentSubjectsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(HomePalette.brand)

            Text("No recent subjects yet")
                .font(AppTypography.homeBody)
                .foregroundStyle(HomePalette.ink)

            Text("Open a lesson to populate this section.")
                .font(AppTypography.homeMetaRegular)
                .foregroundStyle(HomePalette.muted)
        }
        .padding(21)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .homeCardStyle(cornerRadius: 20)
    }
}

// MARK: - Helpers
struct HomeViewActions {
    var onTapSettings: () -> Void = {}
    var onTapContinueLearning: () -> Void = {}
    var onTapTodaysFocus: () -> Void = {}
    var onTapWeeklyProgress: () -> Void = {}
    var onTapWeakness: () -> Void = {}
    var onTapQuickTool: (HomeDashboardContent.QuickToolContent) -> Void = { _ in }
}

private extension View {
    func homeCardStyle(
        cornerRadius: CGFloat,
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 0,
        shadowY: CGFloat = 0
    ) -> some View {
        background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(HomePalette.border, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }
}

private struct HomeEyebrow: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title.uppercased())
            .font(AppTypography.homeCardEyebrow)
            .tracking(1.0)
            .foregroundStyle(color)
    }
}

private struct FrostedPill: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(AppTypography.homeCardEyebrow)
            .tracking(1.0)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.white.opacity(0.20))
            .clipShape(Capsule(style: .continuous))
    }
}

private struct HomeProgressTrack: View {
    let value: Double
    let tint: Color
    let background: Color
    let height: CGFloat

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(background)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(tint)
                        .frame(width: proxy.size.width * clampedValue)
                }
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
    }

    private var clampedValue: CGFloat {
        CGFloat(min(max(value, 0), 1))
    }
}

private struct SmallBlueButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.homeButtonSmall)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(HomePalette.brand)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: HomePalette.brand.opacity(0.20), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct WhiteFocusButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.homeButtonMedium)
                .foregroundStyle(HomePalette.brand)
                .padding(.horizontal, 32)
                .frame(height: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 15, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct DangerActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.homeButtonLarge)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(HomePalette.danger)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: HomePalette.brand.opacity(0.18), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct QuickToolCard: View {
    let tool: HomeDashboardContent.QuickToolContent
    let action: (HomeDashboardContent.QuickToolContent) -> Void

    var body: some View {
        Button {
            action(tool)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(HomePalette.accentTint(for: tool.accentStyle))
                        .frame(width: 40, height: 40)

                    Image(systemName: tool.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(HomePalette.accent(for: tool.accentStyle))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.title)
                        .font(AppTypography.homeBody)
                        .foregroundStyle(HomePalette.ink)

                    Text(tool.subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(HomePalette.muted)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
            .padding(16)
            .background(HomePalette.soft)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SubjectCard: View {
    let subject: HomeDashboardContent.CompactRecentSubjectContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(HomePalette.accentTint(for: subject.accentStyle))
                    .frame(width: 48, height: 48)

                Image(systemName: subject.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(HomePalette.accent(for: subject.accentStyle))
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(subject.title)
                    .font(AppTypography.homeBody)
                    .foregroundStyle(HomePalette.ink)

                Text(subject.detail)
                    .font(AppTypography.homeMeta)
                    .foregroundStyle(HomePalette.muted.opacity(0.7))
                    .padding(.top, 1)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(subject.progressText)
                    .font(AppTypography.homeMeta)
                    .foregroundStyle(HomePalette.accent(for: subject.accentStyle))

                HomeProgressTrack(
                    value: subject.progress,
                    tint: HomePalette.accent(for: subject.accentStyle),
                    background: HomePalette.soft,
                    height: 4
                )
                .frame(width: 90)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
        .padding(21)
        .homeCardStyle(cornerRadius: 20)
    }
}

private struct BiologySubjectCard: View {
    let subject: HomeDashboardContent.FeaturedRecentSubjectContent

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(HomePalette.accentTint(for: subject.accentStyle))
                        .frame(width: 48, height: 48)

                    Image(systemName: subject.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(HomePalette.accent(for: subject.accentStyle))
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(subject.title)
                        .font(AppTypography.homeBody)
                        .foregroundStyle(HomePalette.ink)

                    Text(subject.detail)
                        .font(AppTypography.homeMeta)
                        .foregroundStyle(HomePalette.muted.opacity(0.7))
                        .padding(.top, 1)
                }
            }

            Spacer(minLength: 16)

            VStack(alignment: .trailing, spacing: 0.5) {
                Text(subject.valueText)
                    .font(AppTypography.homeMetricSmall)
                    .foregroundStyle(HomePalette.brand)

                Text(subject.trailingLabel)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(HomePalette.muted.opacity(0.6))
                    .tracking(0.9)
            }
        }
        .padding(21)
        .frame(maxWidth: .infinity, minHeight: 90)
        .homeCardStyle(cornerRadius: 20)
    }
}

private enum HomePalette {
    static let canvas = Color(uiColor: .init(red: 248.0 / 255.0, green: 250.0 / 255.0, blue: 252.0 / 255.0, alpha: 1))
    static let brand = Color(uiColor: .init(red: 0.0 / 255.0, green: 88.0 / 255.0, blue: 188.0 / 255.0, alpha: 1))
    static let brandBright = Color(uiColor: .init(red: 0.0 / 255.0, green: 112.0 / 255.0, blue: 235.0 / 255.0, alpha: 1))
    static let ink = Color(uiColor: .init(red: 26.0 / 255.0, green: 28.0 / 255.0, blue: 31.0 / 255.0, alpha: 1))
    static let muted = Color(uiColor: .init(red: 65.0 / 255.0, green: 71.0 / 255.0, blue: 85.0 / 255.0, alpha: 1))
    static let supportingGray = Color(uiColor: .init(red: 170.0 / 255.0, green: 168.0 / 255.0, blue: 168.0 / 255.0, alpha: 1))
    static let soft = Color(uiColor: .init(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 248.0 / 255.0, alpha: 1))
    static let track = Color(uiColor: .init(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 231.0 / 255.0, alpha: 1))
    static let border = Color(uiColor: .init(red: 193.0 / 255.0, green: 198.0 / 255.0, blue: 215.0 / 255.0, alpha: 0.18))
    static let topBarTint = Color.white.opacity(0.72)
    static let danger = Color(uiColor: .init(red: 234.0 / 255.0, green: 83.0 / 255.0, blue: 83.0 / 255.0, alpha: 1))
    static let dangerText = Color(uiColor: .init(red: 216.0 / 255.0, green: 71.0 / 255.0, blue: 51.0 / 255.0, alpha: 1))
    static let toolBlue = Color(uiColor: .init(red: 64.0 / 255.0, green: 94.0 / 255.0, blue: 150.0 / 255.0, alpha: 1))
    static let toolBlueTint = Color(uiColor: .init(red: 161.0 / 255.0, green: 190.0 / 255.0, blue: 253.0 / 255.0, alpha: 0.3))
    static let toolOrange = Color(uiColor: .init(red: 158.0 / 255.0, green: 61.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))
    static let toolOrangeTint = Color(uiColor: .init(red: 255.0 / 255.0, green: 219.0 / 255.0, blue: 204.0 / 255.0, alpha: 1))
    static let biologyTint = Color(uiColor: .init(red: 216.0 / 255.0, green: 226.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2))

    static func accent(for style: HomeAccentStyle) -> Color {
        switch style {
        case .blue:
            return toolBlue
        case .orange:
            return toolOrange
        case .biology:
            return brand
        }
    }

    static func accentTint(for style: HomeAccentStyle) -> Color {
        switch style {
        case .blue:
            return toolBlueTint
        case .orange:
            return toolOrangeTint
        case .biology:
            return biologyTint
        }
    }
}
