import AuthClient
import Foundation
import Security

/// A single generic-password item in the keychain (service + account), accessed with the `SecItem` API.
struct Keychain: Sendable {
    let service: String
    let account: String

    private var query: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            // Data protection keychain: access is governed by the app's keychain access group,
            // not per-app ACLs, so macOS never asks for the login keychain password.
            kSecUseDataProtectionKeychain as String: true,
        ]
    }

    /// The stored string, or `nil` when there is no item.
    func read() throws -> String? {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw AuthError.keychain(errSecDecode) }
            return String(decoding: data, as: UTF8.self)
        case errSecItemNotFound:
            return nil
        default:
            throw AuthError.keychain(status)
        }
    }

    /// Creates the item, or replaces its value when it already exists.
    func write(_ value: String) throws {
        let data = Data(value.utf8)
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var item = query
            item[kSecValueData as String] = data
            item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw AuthError.keychain(addStatus) }
        default:
            throw AuthError.keychain(status)
        }
    }

    /// Removes the item; nothing happens when there is none.
    func delete() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw AuthError.keychain(status) }
    }
}
