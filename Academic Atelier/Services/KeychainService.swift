import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()

    private let service = Bundle.main.bundleIdentifier ?? "com.academicatelier.app"
    private let account = "auth.jwt"

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
}
