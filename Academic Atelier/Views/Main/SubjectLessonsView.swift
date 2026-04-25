import SwiftUI

struct SubjectLessonsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    @StateObject private var viewModel: SubjectLessonsViewModel

    private let subject: SubjectsTabContent.Subject
    private let actions: SubjectLessonsActions

    init(subject: SubjectsTabContent.Subject, actions: SubjectLessonsActions = .init()) {
        self.subject = subject
        self.actions = actions
        _viewModel = StateObject(wrappedValue: SubjectLessonsViewModel(subject: subject))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    statusSection

                    if let content = viewModel.content {
                        heroCard(content: content)
                        unitsSection(content: content)
                    } else if !viewModel.isLoading {
                        Text("No lessons are available for this subject.")
                            .font(.footnote)
                            .foregroundStyle(SubjectsPalette.muted)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 80)
            }
            .refreshable {
                await load(forceRefresh: true)
            }
        }
        .background(SubjectsPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task(id: refreshCenter.subjectsToken) {
            await load(forceRefresh: viewModel.content != nil)
        }
    }
}

private extension SubjectLessonsView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(SubjectsPalette.topBarTint)
        }
        .frame(height: 104)
        .overlay {
            HStack(spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(SubjectsPalette.ink)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.plain)

                Text(viewModel.content?.title ?? subject.title)
                    .font(AppTypography.subjectLessonsTopBarTitle)
                    .tracking(-0.6)
                    .foregroundStyle(SubjectsPalette.ink)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading subject lessons...")
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.muted)
            }
        } else if !viewModel.errorMessage.isEmpty {
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
                .foregroundStyle(SubjectsPalette.brand)
            }
        }
    }

    func heroCard(content: SubjectLessonsContent) -> some View {
        let currentLesson = content.units
            .flatMap(\.lessons)
            .first(where: \.isInProgress) ?? content.units
            .flatMap(\.lessons)
            .first(where: \.canStart)

        return ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [SubjectsPalette.brandBright, SubjectsPalette.brandDark],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 320
                    )
                )

            Image(systemName: content.hero.backgroundSymbolName)
                .font(.system(size: 120, weight: .regular))
                .foregroundStyle(.white.opacity(0.08))
                .offset(x: 18, y: 18)
                .padding(.trailing, -10)
        }
        .frame(maxWidth: .infinity, minHeight: 216, alignment: .topLeading)
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Text(content.hero.eyebrow.uppercased())
                    .font(AppTypography.subjectLessonsHeroEyebrow)
                    .tracking(2.0)
                    .foregroundStyle(.white.opacity(0.7))

                Text(content.hero.title)
                    .font(AppTypography.subjectLessonsHeroTitle)
                    .tracking(-0.6)
                    .foregroundStyle(.white)
                    .padding(.top, 23)

                HStack(spacing: 16) {
                    GeometryReader { proxy in
                        Capsule(style: .continuous)
                            .fill(SubjectsPalette.heroTrack)
                            .overlay(alignment: .leading) {
                                Capsule(style: .continuous)
                                    .fill(.white)
                                    .frame(width: proxy.size.width * min(max(content.hero.progress, 0), 1))
                                    .shadow(color: .white.opacity(0.6), radius: 15, x: 0, y: 0)
                            }
                    }
                    .frame(height: 4)

                    Text(content.hero.progressText)
                        .font(AppTypography.subjectLessonsHeroProgress)
                        .foregroundStyle(.white)
                }
                .padding(.top, 40)

                Button {
                    guard let currentLesson else { return }
                    handleTapLesson(currentLesson)
                } label: {
                    HStack(spacing: 12) {
                        if viewModel.pendingLessonID == currentLesson?.id {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Text(currentLesson?.title ?? content.hero.currentLessonTitle)
                            .font(AppTypography.subjectLessonsHeroCurrentLesson)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(SubjectsPalette.heroPillBackground)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(SubjectsPalette.heroPillBorder, lineWidth: 1)
                    }
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(currentLesson == nil || viewModel.pendingLessonID == currentLesson?.id)
                .padding(.top, 32)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)
        }
        .shadow(color: SubjectsPalette.brand.opacity(0.20), radius: 50, x: 0, y: 25)
    }

    func unitsSection(content: SubjectLessonsContent) -> some View {
        VStack(alignment: .leading, spacing: 64) {
            ForEach(content.units) { unit in
                VStack(alignment: .leading, spacing: 19.75) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(unit.title.uppercased())
                            .font(AppTypography.subjectLessonsUnitTitle)
                            .tracking(1.65)
                            .foregroundStyle(SubjectsPalette.muted.opacity(0.8))

                        Spacer(minLength: 12)

                        if let lessonCountText = unit.lessonCountText {
                            Text(lessonCountText.uppercased())
                                .font(AppTypography.subjectLessonsUnitCount)
                                .foregroundStyle(SubjectsPalette.muted.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 4) {
                        ForEach(unit.lessons) { lesson in
                            SubjectLessonRow(
                                lesson: lesson,
                                isPending: viewModel.pendingLessonID == lesson.id
                            ) {
                                handleTapLesson(lesson)
                            }
                        }
                    }
                }
            }
        }
    }

    func load(forceRefresh: Bool = false) async {
        await viewModel.load(forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }

    func handleTapLesson(_ lesson: SubjectLessonsContent.Lesson) {
        Task {
            guard let quizContent = await viewModel.startLesson(lesson) else {
                if viewModel.requiresSignOut {
                    session.signOut()
                }
                return
            }

            actions.onOpenQuiz(quizContent)
        }
    }
}

struct SubjectLessonsActions {
    var onOpenQuiz: (LessonQuizContent) -> Void = { _ in }
}

private struct SubjectLessonRow: View {
    let lesson: SubjectLessonsContent.Lesson
    let isPending: Bool
    let action: () -> Void

    var body: some View {
        Group {
            switch lesson.state {
            case let .completed(detailText):
                rowButton(
                    iconName: isPending ? nil : "checkmark.circle.fill",
                    iconTint: SubjectsPalette.completedForeground,
                    iconBackground: SubjectsPalette.completedBackground,
                    titleFont: AppTypography.subjectLessonsRowTitle,
                    title: lesson.title,
                    detailText: detailText,
                    trailingView: AnyView(trailingContent)
                )

            case let .inProgress(progress, progressText):
                rowButton(
                    iconName: isPending ? nil : "play.fill",
                    iconTint: SubjectsPalette.brand,
                    iconBackground: SubjectsPalette.badgeBackground,
                    titleFont: AppTypography.subjectLessonsInProgressTitle,
                    title: lesson.title,
                    detailText: progressText,
                    progress: progress,
                    trailingView: AnyView(trailingContent)
                )

            case let .available(detailText):
                rowButton(
                    iconName: isPending ? nil : "book.fill",
                    iconTint: SubjectsPalette.brand,
                    iconBackground: SubjectsPalette.badgeBackground,
                    titleFont: AppTypography.subjectLessonsRowTitle,
                    title: lesson.title,
                    detailText: detailText,
                    trailingView: AnyView(trailingContent)
                )

            case let .locked(detailText):
                HStack(spacing: 20) {
                    Circle()
                        .fill(SubjectsPalette.lockedBackground)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(SubjectsPalette.lockedForeground)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(lesson.title)
                            .font(AppTypography.subjectLessonsRowTitle)
                            .foregroundStyle(SubjectsPalette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(detailText)
                            .font(AppTypography.subjectLessonsRowDetail)
                            .foregroundStyle(SubjectsPalette.muted.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 19)
                .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
                .background(SubjectsPalette.surfaceMuted.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var trailingContent: some View {
        Group {
            if isPending {
                ProgressView()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(SubjectsPalette.lockedForeground)
            }
        }
    }

    private func rowButton(
        iconName: String?,
        iconTint: Color,
        iconBackground: Color,
        titleFont: Font,
        title: String,
        detailText: String,
        progress: Double? = nil,
        trailingView: AnyView
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)
                    .overlay {
                        if let iconName {
                            Image(systemName: iconName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(iconTint)
                        } else {
                            ProgressView()
                                .tint(iconTint)
                        }
                    }

                VStack(alignment: .leading, spacing: progress == nil ? 2 : 14) {
                    Text(title)
                        .font(titleFont)
                        .foregroundStyle(SubjectsPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let progress {
                        HStack(spacing: 20) {
                            GeometryReader { proxy in
                                Capsule(style: .continuous)
                                    .fill(SubjectsPalette.progressTrack)
                                    .overlay(alignment: .leading) {
                                        Capsule(style: .continuous)
                                            .fill(SubjectsPalette.brand)
                                            .frame(width: proxy.size.width * min(max(progress, 0), 1))
                                    }
                            }
                            .frame(width: 140, height: 6)

                            Text(detailText.uppercased())
                                .font(AppTypography.subjectLessonsInProgressValue)
                                .tracking(0.45)
                                .foregroundStyle(SubjectsPalette.brand)
                        }
                    } else {
                        Text(detailText)
                            .font(AppTypography.subjectLessonsRowDetail)
                            .foregroundStyle(SubjectsPalette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                trailingView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 19)
            .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
            .background(SubjectsPalette.surfaceMuted.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isPending || !lesson.canStart)
        .opacity(lesson.canStart ? 1 : 0.7)
    }
}
