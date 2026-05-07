import SwiftUI

struct StreamSelectionView: View {
    @EnvironmentObject var session: SessionViewModel
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    streamListSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await session.ensureAvailableStreams()
        }
        .onAppear {
            focusedElement = .title
        }
        .onChange(of: session.streamErrorMessage) { _, message in
            guard !message.isEmpty else { return }
            focusedElement = .status
            Task { @MainActor in
                AccessibilitySupport.announce(message)
            }
        }
    }
}

// MARK: - Sections
private extension StreamSelectionView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select Your\nStream")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHeader()
                .accessibilityFocused($focusedElement, equals: .title)

            Text("Choose your academic focus to unlock curated learning paths tailored for your professional future.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
    }

    var streamListSection: some View {
        VStack(spacing: 18) {
            if session.isLoadingStreams && session.availableStreams.isEmpty {
                ProgressView("Loading streams...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            }

            if !session.streamErrorMessage.isEmpty {
                Text(session.streamErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityFocused($focusedElement, equals: .status)
            }

            ForEach(session.availableStreams) { stream in
                StreamSelectionCard(
                    title: stream.displayName,
                    subtitle: stream.description ?? stream.subjectSummary.replacingOccurrences(of: "\n", with: ", "),
                    iconName: stream.assetName
                ) {
                    Task {
                        await session.selectStream(stream)
                    }
                }
                .disabled(session.activeStreamSelectionID != nil)
            }

            if !session.isLoadingStreams && session.availableStreams.isEmpty {
                Text("No streams are available right now. Try again in a moment.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
