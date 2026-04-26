import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    func setErrorMessage(_ message: String) {
        errorMessage = message
    }
}
