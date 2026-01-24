//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 23.01.2026.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func  webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func  webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: - Private Properties
    private var webView: WKWebView!
    private let progressView = UIProgressView()
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Constants
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    // URL страницы авторизации
    private let loginURL = URL(string: WebViewConstants.unsplashAuthorizeURLString)!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationBar()
        setupProgressView()
        updateProgress()
        loadAuthView()
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

    @objc private func backButtonTapped() {
        guard let navController = navigationController else { return }
        let sourceVC = AuthViewController()
        navController.setViewControllers([sourceVC], animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    private func loadAuthView (){
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    
    // MARK: - Private Method, configure WebView
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
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
    // MARK: - Navigation after Login
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
            print(code)
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
            print(codeItem.value)
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
