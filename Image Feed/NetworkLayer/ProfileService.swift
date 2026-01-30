//
//  ProfileService.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 27.01.2026.
//

import UIKit
enum ProfileServiceError: Error {
    case invalidURL
    case invalidProfile
    case decodingError
}
final class ProfileService {
    // MARK: - Singleton
    static let shared = ProfileService()
    
    // MARK: - Properties
    private var networkClient = NetworkClient()
    private let decoder: JSONDecoder
    private(set) var profile: Profile?
    
    // MARK: - Initialization
    init() {
        decoder = JSONDecoder()
    }
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let profileURL = Constants.defaultBaseURLString + "/me"
        
        guard let url = URL(string: profileURL) else {
            DispatchQueue.main.async {
                completion(.failure(ProfileServiceError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🔍 Загружаем профиль по URL: \(url)")
        
        networkClient.fetch(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                // Проверяем данные
                guard !data.isEmpty else {
                    DispatchQueue.main.async {
                        completion(.failure(ProfileServiceError.invalidProfile))
                    }
                    return
                }
                do {

                    let profileBody = try self.decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(
                        username: profileBody.username,
                        name: profileBody.name,
                        loginName: "@\(profileBody.username)",
                        bio: profileBody.bio
                    )
                    
                    DispatchQueue.main.async {
                        self.profile = profile
                        completion(.success(profile))
                    }
                    
                } catch {
                    print("❌ Ошибка декодирования: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(ProfileServiceError.decodingError))
                    }
                }
                
            case .failure(let error):
                print("❌ Сетевая ошибка: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

}

