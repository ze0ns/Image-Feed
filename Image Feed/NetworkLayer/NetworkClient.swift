//
//  NetworkRouting.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 24.01.2026.
//


import Foundation

protocol NetworkRouting {
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkClient: NetworkRouting {
    // MARK: - Keys
    private enum NetworkError: Error {
        case codeError
    }
    // MARK: - Public Methods
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Netwoork client: \(error)")
                handler(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("Response status code \(response.statusCode)")
                print("Netwoork client response: \(NetworkError.codeError)")
                handler(.failure(NetworkError.codeError))
                return
            }
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}
