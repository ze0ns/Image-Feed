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
}
final class ProfileService {
    private var networkClient = NetworkClient()
    private let decoder: JSONDecoder
    init() {
        decoder = JSONDecoder()
    }
    // MARK: - Private Properties
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        let profileURL = Constants.defaultBaseURLString + "/me"
        guard let url = URL(string: profileURL ) else {
            // Всегда вызываем completion на главном потоке
            DispatchQueue.main.async {
                completion(.failure(ProfileServiceError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        networkClient.fetch(request: request) { [weak self] result in
            // Фиксим утечку памяти - сохраняем сильную ссылку
            guard let self = self else { return }
            
            // Гарантируем выполнение на главном потоке
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        // Используем self.decoder вместо self?.decoder
                        let profileBody = try self.decoder.decode(ProfileResult.self, from: data)
                        completion(.success(profileBody))
                    } catch {
                        print("loadProfile: Decoding error: \(error)")
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    print("loadProfile: Network error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}
