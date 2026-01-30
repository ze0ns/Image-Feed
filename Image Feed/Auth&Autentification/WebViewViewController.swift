
import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: - Private Properties
    private var webView: WKWebView?
    private let progressView = UIProgressView()
    weak var delegate: WebViewViewControllerDelegate?
    private var authVC = AuthViewController()
    private var estimatedProgressObservation: NSKeyValueObservation?
    // MARK: - Constants
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    private let loginURL: URL? = URL(string: WebViewConstants.unsplashAuthorizeURLString)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationBar()
        setupProgressView()
        updateProgress()
        loadAuthView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let webView = webView else { return }
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        updateProgress()
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        let customView = UIButton(type: .custom)
        customView.setImage(UIImage(resource: .backwardLogin), for: .normal)
        customView.tintColor = .ypBlack
        customView.backgroundColor = .ypWhite
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let customButton = UIBarButtonItem(customView: customView)
        navigationItem.leftBarButtonItem = customButton
    }
    // MARK: - Actions
    @objc private func backButtonTapped() {
        guard let navController = navigationController else { return }
        let sourceVC = AuthViewController()
        navController.setViewControllers([sourceVC], animated: true)
    }
    
    // MARK: - Private Method
    
    private func loadAuthView (){
        guard WebViewConstants.unsplashAuthorizeURLString != nil else {
            let error = NSError(domain: "Auth", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Отсутствует строка URL авторизации"])
            print("Ошибка URL: \(error.localizedDescription)")
            return
        }
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            let error = NSError(domain: "Auth", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать URLComponents из строки: \(WebViewConstants.unsplashAuthorizeURLString)"])
            print("Ошибка URLComponents: \(error.localizedDescription)")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            let error = NSError(domain: "Auth", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Не удалось сформировать URL из URLComponents: \(urlComponents)"])
            print("Ошибка формирования URL: \(error.localizedDescription)")
            return
        }
        guard let webView = webView else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    
    // MARK: - Private Method, configure WebView
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.webView = webView // Сохраняем в свойство
    }
    
    
    
    // MARK: - Setup Progress View
    private func setupProgressView() {
        progressView.progressTintColor = .ypBlack
        progressView.trackTintColor = .lightGray
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    private func updateProgress() {
        guard let webView = webView else { return }
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    // MARK: - Navigation after Login
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    // MARK: - Private Method
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    // MARK: - UIAlertController
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Go to main screen
    private func navigateToMainScreen() {
        let mainVC = MainTabBarController()
        let navController = UINavigationController(rootViewController: mainVC)
        UIApplication.shared.windows.first?.rootViewController = navController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
