import Foundation
import LocalAuthentication
import Security

protocol KeychainServiceProtocol: AnyObject {
    func saveToken(_ token: String) throws
    func loadToken() -> String?
    func removeToken()
    func saveBiometricToken(_ token: String) throws
    func loadBiometricToken(using context: LAContext) throws -> String?
    func hasBiometricToken() -> Bool
    func removeBiometricToken()
}

final class KeychainService {
    static let shared = KeychainService()

    private let service = Bundle.main.bundleIdentifier ?? "com.academicatelier.app"
    private let account = "auth.jwt"
    private let biometricAccount = "auth.jwt.biometric"

    private init() {}

    func saveToken(_ token: String) throws {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecSuccess {
            return
        }

        if updateStatus != errSecItemNotFound {
            throw APIError.server(message: "Failed to store authentication token.", statusCode: Int(updateStatus))
        }

        var item = query
        attributes.forEach { item[$0.key] = $0.value }

        let addStatus = SecItemAdd(item as CFDictionary, nil)

        guard addStatus == errSecSuccess else {
            throw APIError.server(message: "Failed to store authentication token.", statusCode: Int(addStatus))
        }
    }

    func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    func removeToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }

    func saveBiometricToken(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: biometricAccount
        ]
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

        if updateStatus == errSecSuccess {
            return
        }

        if updateStatus != errSecItemNotFound {
            throw KeychainError(message: "Failed to update the biometric login token.")
        }

        var accessControlError: Unmanaged<CFError>?

        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryCurrentSet,
            &accessControlError
        ) else {
            let message = accessControlError?.takeRetainedValue().localizedDescription
                ?? "Failed to prepare secure biometric storage."
            throw KeychainError(message: message)
        }

        let item: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: biometricAccount,
            kSecAttrAccessControl as String: accessControl,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(item as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError(message: "Failed to store the biometric login token.")
        }
    }

    func loadBiometricToken(using context: LAContext) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: biometricAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                return nil
            }
            return token
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError(message: "Failed to read the biometric login token.")
        }
    }

    func hasBiometricToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: biometricAccount,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecInteractionNotAllowed || status == errSecAuthFailed
    }

    func removeBiometricToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: biometricAccount
        ]

        SecItemDelete(query as CFDictionary)
    }
}

extension KeychainService: KeychainServiceProtocol {}

enum BiometricType: Equatable {
    case none
    case faceID
    case touchID

    var displayName: String {
        switch self {
        case .none:
            return "Biometric"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        }
    }

    var iconSystemName: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.shield"
        }
    }
}

protocol BiometricAuthServiceProtocol {
    func availableBiometricType() -> BiometricType
    func authenticate(reason: String) async throws -> LAContext
}

struct BiometricAuthService {
    func availableBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }

    func authenticate(reason: String) async throws -> LAContext {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password Instead"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricAuthError(message: message(for: error))
        }

        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return context
        } catch {
            throw BiometricAuthError(message: message(for: error))
        }
    }

    private func message(for error: Error?) -> String {
        guard let laError = error as? LAError else {
            return error?.localizedDescription ?? "Biometric authentication is not available right now."
        }

        switch laError.code {
        case .authenticationFailed:
            return "Biometric authentication failed. Try again or use your password."
        case .userCancel, .appCancel, .systemCancel:
            return "Biometric authentication was cancelled."
        case .userFallback:
            return "Use your password to sign in."
        case .biometryNotAvailable:
            return "Biometric authentication is not available on this device."
        case .biometryNotEnrolled:
            return "Set up Face ID or Touch ID in iOS Settings first."
        case .biometryLockout:
            return "Biometric authentication is locked. Unlock your device and try again."
        case .passcodeNotSet:
            return "Set a device passcode before enabling biometric login."
        case .invalidContext:
            return "Biometric authentication is unavailable right now. Try again."
        default:
            return laError.localizedDescription
        }
    }
}

extension BiometricAuthService: BiometricAuthServiceProtocol {}

private struct KeychainError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

private struct BiometricAuthError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}
