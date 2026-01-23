//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 23.01.2026.
//

import UIKit
import WebKit
final class WebViewViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: - Свойства
    private var webView: WKWebView!
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // URL страницы авторизации
    private let loginURL = URL(string: Constants.defaultBaseURLString)!
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupActivityIndicator()
        loadLoginPage()
    }
    
    // MARK: - Настройка WebView
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
    
    // MARK: - Индикатор загрузки
    private func setupActivityIndicator() {
        activityIndicator.color = .systemBlue
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Загрузка страницы
    private func loadLoginPage() {
        let request = URLRequest(url: loginURL)
        webView.load(request)
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Начинается загрузка
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Загрузка завершена
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Ошибка загрузки
        activityIndicator.stopAnimating()
        showErrorAlert(error.localizedDescription)
    }
    
    // MARK: - Обработка навигации (например, после входа)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Пример: перехватываем URL после успешного входа
        if let url = navigationAction.request.url,
           url.absoluteString.contains("/dashboard") {
            // Пользователь вошёл — переходим в основное приложение
            showSuccessAlert()
            decisionHandler(.cancel) // Отменяем навигацию в WebView
            return
        }
        
        decisionHandler(.allow) // Разрешаем обычную навигацию
    }
    
    // MARK: - UIAlertController
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Успех", message: "Вы вошли в систему!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Продолжить", style: .default) { _ in
            // Здесь можно перейти на главный экран приложения
            self.navigateToMainScreen()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Переход в основное приложение
    private func navigateToMainScreen() {
        // Пример замены rootViewController
        let mainVC = MainTabBarController() // Ваш основной экран
        let navController = UINavigationController(rootViewController: mainVC)
        UIApplication.shared.windows.first?.rootViewController = navController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
