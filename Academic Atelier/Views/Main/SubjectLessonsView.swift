import SwiftUI

struct SubjectLessonsView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: SubjectLessonsContent
    private let actions: SubjectLessonsActions

    init(content: SubjectLessonsContent, actions: SubjectLessonsActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 64) {
                    heroCard
                    unitsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 80)
            }
        }
        .background(SubjectsPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
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

                Text(content.title)
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

    var heroCard: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    actions.onTapCurrentLesson()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(content.hero.currentLessonTitle)
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
                .padding(.top, 32)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)
        }
        .shadow(color: SubjectsPalette.brand.opacity(0.20), radius: 50, x: 0, y: 25)
    }

    var unitsSection: some View {
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
                            SubjectLessonRow(lesson: lesson) {
                                actions.onTapLesson(lesson)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SubjectLessonsActions {
    var onTapCurrentLesson: () -> Void = {}
    var onTapLesson: (SubjectLessonsContent.Lesson) -> Void = { _ in }
}

private struct SubjectLessonRow: View {
    let lesson: SubjectLessonsContent.Lesson
    let action: () -> Void

    var body: some View {
        switch lesson.state {
        case let .completed(detailText):
            Button(action: action) {
                HStack(spacing: 20) {
                    Circle()
                        .fill(SubjectsPalette.completedBackground)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(SubjectsPalette.completedForeground)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(lesson.title)
                            .font(AppTypography.subjectLessonsRowTitle)
                            .foregroundStyle(SubjectsPalette.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(detailText)
                            .font(AppTypography.subjectLessonsRowDetail)
                            .foregroundStyle(SubjectsPalette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(SubjectsPalette.lockedForeground)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 19)
                .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
                .background(SubjectsPalette.surfaceMuted.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

        case let .inProgress(progress, progressText):
            Button(action: action) {
                HStack(spacing: 20) {
                    Circle()
                        .fill(SubjectsPalette.badgeBackground)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(SubjectsPalette.brand)
                        }

                    VStack(alignment: .leading, spacing: 14) {
                        Text(lesson.title)
                            .font(AppTypography.subjectLessonsInProgressTitle)
                            .foregroundStyle(SubjectsPalette.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)

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

                            Text(progressText.uppercased())
                                .font(AppTypography.subjectLessonsInProgressValue)
                                .tracking(0.45)
                                .foregroundStyle(SubjectsPalette.brand)
                        }
                    }

                    Spacer(minLength: 12)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SubjectsPalette.brand)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 19)
                .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
                .background(AppColors.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: SubjectsPalette.cardShadow, radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)

        case .locked:
            HStack(spacing: 20) {
                Circle()
                    .fill(SubjectsPalette.lockedBackground)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SubjectsPalette.muted)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(AppTypography.subjectLessonsRowTitle)
                        .foregroundStyle(SubjectsPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Locked")
                        .font(AppTypography.subjectLessonsRowDetail)
                        .foregroundStyle(SubjectsPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 19)
            .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
            .background(AppColors.cardBackground.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(0.4)
        }
    }
}
