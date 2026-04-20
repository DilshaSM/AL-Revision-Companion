import SwiftUI

@main
struct ALRevisionCompanionApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionViewModel)
        }
    }
}
