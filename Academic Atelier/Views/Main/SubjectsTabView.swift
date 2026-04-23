import SwiftUI

struct SubjectsTabView: View {
    @State private var path: [SubjectsTabRoute] = []

    private let content: SubjectsTabContent

    init(content: SubjectsTabContent = .placeholder) {
        self.content = content
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        assessmentCard
                        subjectsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
            .background(SubjectsPalette.canvas.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SubjectsTabRoute.self) { route in
                switch route {
                case let .lessons(content):
                    SubjectLessonsView(
                        content: content,
                        actions: .init(
                            onTapCurrentLesson: {
                                guard
                                    let lesson = content.currentLesson,
                                    let quizContent = content.quizContent(for: lesson)
                                else { return }
                                path.append(.quiz(quizContent))
                            },
                            onTapLesson: { lesson in
                                guard let quizContent = content.quizContent(for: lesson) else { return }
                                path.append(.quiz(quizContent))
                            }
                        )
                    )
                case let .quiz(content):
                    LessonQuizView(
                        content: content,
                        actions: .init(
                            onComplete: { selectedOptionIDsByQuestionID in
                                let currentLesson = SubjectLessonsContent.Lesson(
                                    id: content.lessonID,
                                    title: content.lessonTitle,
                                    state: .completed(detailText: "Completed")
                                )
                                let nextTopicQuizContent = self.content
                                    .lessonsContent(forID: content.subjectID)?
                                    .nextLesson(after: currentLesson)
                                    .flatMap { self.content.lessonsContent(forID: content.subjectID)?.unlockedQuizContent(for: $0) }
                                let resultContent = QuizResultContent.build(
                                    from: content,
                                    selectedOptionIDsByQuestionID: selectedOptionIDsByQuestionID,
                                    nextTopicQuizContent: nextTopicQuizContent
                                )
                                path.removeLast()
                                path.append(.quizResult(resultContent))
                            }
                        )
                    )
                case let .quizResult(content):
                    QuizResultView(
                        content: content,
                        actions: .init(
                            onTapNextTopic: {
                                guard let nextTopic = content.nextTopicQuizContent else { return }
                                path.removeLast()
                                path.append(.quiz(nextTopic))
                            },
                            onTapReviewAnswers: {
                                path.append(.reviewAnswers(content.reviewContent))
                            },
                            onTapRetryQuiz: {
                                path.removeLast()
                                path.append(.quiz(content.retryQuizContent))
                            }
                        )
                    )
                case let .reviewAnswers(content):
                    ReviewAnswersView(
                        content: content,
                        actions: .init(
                            onTapNextTopic: {
                                guard let nextTopic = content.nextTopicQuizContent else { return }
                                if path.count >= 2 {
                                    path.removeLast(2)
                                }
                                path.append(.quiz(nextTopic))
                            }
                        )
                    )
                }
            }
        }
    }
}

private extension SubjectsTabView {
    var topBar: some View {
        VStack {
            Spacer()

            HStack {
                Text(content.title)
                    .font(AppTypography.subjectsTopBarTitle)
                    .tracking(-0.5)
                    .foregroundStyle(SubjectsPalette.titleBlue)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(height: 96)
    }

    var assessmentCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2.5) {
                Text(content.assessment.eyebrow.uppercased())
                    .font(AppTypography.subjectsAssessmentEyebrow)
                    .tracking(1.0)
                    .foregroundStyle(SubjectsPalette.brand.opacity(0.7))

                Text(content.assessment.title)
                    .font(AppTypography.subjectsAssessmentTitle)
                    .foregroundStyle(SubjectsPalette.ink)
                    .padding(.top, 8)

                Text(content.assessment.subtitle)
                    .font(AppTypography.subjectsAssessmentSubtitle)
                    .foregroundStyle(SubjectsPalette.muted)
                    .padding(.top, 2)
            }

            Spacer(minLength: 12)

            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(.white)
                    .frame(width: 40, height: 40)

                Image(systemName: content.assessment.symbolName)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(SubjectsPalette.brand)

                Text(content.assessment.badgeCountText)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(SubjectsPalette.brand)
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
            .frame(width: 56, height: 56)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(SubjectsPalette.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    var subjectsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text(content.subjectsSectionTitle.uppercased())
                    .font(AppTypography.subjectsSectionTitle)
                    .tracking(1.4)
                    .foregroundStyle(SubjectsPalette.muted)

                Spacer(minLength: 12)

                Text(content.subjectsActionTitle)
                    .font(AppTypography.subjectsSectionAction)
                    .foregroundStyle(SubjectsPalette.brand)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 30) {
                ForEach(content.subjects) { subject in
                    SubjectCard(subject: subject) {
                        handleSubjectTap(subject)
                    }
                }
            }
        }
    }

    func handleSubjectTap(_ subject: SubjectsTabContent.Subject) {
        guard let content = content.lessonsContent(for: subject) else { return }
        path.append(.lessons(content))
    }
}

private enum SubjectsTabRoute: Hashable {
    case lessons(SubjectLessonsContent)
    case quiz(LessonQuizContent)
    case quizResult(QuizResultContent)
    case reviewAnswers(ReviewAnswersContent)
}

private struct SubjectCard: View {
    let subject: SubjectsTabContent.Subject
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subject.title)
                            .font(AppTypography.subjectsCardTitle)
                            .tracking(-0.5)
                            .foregroundStyle(SubjectsPalette.ink)

                        Text(subject.lastActiveText)
                            .font(AppTypography.subjectsCardMeta)
                            .foregroundStyle(SubjectsPalette.secondaryMuted)
                    }

                    Spacer(minLength: 12)

                    Text(subject.levelText.uppercased())
                        .font(AppTypography.subjectsCardBadge)
                        .foregroundStyle(SubjectsPalette.badgeForeground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)
                        .background(SubjectsPalette.badgeBackground)
                        .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 0.5) {
                            Text(subject.nextLessonLabel.uppercased())
                                .font(AppTypography.subjectsCardEyebrow)
                                .foregroundStyle(SubjectsPalette.brand.opacity(0.7))

                            Text(subject.nextLessonTitle)
                                .font(AppTypography.subjectsCardLessonTitle)
                                .foregroundStyle(SubjectsPalette.ink)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer(minLength: 12)

                        Text(subject.progressText)
                            .font(AppTypography.subjectsCardProgressValue)
                            .foregroundStyle(SubjectsPalette.brand)
                    }

                    GeometryReader { proxy in
                        Capsule(style: .continuous)
                            .fill(SubjectsPalette.progressTrack)
                            .overlay(alignment: .leading) {
                                Capsule(style: .continuous)
                                    .fill(SubjectsPalette.brand)
                                    .frame(width: proxy.size.width * min(max(subject.progress, 0), 1))
                            }
                    }
                    .frame(height: 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, minHeight: 152.5, alignment: .topLeading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: SubjectsPalette.cardShadow, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
