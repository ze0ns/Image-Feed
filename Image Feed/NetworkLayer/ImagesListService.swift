//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 02.02.2026.
//

import UIKit
enum ImagesListServiceError: Error {
    case invalidURL
    case invalidImages
    case decodingError
    case invalidRequest
    case noToken
    case alreadyLoading
}
final class ImagesListService {
// MARK: - Singleton
 static let shared = ImagesListService()
 private init() {}
 
 // MARK: - Properties
 private(set) var images: [Photo] = []
 private var currentPage: Int = 1
 private var isFetching = false
 private var storageToken = OAuth2TokenStorage.shared
 private var networkClient = NetworkClient()
 private var currentTask: URLSessionTask?
 
 static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
 
 // MARK: - Public Methods
 
 func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {

     guard !isFetching else {
         completion(.failure(ImagesListServiceError.alreadyLoading))
         return
     }
     guard let token = storageToken.token else {
         completion(.failure(ImagesListServiceError.noToken))
         return
     }
     guard let request = makePhotoImagesRequest(token: token, page: currentPage) else {
         completion(.failure(ImagesListServiceError.invalidRequest))
         return
     }
     isFetching = true
     currentTask?.cancel()
     currentTask = networkClient.fetch(request: request) { [weak self] result in
         guard let self = self else { return }
         self.isFetching = false
         self.currentTask = nil
         
         DispatchQueue.main.async {
             switch result {
             case .success(let data):
                 guard !data.isEmpty else {
                     completion(.failure(ImagesListServiceError.invalidImages))
                     return
                 }
                 
                 do {
                     let decoder = JSONDecoder()
                     let images = try decoder.decode([Photo].self, from: data)
                     self.images.append(contentsOf: images)
                     self.currentPage += 1
                     NotificationCenter.default.post(
                         name: ImagesListService.didChangeNotification,
                         object: self,
                         userInfo: ["photos": self.images]
                     )
                     
                     completion(.success(images))
                     
                 } catch {
                     print("❌ [ImagesListService] - Ошибка декодирования: \(error)")
                     completion(.failure(ImagesListServiceError.decodingError))
                 }
                 
             case .failure(let error):
                 let nsError = error as NSError
                 if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                     print("[ImagesListService] - Запрос был отменен")
                     return
                 }
                 print("❌ [ImagesListService] - Сетевая ошибка: \(error.localizedDescription)")
                 completion(.failure(error))
             }
         }
     }
 }
    
    private func makePhotoImagesRequest(token: String, page: Int) -> URLRequest? {
        guard let baseURL = URL(string: Constants.defaultBaseURLString) else {
            return nil
        }
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("/photos"), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10") // Можно увеличить количество фото на странице
        ]
        guard let url = urlComponents?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func reset() {
        currentTask?.cancel()
        currentTask = nil
        isFetching = false
        currentPage = 1
        images.removeAll()
    }
}

