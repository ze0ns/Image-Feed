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
    let createdAt: Date?
    let description: String?
    let urls: PhotoUrls
    let liked_by_user: Bool
    
    struct PhotoUrls: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}
