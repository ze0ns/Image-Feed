//
//  AuthToken.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 24.01.2026.
//


import Foundation

// MARK: - AuthToken
struct OAuthTokenResponseBody: Codable {
    let accessToken, tokenType, scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
