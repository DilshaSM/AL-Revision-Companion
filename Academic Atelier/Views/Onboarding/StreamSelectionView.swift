import SwiftUI

struct StreamSelectionView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select Your Stream")
                    .font(.largeTitle.bold())

                Text("Choose the stream that matches your A/L studies.")
                    .foregroundStyle(.secondary)

                ForEach(Stream.allCases) { stream in
                    StreamCard(title: stream.rawValue) {
                        session.updateSelectedStream(stream)
                    }
                }
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
