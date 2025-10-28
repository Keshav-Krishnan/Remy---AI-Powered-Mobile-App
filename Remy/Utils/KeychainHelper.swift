//
//  KeychainHelper.swift
//  Remy
//
//  Created on 10/17/25.
//

import Foundation
import Security

/// Helper class for secure storage in the Keychain
class KeychainHelper {
    // MARK: - Singleton

    static let shared = KeychainHelper()

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Save a string value to the Keychain
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        // Delete any existing item
        delete(key: key)

        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Add item to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    /// Read a string value from the Keychain
    func read(key: String) -> String? {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        // Fetch item from Keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            return nil
        }

        guard let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Delete a value from the Keychain
    @discardableResult
    func delete(key: String) -> Bool {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        // Delete item from Keychain
        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Update an existing value in the Keychain
    func update(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        // Create attributes to update
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        // Update item in Keychain
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        // If item doesn't exist, save it instead
        if status == errSecItemNotFound {
            return save(key: key, value: value)
        }

        return status == errSecSuccess
    }

    /// Check if a key exists in the Keychain
    func exists(key: String) -> Bool {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        // Check if item exists
        let status = SecItemCopyMatching(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    /// Clear all items saved by this app from the Keychain
    func clearAll() -> Bool {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        // Delete all items
        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Convenience Keys

extension KeychainHelper {
    /// Common keychain keys used in the app
    enum Keys {
        static let openAIAPIKey = "com.remy.openai_api_key"
        static let firebaseToken = "com.remy.firebase_token"
        static let userID = "com.remy.user_id"
    }
}

// MARK: - Usage Example
/*
 // Save API key
 KeychainHelper.shared.save(key: KeychainHelper.Keys.openAIAPIKey, value: "sk-...")

 // Read API key
 if let apiKey = KeychainHelper.shared.read(key: KeychainHelper.Keys.openAIAPIKey) {
     print("API Key: \(apiKey)")
 }

 // Update API key
 KeychainHelper.shared.update(key: KeychainHelper.Keys.openAIAPIKey, value: "sk-new...")

 // Delete API key
 KeychainHelper.shared.delete(key: KeychainHelper.Keys.openAIAPIKey)

 // Check if key exists
 if KeychainHelper.shared.exists(key: KeychainHelper.Keys.openAIAPIKey) {
     print("API key is stored")
 }
 */
