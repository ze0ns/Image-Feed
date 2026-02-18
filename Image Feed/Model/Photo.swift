//
//  Photo 2.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 18.02.2026.
//
import Foundation

struct Photo {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let thumbImageURL: String
    let fullImageURL: String
    var likedByUser: Bool
    
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.width = photoResult.width
        self.height = photoResult.height
        self.createdAt = photoResult.createdAt
        self.description = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.fullImageURL = photoResult.urls.full
        self.likedByUser = photoResult.likedByUser
    }
}
