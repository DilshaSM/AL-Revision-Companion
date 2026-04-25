import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false

    func signIn(using session: SessionViewModel) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        isLoading = true
        errorMessage = ""

        defer { isLoading = false }

        do {
            try await session.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(using session: SessionViewModel) async {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }

        isLoading = true
        errorMessage = ""

        defer { isLoading = false }

        do {
            try await session.signUp(
                fullName: fullName,
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
