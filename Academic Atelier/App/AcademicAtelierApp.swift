import SwiftUI

@main
struct AcademicAtelierApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionViewModel)
        }
    }
}
