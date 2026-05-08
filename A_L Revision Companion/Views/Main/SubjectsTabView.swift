import SwiftUI

struct SubjectsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    @StateObject private var viewModel = SubjectsViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?
    @State private var path: [SubjectsTabRoute] = []
    @State private var routeErrorMessage = ""

    private let subjectsService = SubjectsService()

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    private var content: SubjectsTabContent? {
        viewModel.content
    }

    private var titleText: String {
        content?.title ?? "Your Subjects"
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        overviewCard
                        statusSection
                        subjectsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
                .refreshable {
                    await loadSubjects(forceRefresh: true)
                }
            }
            .background(SubjectsPalette.canvas.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SubjectsTabRoute.self) { route in
                switch route {
                case let .lessons(subject):
                    SubjectLessonsView(
                        subject: subject,
                        actions: .init(
                            onOpenQuiz: { quizContent in
                                path.append(.quiz(quizContent))
                            }
                        )
                    )
                case let .quiz(content):
                    LessonQuizView(
                        content: content,
                        actions: .init(
                            onComplete: { resultContent in
                                if !path.isEmpty {
                                    path.removeLast()
                                }
                                path.append(.quizResult(resultContent))
                            }
                        )
                    )
                case let .quizResult(content):
                    QuizResultView(
                        content: content,
                        actions: .init(
                            onTapNextTopic: {
                                openNextLesson(from: content, removingRoutes: 1)
                            },
                            onTapReviewAnswers: {
                                path.append(.reviewAnswers(content))
                            },
                            onTapRetryQuiz: {
                                if !path.isEmpty {
                                    path.removeLast()
                                }
                                path.append(.quiz(content.retryQuizContent))
                            }
                        )
                    )
                case let .reviewAnswers(result):
                    ReviewAnswersView(
                        result: result,
                        actions: .init(
                            onTapNextTopic: {
                                openNextLesson(from: result, removingRoutes: 2)
                            }
                        )
                    )
                }
            }
            .task(id: refreshCenter.subjectsToken) {
                await loadSubjects(forceRefresh: viewModel.content != nil)
            }
            .alert(
                "Unable to Continue",
                isPresented: Binding(
                    get: { !routeErrorMessage.isEmpty },
                    set: { isPresented in
                        if !isPresented {
                            routeErrorMessage = ""
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(routeErrorMessage)
            }
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
        .onChange(of: routeErrorMessage) { _, message in
            guard !message.isEmpty else { return }
            Task { @MainActor in
                AccessibilitySupport.announce(message)
            }
        }
        .task(id: router.pendingDeepLink) {
            await consumePendingDeepLinkIfNeeded()
        }
    }
}

private extension SubjectsTabView {
    var topBar: some View {
        VStack {
            Spacer()

            HStack {
                Text(titleText)
                    .font(AppTypography.subjectsTopBarTitle)
                    .tracking(-0.5)
                    .foregroundStyle(SubjectsPalette.titleBlue)
                    .accessibilityHeader()
                    .accessibilityFocused($focusedElement, equals: .title)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(height: 96)
    }

    var overviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text((content?.streamName ?? "Selected Stream").uppercased())
                .font(AppTypography.subjectsAssessmentEyebrow)
                .tracking(1.0)
                .foregroundStyle(SubjectsPalette.brand.opacity(0.7))

            Text(content?.subtitle ?? "Load the subjects available for your current stream.")
                .font(AppTypography.subjectsAssessmentTitle)
                .foregroundStyle(SubjectsPalette.ink)

            Text("\(content?.subjects.count ?? 0) subjects available")
                .font(AppTypography.subjectsAssessmentSubtitle)
                .foregroundStyle(SubjectsPalette.muted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(SubjectsPalette.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading subjects...")
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.muted)
            }
        } else if !viewModel.errorMessage.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)
                    .accessibilityFocused($focusedElement, equals: .status)

                Button("Retry") {
                    Task {
                        await loadSubjects(forceRefresh: true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SubjectsPalette.brand)
            }
        }
    }

    var subjectsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text((content?.subjectsSectionTitle ?? "Active Curriculum").uppercased())
                .font(AppTypography.subjectsSectionTitle)
                .tracking(1.4)
                .foregroundStyle(SubjectsPalette.muted)
                .padding(.horizontal, 4)
                .accessibilityHeader()

            if let subjects = content?.subjects, !subjects.isEmpty {
                VStack(spacing: 20) {
                    ForEach(subjects) { subject in
                        SubjectCard(subject: subject) {
                            path.append(.lessons(subject))
                        }
                    }
                }
            } else if !viewModel.isLoading {
                Text("No subjects are available for the selected stream.")
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.muted)
                    .padding(.horizontal, 4)
            }
        }
    }

    func loadSubjects(forceRefresh: Bool = false) async {
        await viewModel.load(for: session.currentUser, forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }

    func openNextLesson(from result: QuizResultContent, removingRoutes routeCount: Int) {
        guard let nextLesson = result.nextLesson else { return }

        Task {
            do {
                let subjectTree = try await subjectsService.getSubjectUnits(subjectID: result.retryQuizContent.subjectID)
                let subjectContent = SubjectLessonsContent.build(from: subjectTree)

                guard let refreshedLesson = subjectContent.units
                    .flatMap(\.lessons)
                    .first(where: { $0.id == nextLesson.id }) else {
                    routeErrorMessage = "The next lesson could not be found."
                    return
                }

                guard let activeTopic = refreshedLesson.firstActiveTopic else {
                    routeErrorMessage = "No active topic is available for the next lesson yet."
                    return
                }

                _ = try await subjectsService.openLesson(lessonID: refreshedLesson.id)
                refreshCenter.didOpenLesson()
                let quizPayload = try await subjectsService.getTopicQuiz(topicID: activeTopic.id)
                let nextQuizContent = LessonQuizContent.build(
                    from: quizPayload,
                    lesson: refreshedLesson,
                    nextLesson: subjectContent.nextLesson(after: refreshedLesson.id)
                )

                let safeRemoveCount = min(routeCount, path.count)
                if safeRemoveCount > 0 {
                    path.removeLast(safeRemoveCount)
                }
                path.append(.quiz(nextQuizContent))
            } catch let error as APIError {
                if error.requiresSignOut {
                    session.signOut()
                } else {
                    routeErrorMessage = error.localizedDescription
                }
            } catch {
                routeErrorMessage = error.localizedDescription
            }
        }
    }

    func consumePendingDeepLinkIfNeeded() async {
        guard let deepLink = router.pendingDeepLink else { return }

        switch deepLink {
        case let .subject(subjectId):
            await openSubject(subjectId: subjectId)
        case let .continueLearning(subjectId, lessonId, topicId):
            guard let subjectId else {
                router.clearPendingDeepLink()
                return
            }
            await openContinueLearning(
                subjectId: subjectId,
                lessonId: lessonId,
                topicId: topicId
            )
        case let .recommendation(subjectId, _):
            guard let subjectId else {
                router.clearPendingDeepLink()
                return
            }
            await openSubject(subjectId: subjectId)
        case .home, .progress, .subjects:
            router.clearPendingDeepLink()
        }
    }

    func openSubject(subjectId: Int) async {
        if content == nil {
            await loadSubjects(forceRefresh: false)
        }

        guard let subject = viewModel.content?.subjects.first(where: { $0.id == subjectId }) else {
            router.clearPendingDeepLink()
            return
        }

        path = [.lessons(subject)]
        router.clearPendingDeepLink()
    }

    func openContinueLearning(subjectId: Int, lessonId: Int?, topicId: Int?) async {
        if content == nil {
            await loadSubjects(forceRefresh: false)
        }

        guard let subject = viewModel.content?.subjects.first(where: { $0.id == subjectId }) else {
            router.clearPendingDeepLink()
            return
        }

        guard lessonId != nil || topicId != nil else {
            path = [.lessons(subject)]
            router.clearPendingDeepLink()
            return
        }

        do {
            let subjectTree = try await subjectsService.getSubjectUnits(subjectID: subjectId)
            let subjectContent = SubjectLessonsContent.build(from: subjectTree)
            let lessons = subjectContent.units.flatMap(\.lessons)

            guard let targetLesson = lessons.first(where: { lesson in
                if let lessonId, lesson.id == lessonId {
                    return true
                }

                if let topicId, lesson.topics.contains(where: { $0.id == topicId }) {
                    return true
                }

                return false
            }) else {
                path = [.lessons(subject)]
                router.clearPendingDeepLink()
                return
            }

            let openPayload = try await subjectsService.openLesson(lessonID: targetLesson.id)
            let updatedSubjectContent = subjectContent.applying(progress: openPayload.lessonProgress)
            let refreshedLesson = updatedSubjectContent.units
                .flatMap(\.lessons)
                .first(where: { $0.id == targetLesson.id }) ?? targetLesson

            guard let targetTopic = (topicId.flatMap { requestedTopicID in
                refreshedLesson.topics.first(where: { $0.id == requestedTopicID })
            }) ?? refreshedLesson.firstActiveTopic else {
                path = [.lessons(subject)]
                router.clearPendingDeepLink()
                return
            }

            let quizPayload = try await subjectsService.getTopicQuiz(topicID: targetTopic.id)
            let quizContent = LessonQuizContent.build(
                from: quizPayload,
                lesson: refreshedLesson,
                nextLesson: updatedSubjectContent.nextLesson(after: refreshedLesson.id)
            )

            try? LocalPersistenceService(context: modelContext).saveStudyActivity(
                activityType: "lessonOpened",
                subjectId: subject.id,
                subjectName: subject.title,
                topicId: quizContent.topicID,
                topicTitle: quizContent.topicTitle
            )

            refreshCenter.didOpenLesson()
            path = [.lessons(subject), .quiz(quizContent)]
            router.clearPendingDeepLink()
        } catch let error as APIError {
            if error.requiresSignOut {
                session.signOut()
            } else {
                routeErrorMessage = error.localizedDescription
            }
        } catch {
            routeErrorMessage = error.localizedDescription
        }
    }
}

private enum SubjectsTabRoute: Hashable {
    case lessons(SubjectsTabContent.Subject)
    case quiz(LessonQuizContent)
    case quizResult(QuizResultContent)
    case reviewAnswers(QuizResultContent)
}

private struct SubjectCard: View {
    let subject: SubjectsTabContent.Subject
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SubjectsPalette.badgeBackground)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: subject.iconSystemName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(SubjectsPalette.brand)
                            .accessibilityHidden(true)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(subject.title)
                        .font(AppTypography.subjectsCardTitle)
                        .tracking(-0.5)
                        .foregroundStyle(SubjectsPalette.ink)

                    Text(subject.subtitle)
                        .font(AppTypography.subjectsCardMeta)
                        .foregroundStyle(SubjectsPalette.secondaryMuted)

                    Text("Open subject")
                        .font(AppTypography.subjectsCardEyebrow)
                        .foregroundStyle(SubjectsPalette.brand.opacity(0.7))
                        .padding(.top, 2)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SubjectsPalette.lockedForeground)
                    .accessibilityHidden(true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(subject.title)
        .accessibilityValue(subject.subtitle)
        .accessibilityHint("Open this subject.")
    }
}

private extension APIError {
    var requiresSignOut: Bool {
        switch self {
        case .missingToken, .unauthorized:
            return true
        default:
            return false
        }
    }
}
