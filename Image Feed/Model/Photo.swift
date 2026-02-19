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
    let createdAt: Date?  // Изменено с String? на Date?
    let description: String?
    let thumbImageURL: String
    let fullImageURL: String
    var likedByUser: Bool
    
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.width = photoResult.width
        self.height = photoResult.height
        // Преобразование строки в Date на уровне маппинга
        if let createdAtString = photoResult.createdAt {
            self.createdAt = ISO8601DateFormatter().date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
        self.description = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.fullImageURL = photoResult.urls.full
        self.likedByUser = photoResult.likedByUser
    }
}
