import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var settings: ProfileSettings

    init(settings: ProfileSettings = .init()) {
        self.settings = settings
    }
}
