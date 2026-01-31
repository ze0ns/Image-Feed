//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 24.01.2026.
//


import Foundation
import SwiftKeychainWrapper
final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let tokenKey = "token"

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
