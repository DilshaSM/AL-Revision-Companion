import SwiftUI

struct LessonQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    @StateObject private var viewModel = LessonQuizViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private let content: LessonQuizContent
    private let actions: LessonQuizActions

    @State private var currentQuestionIndex = 0
    @State private var selectedOptionIDsByQuestionID: [Int: Int] = [:]

    private enum FocusTarget: Hashable {
        case title
        case status
        case question
    }

    init(content: LessonQuizContent, actions: LessonQuizActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        Group {
            if content.questions.isEmpty {
                VStack(spacing: 16) {
                    Text("This quiz has no questions.")
                        .font(.headline)
                        .foregroundStyle(SubjectsPalette.ink)

                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(SubjectsPalette.brand)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(SubjectsPalette.canvas.ignoresSafeArea())
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        statusBanner
                        questionHeader
                        questionPrompt
                        optionsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
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
                .task(id: content.quizID) {
                    await startAttempt()
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
                .onChange(of: currentQuestionIndex) { _, newValue in
                    focusedElement = .question
                    Task { @MainActor in
                        AccessibilitySupport.announce("Question \(newValue + 1) of \(content.questions.count).")
                    }
                }
            }
        }
    }
}

private extension LessonQuizView {
    var currentQuestion: LessonQuizContent.Question {
        content.questions[currentQuestionIndex]
    }

    var currentQuestionNumber: Int {
        currentQuestionIndex + 1
    }

    var isOnFirstQuestion: Bool {
        currentQuestionIndex == 0
    }

    var isOnLastQuestion: Bool {
        currentQuestionIndex == content.questions.count - 1
    }

    var progressFraction: CGFloat {
        guard !content.questions.isEmpty else { return 0 }
        return CGFloat(currentQuestionNumber) / CGFloat(content.questions.count)
    }

    var primaryButtonTitle: String {
        if isOnLastQuestion {
            return viewModel.isSubmitting ? "Submitting..." : "Submit Quiz"
        }

        return "Next Question"
    }

    var canPerformPrimaryAction: Bool {
        if isOnLastQuestion {
            return viewModel.attemptID != nil && !viewModel.isSubmitting
        }

        return !viewModel.isSubmitting
    }

    var topBar: some View {
        HStack(spacing: 18) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SubjectsPalette.quizDismiss)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close quiz")
            .accessibilityHint("Return to the previous screen.")

            Capsule(style: .continuous)
                .fill(SubjectsPalette.quizProgressTrack)
                .frame(width: 163, height: 8)
                .overlay(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(SubjectsPalette.quizProgressFill)
                        .frame(width: 163.0 * progressFraction)
                }
                .accessibilityHidden(true)

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                Text(content.topicTitle.uppercased())
                    .font(AppTypography.subjectQuizTopBarMeta)
                    .tracking(1.6)
                    .foregroundStyle(SubjectsPalette.quizTopBarMeta)

                Text("\(formattedQuestionNumber(currentQuestionNumber)) / \(formattedQuestionNumber(content.questions.count))")
                    .font(AppTypography.subjectQuizTopBarCount)
                    .foregroundStyle(SubjectsPalette.quizTopBarCount)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quiz progress")
            .accessibilityValue("Question \(currentQuestionNumber) of \(content.questions.count) in \(content.topicTitle).")
            .accessibilityFocused($focusedElement, equals: .title)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay {
            SubjectsPalette.topBarTint.opacity(0.6)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    var statusBanner: some View {
        if viewModel.isStartingAttempt && viewModel.attemptID == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Preparing your quiz attempt...")
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.muted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Preparing your quiz attempt.")
            .accessibilityFocused($focusedElement, equals: .status)
        } else if !viewModel.errorMessage.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)

                if viewModel.attemptID == nil {
                    Button("Retry Start") {
                        Task {
                            await startAttempt(forceRestart: true)
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(SubjectsPalette.brand)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityFocused($focusedElement, equals: .status)
        }
    }

    var questionHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            (
                Text("Question ")
                    .foregroundStyle(SubjectsPalette.quizHeadlinePrimary)
                + Text(formattedQuestionNumber(currentQuestionNumber))
                    .foregroundStyle(SubjectsPalette.quizHeadlineAccent)
                + Text(" of ")
                    .foregroundStyle(SubjectsPalette.quizHeadlineMuted)
                + Text(formattedQuestionNumber(content.questions.count))
                    .foregroundStyle(SubjectsPalette.quizHeadlineCount)
            )
            .font(AppTypography.subjectQuizQuestionHeadline)
            .tracking(-0.9)
            .accessibilityLabel("Question \(currentQuestionNumber) of \(content.questions.count)")

            if let subtitle = content.topicSubtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.muted)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHeader()
    }

    var questionPrompt: some View {
        Text(currentQuestion.prompt)
            .font(AppTypography.subjectQuizQuestionBody)
            .foregroundStyle(SubjectsPalette.quizQuestionBody)
            .tracking(-0.6)
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(currentQuestion.prompt)
            .accessibilityFocused($focusedElement, equals: .question)
    }

    var optionsSection: some View {
        VStack(spacing: 16) {
            ForEach(currentQuestion.options) { option in
                QuizOptionRow(
                    title: option.text,
                    isSelected: selectedOptionIDsByQuestionID[currentQuestion.id] == option.id
                ) {
                    selectedOptionIDsByQuestionID[currentQuestion.id] = option.id
                    Task { @MainActor in
                        AccessibilitySupport.announce("Selected answer. \(option.text)")
                    }
                }
            }
        }
    }

    var bottomBar: some View {
        HStack(spacing: 14) {
            Button {
                guard !isOnFirstQuestion else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentQuestionIndex -= 1
                }
            } label: {
                Text("Previous")
                    .font(AppTypography.subjectQuizPreviousButton)
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(isOnFirstQuestion || viewModel.isSubmitting ? SubjectsPalette.quizPreviousDisabled : SubjectsPalette.quizPreviousLabel)
                    .frame(width: 118, height: 60)
            }
            .buttonStyle(.plain)
            .disabled(isOnFirstQuestion || viewModel.isSubmitting)
            .accessibilityHint("Go to the previous question.")

            Button {
                handlePrimaryAction()
            } label: {
                Text(primaryButtonTitle)
                    .font(AppTypography.subjectQuizNextButton)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 60)
                    .background(canPerformPrimaryAction ? SubjectsPalette.brandBright : SubjectsPalette.quizNextDisabled)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: canPerformPrimaryAction ? SubjectsPalette.quizPrimaryShadow : .clear, radius: 24, x: 0, y: 12)
            }
            .buttonStyle(.plain)
            .disabled(!canPerformPrimaryAction)
            .accessibilityHint(isOnLastQuestion ? "Submit your quiz answers." : "Go to the next question.")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 32)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(SubjectsPalette.quizFooterSeparator)
                .frame(height: 1)
                .allowsHitTesting(false)
        }
    }

    func startAttempt(forceRestart: Bool = false) async {
        if forceRestart {
            // Reset local state for a fresh start request.
            selectedOptionIDsByQuestionID = [:]
        }

        await viewModel.startAttemptIfNeeded(for: content)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }

    func handlePrimaryAction() {
        if isOnLastQuestion {
            Task {
                let answers = Dictionary(
                    uniqueKeysWithValues: content.questions.map { question in
                        (question.id, selectedOptionIDsByQuestionID[question.id])
                    }
                )

                guard let result = await viewModel.submit(
                    content: content,
                    selectedOptionIDsByQuestionID: answers,
                    notificationsEnabled: session.currentUser?.preference?.areNotificationsEnabled == true
                ) else {
                    if viewModel.requiresSignOut {
                        session.signOut()
                    }
                    return
                }

                refreshCenter.didSubmitQuiz()
                actions.onComplete(result)
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            currentQuestionIndex += 1
        }
    }

    func formattedQuestionNumber(_ value: Int) -> String {
        String(format: "%02d", value)
    }
}

struct LessonQuizActions {
    var onComplete: (QuizResultContent) -> Void = { _ in }
}

private struct QuizOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Circle()
                    .strokeBorder(isSelected ? SubjectsPalette.brandBright : SubjectsPalette.quizOptionRadioBorder, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? SubjectsPalette.brandBright : .clear)
                    )
                    .frame(width: 40, height: 40)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.subjectQuizOptionLabel)
                    .foregroundStyle(isSelected ? SubjectsPalette.quizOptionSelectedText : SubjectsPalette.quizOptionText)
                    .tracking(-0.2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(isSelected ? SubjectsPalette.quizOptionSelectedBackground : AppColors.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? SubjectsPalette.quizOptionSelectedStroke : SubjectsPalette.quizOptionBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: isSelected ? SubjectsPalette.quizOptionSelectedShadow : SubjectsPalette.quizOptionShadow,
                radius: isSelected ? 16 : 10,
                x: 0,
                y: isSelected ? 8 : 6
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to choose this answer.")
    }
}
