import SwiftUI

@main
struct ALRevisionCompanionApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var refreshCenter = AppRefreshCenter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionViewModel)
                .environmentObject(refreshCenter)
        }
    }
}
