import SwiftUI

struct QuizResultView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: QuizResultContent
    private let actions: QuizResultActions

    init(content: QuizResultContent, actions: QuizResultActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                heroSection
                summarySection
                detailSection
                actionSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 72)
        }
        .background(SubjectsPalette.canvas.ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            topBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

private extension QuizResultView {
    var topBar: some View {
        HStack {
            Spacer()

            Text("Results")
                .font(AppTypography.subjectQuizResultTopBarTitle)
                .foregroundStyle(SubjectsPalette.ink)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .font(AppTypography.subjectQuizResultTopBarAction)
            .foregroundStyle(SubjectsPalette.brand)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }

    var heroSection: some View {
        VStack(spacing: 16) {
            Text("Quiz Completed")
                .font(AppTypography.subjectQuizResultHeroTitle)
                .tracking(-0.9)
                .foregroundStyle(SubjectsPalette.ink)

            Text(content.topicTitle)
                .font(AppTypography.subjectQuizResultMessage)
                .foregroundStyle(SubjectsPalette.muted)

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 168, height: 168)
                        .shadow(color: Color.black.opacity(0.04), radius: 24, x: 0, y: 12)

                    VStack(spacing: 4) {
                        Text(content.scoreText)
                            .font(AppTypography.subjectQuizResultScoreValue)
                            .foregroundStyle(SubjectsPalette.brandBright)

                        Text(content.masteryLevel.uppercased())
                            .font(AppTypography.subjectQuizResultScoreLabel)
                            .tracking(2)
                            .foregroundStyle(SubjectsPalette.muted)
                    }
                }

                VStack(spacing: 8) {
                    Text(content.headline)
                        .font(AppTypography.subjectQuizResultHeadline)
                        .foregroundStyle(SubjectsPalette.ink)

                    Text(content.message)
                        .font(AppTypography.subjectQuizResultMessage)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SubjectsPalette.muted)
                }

                HStack(spacing: 20) {
                    statCard(
                        title: "CORRECT",
                        value: "\(content.correctCount)",
                        foreground: SubjectsPalette.resultCorrect,
                        background: SubjectsPalette.resultCorrectBackground
                    )
                    statCard(
                        title: "INCORRECT",
                        value: "\(content.incorrectCount)",
                        foreground: SubjectsPalette.resultIncorrect,
                        background: SubjectsPalette.resultIncorrectBackground
                    )
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 16, x: 0, y: 8)
        }
    }

    func statCard(title: String, value: String, foreground: Color, background: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppTypography.subjectQuizResultStatLabel)
                .tracking(1.5)
            Text(value)
                .font(AppTypography.subjectQuizResultStatValue)
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, minHeight: 96)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    var summarySection: some View {
        VStack(spacing: 14) {
            detailCard(
                title: "TIME TAKEN",
                value: content.timeTakenText,
                systemName: "timer",
                tint: SubjectsPalette.brandBright
            )

            HStack(spacing: 14) {
                detailCard(
                    title: "SUBJECT PROGRESS",
                    value: content.subjectProgressText,
                    systemName: "chart.bar.fill",
                    tint: SubjectsPalette.brandBright
                )

                detailCard(
                    title: "MASTERY",
                    value: content.masteryLevel,
                    systemName: "sparkles",
                    tint: SubjectsPalette.resultCorrect
                )
            }
        }
    }

    func detailCard(title: String, value: String, systemName: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(SubjectsPalette.badgeBackground)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.subjectQuizResultTimeLabel)
                    .tracking(1.4)
                    .foregroundStyle(SubjectsPalette.muted)

                Text(value)
                    .font(AppTypography.subjectQuizResultTimeValue)
                    .foregroundStyle(SubjectsPalette.ink)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(SubjectsPalette.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    var detailSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            detailCard(
                title: "LESSON COMPLETION",
                value: content.completedLessonsText,
                systemName: "checkmark.seal.fill",
                tint: SubjectsPalette.resultCorrect
            )

            detailCard(
                title: "STUDY SESSION",
                value: content.studySessionText,
                systemName: "clock.arrow.circlepath",
                tint: SubjectsPalette.brandBright
            )

            if let submittedAtText = content.submittedAtText {
                detailCard(
                    title: "SUBMITTED",
                    value: submittedAtText,
                    systemName: "calendar",
                    tint: SubjectsPalette.brandBright
                )
            }
        }
    }

    var actionSection: some View {
        VStack(spacing: 12) {
            Button {
                actions.onTapNextTopic()
            } label: {
                Text(content.nextTopicTitle.map { "Next Topic: \($0)" } ?? "Next Topic")
                    .font(AppTypography.subjectQuizResultPrimaryButton)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(content.nextLesson == nil ? SubjectsPalette.quizNextDisabled : SubjectsPalette.brandBright)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: content.nextLesson == nil ? .clear : SubjectsPalette.quizPrimaryShadow, radius: 20, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(content.nextLesson == nil)

            HStack(spacing: 20) {
                secondaryActionButton(
                    title: "Review Answers",
                    systemName: "eye",
                    tint: SubjectsPalette.brandBright
                ) {
                    actions.onTapReviewAnswers()
                }

                secondaryActionButton(
                    title: "Retry Quiz",
                    systemName: "arrow.clockwise",
                    tint: SubjectsPalette.ink
                ) {
                    actions.onTapRetryQuiz()
                }
            }
        }
    }

    func secondaryActionButton(
        title: String,
        systemName: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .semibold))
                Text(title.uppercased())
                    .font(AppTypography.subjectQuizResultSecondaryButton)
                    .tracking(0.6)
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct QuizResultActions {
    var onTapNextTopic: () -> Void = {}
    var onTapReviewAnswers: () -> Void = {}
    var onTapRetryQuiz: () -> Void = {}
}
