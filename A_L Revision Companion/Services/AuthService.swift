import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthPayload
    func register(fullName: String, email: String, password: String) async throws -> AuthPayload
    func forgotPassword(email: String) async throws -> ForgotPasswordPayload
    func verifyResetCode(email: String, code: String) async throws -> VerifyResetCodePayload
    func resetPassword(email: String, code: String, newPassword: String) async throws -> ResetPasswordPayload
    func currentUser() async throws -> CurrentUserPayload
    func logout() async throws -> LogoutPayload
}

struct AuthService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> AuthPayload {
        try await client.send(
            path: "/auth/login",
            method: "POST",
            body: LoginRequest(
                email: email.lowercased(),
                password: password
            )
        )
    }

    func register(fullName: String, email: String, password: String) async throws -> AuthPayload {
        try await client.send(
            path: "/auth/register",
            method: "POST",
            body: RegisterRequest(
                fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.lowercased(),
                password: password
            )
        )
    }

    func forgotPassword(email: String) async throws -> ForgotPasswordPayload {
        try await client.send(
            path: "/auth/forgot-password",
            method: "POST",
            body: ForgotPasswordRequest(email: email.lowercased())
        )
    }

    func verifyResetCode(email: String, code: String) async throws -> VerifyResetCodePayload {
        try await client.send(
            path: "/auth/verify-reset-code",
            method: "POST",
            body: VerifyResetCodeRequest(
                email: email.lowercased(),
                code: code
            )
        )
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws -> ResetPasswordPayload {
        try await client.send(
            path: "/auth/reset-password",
            method: "POST",
            body: ResetPasswordRequest(
                email: email.lowercased(),
                code: code,
                newPassword: newPassword
            )
        )
    }

    func currentUser() async throws -> CurrentUserPayload {
        try await client.send(
            path: "/users/me",
            method: "GET",
            requiresAuth: true
        )
    }

    func logout() async throws -> LogoutPayload {
        try await client.send(
            path: "/auth/logout",
            method: "POST",
            body: EmptyRequest()
        )
    }
}

extension AuthService: AuthServiceProtocol {}
