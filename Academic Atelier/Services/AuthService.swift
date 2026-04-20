import Foundation

struct AuthService {
    func signIn(email: String) -> User {
        User(
            id: UUID(),
            fullName: "Student User",
            email: email,
            selectedStream: nil
        )
    }

    func signUp(fullName: String, email: String) -> User {
        User(
            id: UUID(),
            fullName: fullName,
            email: email,
            selectedStream: nil
        )
    }
}
