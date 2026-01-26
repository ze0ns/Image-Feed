//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 24.01.2026.
//


import Foundation

final class OAuth2TokenStorage {
    // MARK: - Private Properties
    private var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    
    // MARK: - Public Interface
    func set(token: String) {
        self.token = token
    }
    func get() -> String? {
        return token
    }
}
