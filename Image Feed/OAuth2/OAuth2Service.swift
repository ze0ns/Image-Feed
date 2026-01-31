import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case invalidToken
    case duplicateRequest
}
final class OAuth2Service {
    // MARK: Static Properties
    static let shared = OAuth2Service()
    
    // MARK: Private Properties
    private var networkClient = NetworkClient()
    private var storageToken = OAuth2TokenStorage.shared
    private let decoder: JSONDecoder
    private var lastCode: String?
    
    private init() {
        decoder = JSONDecoder()
    }
    
    private(set) var authToken: String? {
        get {
            return storageToken.token
        }
        set {
            storageToken.token = newValue
        }
    }
    
    // MARK: - Private Properties
    private let tokenQueue = DispatchQueue(label: "com.app.tokenQueue", qos: .userInitiated, attributes: .concurrent)
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) -> URLSessionTask {
        // Проверяем дублирующие запросы
        var shouldProceed = false
        tokenQueue.sync {
            if lastCode != code {
                lastCode = code
                shouldProceed = true
            }
        }
        
        guard shouldProceed else {
            completion(.failure(AuthServiceError.duplicateRequest))
            // Возвращаем пустую задачу, так как запрос не выполняется
            return URLSessionTask()
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            tokenQueue.async(flags: .barrier) {
                self.lastCode = nil
            }
            completion(.failure(AuthServiceError.invalidRequest))
            return URLSessionTask()
        }
        
        let task = networkClient.fetch(request: request) { [weak self] result in
            // Очищаем lastCode после завершения запроса
            self?.tokenQueue.async(flags: .barrier) {
                self?.lastCode = nil
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let tokenBody = try self?.decoder.decode(OAuthTokenResponseBody.self, from: data)
                        guard let token = tokenBody?.accessToken else {
                            completion(.failure(AuthServiceError.invalidToken))
                            return
                        }
                        self?.authToken = token
                        completion(.success(token))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }

    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("❌ Не удалось создать URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        print("QueryItems установлены: \(urlComponents.queryItems?.count ?? 0) параметров")
        
        guard let authTokenUrl = urlComponents.url else {
            print("❌ Не удалось создать URL из компонентов")
            print("Компоненты: scheme=\(urlComponents.scheme ?? "nil"), host=\(urlComponents.host ?? "nil")")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        print("Запрос создан: method=\(request.httpMethod ?? "nil")")
        return request
    }
}
