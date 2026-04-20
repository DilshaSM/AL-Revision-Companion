import Foundation

final class AuthViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""

    private let authService = AuthService()

    func signIn() -> User? {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return nil
        }

        errorMessage = ""
        return authService.signIn(email: email)
    }

    func signUp() -> User? {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return nil
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return nil
        }

        errorMessage = ""
        return authService.signUp(fullName: fullName, email: email)
    }
}
