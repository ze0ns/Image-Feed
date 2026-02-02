//
//  ModelPhoto.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 02.02.2026.
//

import Foundation
struct Photos {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
