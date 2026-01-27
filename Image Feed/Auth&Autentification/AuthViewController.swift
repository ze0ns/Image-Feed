//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 23.01.2026.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .logoOfUnsplash)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .ypWhite
        button.setTitleColor(.ypBlack, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(imageView)
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -124),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        print("Кнопка 'Вход' нажата")
        let nextVC = WebViewViewController()
        nextVC.delegate = self
        let navController = UINavigationController(rootViewController: nextVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    private func goToMainTabBarController() {
        let nextVC = MainTabBarController()
        let navController = UINavigationController(rootViewController: nextVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    // MARK: - Alerts
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: Extensions
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
                DispatchQueue.main.async{
                    UIBlockingProgressHUD.dismiss()
                    self.goToMainTabBarController()
                }
            case .failure:
                showErrorAlert("error")
                break
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
}
