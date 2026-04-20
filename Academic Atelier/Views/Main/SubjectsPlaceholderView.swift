import SwiftUI

struct SubjectsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Subjects Screen")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Subjects")
        }
    }
}
