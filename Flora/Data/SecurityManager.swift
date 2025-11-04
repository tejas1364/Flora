//
//  MARK: - SecurityManager.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

// Keychain-backed encryption key management

import Foundation
import Security

class SecurityManager {
    static let shared = SecurityManager()
    
    private let keychainService = "com.flora.encryption"
    private let keychainAccount = "dataEncryptionKey"
    
    private init() {}
    
    // MARK: - Encryption Key Management
    func getOrCreateEncryptionKey() -> String {
        // Try to retrieve existing key
        if let existingKey = retrieveKey() {
            return existingKey
        }
        
        // Generate new key
        let newKey = generateEncryptionKey()
        storeKey(newKey)
        return newKey
    }
    
    private func generateEncryptionKey() -> String {
        // Generate 256-bit random key
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            fatalError("Failed to generate encryption key")
        }
        
        return keyData.base64EncodedString()
    }
    
    private func storeKey(_ key: String) {
        let keyData = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete any existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            fatalError("Failed to store encryption key: \(status)")
        }
    }
    
    private func retrieveKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data,
              let key = String(data: keyData, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    // MARK: - Biometric Authentication
    func canUseBiometrics() -> Bool {
        // Check if biometric authentication is available
        // This would use LocalAuthentication framework
        return true // Simplified for now
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        // Implement LAContext biometric authentication
        // For now, simplified
        completion(true, nil)
    }
}
