//
//  AuthHelper.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 21.02.2026.
//

import UIKit
import WebKit

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from navigationAction: WKNavigationAction) -> String?
    func code(from url: URL) -> String? // Добавляем метод для URL
}

// MARK: - AuthHelper
class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Constants
    private let configuration: AuthConfiguration
    
    // MARK: - Initializer
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        var urlComponents = URLComponents(string: configuration.authURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents?.url
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else { return nil }
        return code(from: url)
    }
    
    func code(from url: URL) -> String? {
        guard
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else { return nil }
        
        return codeItem.value
    }
}
