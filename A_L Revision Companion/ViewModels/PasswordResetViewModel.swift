import Foundation

@MainActor
final class PasswordResetViewModel: ObservableObject {
    @Published var email: String
    @Published var verificationCode: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var infoMessage: String = ""
    @Published var expiresAt: Date?
    @Published var isLoading = false

    private let authService: AuthService
    private let dateFormatter = ISO8601DateFormatter()

    init(
        email: String = "",
        authService: AuthService = AuthService()
    ) {
        self.email = email
        self.authService = authService
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }

    func sendResetCode() async -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !normalizedEmail.isEmpty else {
            errorMessage = "Email is required."
            return false
        }

        isLoading = true
        errorMessage = ""
        infoMessage = ""

        defer { isLoading = false }

        do {
            let payload = try await authService.forgotPassword(email: normalizedEmail)
            email = payload.email
            expiresAt = parseDate(payload.expiresAt)
            infoMessage = "Verification code sent successfully."
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func verifyCode() async -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCode = verificationCode.filter(\.isNumber)

        guard !normalizedEmail.isEmpty, normalizedCode.count == 4 else {
            errorMessage = "Enter the 4-digit verification code."
            return false
        }

        isLoading = true
        errorMessage = ""
        infoMessage = ""

        defer { isLoading = false }

        do {
            _ = try await authService.verifyResetCode(email: normalizedEmail, code: normalizedCode)
            verificationCode = normalizedCode
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func resetPassword() async -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCode = verificationCode.filter(\.isNumber)

        guard !normalizedEmail.isEmpty, normalizedCode.count == 4 else {
            errorMessage = "Your verification session expired. Start again."
            return false
        }

        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in both password fields."
            return false
        }

        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        isLoading = true
        errorMessage = ""
        infoMessage = ""

        defer { isLoading = false }

        do {
            _ = try await authService.resetPassword(
                email: normalizedEmail,
                code: normalizedCode,
                newPassword: newPassword
            )
            infoMessage = "Password reset successful."
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func clearMessages() {
        errorMessage = ""
        infoMessage = ""
    }

    private func parseDate(_ value: String) -> Date? {
        dateFormatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}
