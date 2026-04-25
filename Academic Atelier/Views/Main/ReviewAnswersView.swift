import SwiftUI

struct ReviewAnswersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel

    @StateObject private var viewModel = ReviewAnswersViewModel()

    private let result: QuizResultContent
    private let actions: ReviewAnswersActions

    init(result: QuizResultContent, actions: ReviewAnswersActions = .init()) {
        self.result = result
        self.actions = actions
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                scoreHeader
                statusSection

                if let review = viewModel.review {
                    reviewCards(review: review)
                    recommendationCard(review: review)
                }
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
        .task {
            await loadReview()
        }
        .refreshable {
            await loadReview(forceRefresh: true)
        }
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

                Text((viewModel.review?.subtitle ?? "Loading review").uppercased())
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
                Text(result.subjectTitle)
                    .font(AppTypography.subjectQuizReviewSubjectTitle)
                    .tracking(-0.6)
                    .foregroundStyle(SubjectsPalette.ink)

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.review?.scoreText ?? result.scoreText)
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
                            .frame(width: proxy.size.width * CGFloat(result.scorePercent) / 100.0)
                    }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.review == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading review...")
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.muted)
            }
            .padding(.horizontal, 18)
        } else if !viewModel.errorMessage.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)

                Button("Retry") {
                    Task {
                        await loadReview(forceRefresh: true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SubjectsPalette.brand)
            }
            .padding(.horizontal, 18)
        }
    }

    func reviewCards(review: ReviewAnswersContent) -> some View {
        VStack(spacing: 18) {
            ForEach(review.questions) { question in
                ReviewAnswerCard(question: question)
            }
        }
    }

    func recommendationCard(review: ReviewAnswersContent) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("IMPROVE YOUR SCORE")
                .font(AppTypography.subjectQuizReviewRecommendationLabel)
                .tracking(0.8)
                .foregroundStyle(SubjectsPalette.muted)

            Text(review.recommendationText)
                .font(AppTypography.subjectQuizReviewRecommendationBody)
                .foregroundStyle(SubjectsPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
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
                Text(viewModel.review?.nextTopicTitle ?? "Next Topic")
                    .font(AppTypography.subjectQuizReviewFooterSecondary)
                    .foregroundStyle(SubjectsPalette.ink)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(result.nextLesson == nil ? SubjectsPalette.lockedBackground : Color(uiColor: .init(white: 0.92, alpha: 1)))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(result.nextLesson == nil)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
    }

    func loadReview(forceRefresh: Bool = false) async {
        await viewModel.load(for: result, forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconSystemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(iconTint)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppTypography.subjectQuizReviewAnswerLabel)
                    .tracking(0.9)
                    .foregroundStyle(SubjectsPalette.muted.opacity(0.8))

                Text(value)
                    .font(AppTypography.subjectQuizReviewAnswerValue)
                    .foregroundStyle(tint)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
