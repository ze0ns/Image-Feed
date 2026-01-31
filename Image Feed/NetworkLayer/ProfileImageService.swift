//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 29.01.2026.
//

import UIKit

enum ProfileImageError: Error {
    case invalidURL
    case invalidProfile
    case decodingError
}
final class ProfileImageService {
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    // MARK: - Private Properties
    private(set) var userImage: String = " "
    private var networkClient = NetworkClient()
    private var storageToken = OAuth2TokenStorage.shared

    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        guard let token = storageToken.token else { return }
        guard let request = makeProfileImageRequest(username: username, token:  token) else {
            print("ProfileImageService: Не сформировался запрос для загрузки Аватарки")
            return
        }
        _ =  networkClient.fetch(request: request) { [weak self] result in
            guard let self = self else { return }
            let decoder = JSONDecoder()
            switch result {
            case .success(let data):
                guard !data.isEmpty else {
                    DispatchQueue.main.async {
                        completion(.failure(ProfileServiceError.invalidProfile))
                    }
                    return
                }
                do {
                    let userProfileBody = try decoder.decode(UserResult.self, from: data)
                    DispatchQueue.main.async {
                        self.userImage = userProfileBody.profileImage.small
                        completion(.success(userProfileBody.profileImage.small))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": userProfileBody.profileImage.small])
                    }
                    
                } catch {
                    print("❌ [ProfileImageService] - Ошибка декодирования: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(ProfileServiceError.decodingError))
                    }
                }
                
            case .failure(let error):
                print("❌ [ProfileImageService] - Сетевая ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
