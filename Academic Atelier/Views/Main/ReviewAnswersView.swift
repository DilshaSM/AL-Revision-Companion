import SwiftUI

struct ReviewAnswersView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: ReviewAnswersContent
    private let actions: ReviewAnswersActions

    init(content: ReviewAnswersContent, actions: ReviewAnswersActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                scoreHeader
                reviewCards
                recommendationCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 88)
        }
        .background(SubjectsPalette.canvas.ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            topBar
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

private extension ReviewAnswersView {
    var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(SubjectsPalette.brandBright)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Review Answers")
                    .font(AppTypography.subjectQuizReviewTopBarTitle)
                    .foregroundStyle(SubjectsPalette.ink)

                Text(content.subtitle.uppercased())
                    .font(AppTypography.subjectQuizReviewTopBarSubtitle)
                    .tracking(1.0)
                    .foregroundStyle(SubjectsPalette.secondaryMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .background(SubjectsPalette.canvas)
    }

    var scoreHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(content.subjectTitle)
                    .font(AppTypography.subjectQuizReviewSubjectTitle)
                    .tracking(-0.6)
                    .foregroundStyle(SubjectsPalette.ink)

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(content.scoreText)
                        .font(AppTypography.subjectQuizReviewScoreValue)
                        .foregroundStyle(SubjectsPalette.brandBright)
                    Text("SCORE")
                        .font(AppTypography.subjectQuizReviewScoreLabel)
                        .tracking(1.2)
                        .foregroundStyle(SubjectsPalette.muted)
                }
            }

            GeometryReader { proxy in
                Capsule(style: .continuous)
                    .fill(SubjectsPalette.quizProgressTrack)
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(SubjectsPalette.brandBright)
                            .frame(width: proxy.size.width * CGFloat(Int(content.scoreText.replacingOccurrences(of: "%", with: "")) ?? 0) / 100.0)
                    }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 18)
    }

    var reviewCards: some View {
        VStack(spacing: 18) {
            ForEach(content.questions) { question in
                ReviewAnswerCard(question: question)
            }
        }
    }

    var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("IMPROVE YOUR SCORE")
                .font(AppTypography.subjectQuizReviewRecommendationLabel)
                .tracking(0.8)
                .foregroundStyle(SubjectsPalette.muted)

            Text(content.recommendationText)
                .font(AppTypography.subjectQuizReviewRecommendationBody)
                .foregroundStyle(SubjectsPalette.muted)
                .fixedSize(horizontal: false, vertical: true)

            Button {
            } label: {
                Text("View Recommendations")
                    .font(AppTypography.subjectQuizReviewRecommendationAction)
                    .foregroundStyle(SubjectsPalette.brandDark)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(SubjectsPalette.reviewRecommendationBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(SubjectsPalette.reviewRecommendationStroke, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    var bottomBar: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Text("Back to Results")
                    .font(AppTypography.subjectQuizReviewFooterPrimary)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(SubjectsPalette.brandBright)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                actions.onTapNextTopic()
            } label: {
                Text("Next Topic")
                    .font(AppTypography.subjectQuizReviewFooterSecondary)
                    .foregroundStyle(SubjectsPalette.ink)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(content.nextTopicQuizContent == nil ? SubjectsPalette.lockedBackground : Color(uiColor: .init(white: 0.92, alpha: 1)))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(content.nextTopicQuizContent == nil)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
    }
}

struct ReviewAnswersActions {
    var onTapNextTopic: () -> Void = {}
}

private struct ReviewAnswerCard: View {
    let question: ReviewAnswersContent.ReviewQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(String(format: "QUESTION %02d", question.index))
                    .font(AppTypography.subjectQuizReviewQuestionLabel)
                    .tracking(1.2)
                    .foregroundStyle(SubjectsPalette.secondaryMuted)

                Spacer(minLength: 12)

                statusPill
            }

            Text(question.prompt)
                .font(AppTypography.subjectQuizReviewQuestionTitle)
                .foregroundStyle(SubjectsPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            answerBlock(
                label: "YOUR ANSWER",
                value: question.yourAnswer,
                tint: question.isCorrect ? SubjectsPalette.brandBright : SubjectsPalette.resultIncorrect,
                background: SubjectsPalette.reviewAnswerBackground,
                iconSystemName: question.isCorrect ? "checkmark.circle.fill" : "xmark",
                iconTint: question.isCorrect ? SubjectsPalette.resultCorrect : SubjectsPalette.resultIncorrect
            )

            if !question.isCorrect {
                answerBlock(
                    label: "CORRECT ANSWER",
                    value: question.correctAnswer,
                    tint: SubjectsPalette.resultCorrect,
                    background: SubjectsPalette.reviewCorrectAnswerBackground,
                    iconSystemName: "checkmark.seal.fill",
                    iconTint: SubjectsPalette.resultCorrect
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("EXPLANATION")
                    .font(AppTypography.subjectQuizReviewExplanationLabel)
                    .tracking(1.1)
                    .foregroundStyle(SubjectsPalette.muted.opacity(0.85))

                Text(question.explanation)
                    .font(AppTypography.subjectQuizReviewExplanationBody)
                    .foregroundStyle(SubjectsPalette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    var statusPill: some View {
        HStack(spacing: 6) {
            Image(systemName: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12, weight: .bold))
            Text(question.isCorrect ? "CORRECT" : "INCORRECT")
                .font(AppTypography.subjectQuizReviewStatusPill)
                .tracking(0.8)
        }
        .foregroundStyle(question.isCorrect ? SubjectsPalette.resultCorrect : SubjectsPalette.resultIncorrect)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(question.isCorrect ? SubjectsPalette.resultCorrectBackground : SubjectsPalette.resultIncorrectBackground)
        .clipShape(Capsule())
    }

    func answerBlock(
        label: String,
        value: String,
        tint: Color,
        background: Color,
        iconSystemName: String,
        iconTint: Color
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(AppTypography.subjectQuizReviewAnswerLabel)
                    .tracking(0.8)
                    .foregroundStyle(SubjectsPalette.muted)
                Text(value)
                    .font(AppTypography.subjectQuizReviewAnswerValue)
                    .foregroundStyle(tint)
            }

            Spacer(minLength: 12)

            Image(systemName: iconSystemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconTint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
