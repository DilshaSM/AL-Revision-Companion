import SwiftData
import SwiftUI

@main
struct ALRevisionCompanionApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var refreshCenter = AppRefreshCenter()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionViewModel)
                .environmentObject(refreshCenter)
                .environmentObject(router)
        }
        .modelContainer(for: [
            WidgetSummaryEntity.self,
            RecentStudyActivityEntity.self,
            AudioProgressEntity.self,
            RecentSubjectEntity.self
        ])
    }
}
