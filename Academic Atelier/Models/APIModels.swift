import Foundation

struct APIResponse<Payload: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: Payload?
}

struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String
}

struct EmptyPayload: Decodable {}
struct EmptyRequest: Encodable {}

struct AuthPayload: Decodable {
    let user: User
    let token: String
    let requiresStreamSelection: Bool
}

struct ForgotPasswordPayload: Decodable {
    let email: String
    let expiresAt: String
    let sent: Bool
}

struct VerifyResetCodePayload: Decodable {
    let email: String
    let verified: Bool
}

struct ResetPasswordPayload: Decodable {
    let email: String
    let reset: Bool
}

struct LogoutPayload: Decodable {
    let loggedOut: Bool
}

struct CurrentUserPayload: Decodable {
    let user: User
}

struct StreamsPayload: Decodable {
    let streams: [Stream]
}

struct StreamSelectionPayload: Decodable {
    let user: User
    let requiresStreamSelection: Bool
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let fullName: String
    let email: String
    let password: String
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct VerifyResetCodeRequest: Encodable {
    let email: String
    let code: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let newPassword: String
}

struct SelectStreamRequest: Encodable {
    let streamId: Int
}
