//
//  ListPhoto.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 02.02.2026.
//
import Foundation

struct Photo: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: PhotoUrls
    let likedByUser: Bool
    
    struct PhotoUrls: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case width, height
            case description = "alt_description"
            case urls
            case likedByUser = "liked_by_user"
        }
}
