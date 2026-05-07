import SwiftUI

struct ProgressPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Progress Tracking Screen")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Progress")
        }
    }
}
