//
//  SplashViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 26.01.2026.
//

import UIKit
final class SplashViewController: UIViewController {

    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .splashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthStatus()
    }
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 77.68),
        ])
    }
    
    private func checkAuthStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let token = self.storage.get()
            print("Токен: \(token ?? "отсутствует")")
            
            if token != nil && !(token?.isEmpty ?? true) {
                print("Идем в галерею")
                self.goToMainTabController()
            } else {
                print("Идем в авторизацию")
                self.goToAuthViewController()
            }
        }
    }
    // MARK: - Go To ViewControllers
    private func goToMainTabController() {
        let tabBarController = MainTabBarController()
        performTransition(to: tabBarController)
    }
    
    private func goToAuthViewController() {
        let authViewController = AuthViewController()
        performTransition(to: authViewController)
    }
    
    private func performTransition(to viewController: UIViewController) {
        replaceRootViewController(with: viewController)
    }

    private func replaceRootViewController(with viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
