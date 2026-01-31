//
//  SplashViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 26.01.2026.
//

import UIKit
final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let storageToken = OAuth2TokenStorage.shared
    private lazy var username: String = " "
    private  let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .splashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private(set) var authToken: String? {
        get {
            return storageToken.token
        }
        set {
            storageToken.token = newValue
        }
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var token = authToken
        print(authToken)
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
        DispatchQueue.main.async { 
            if  let token = self.authToken {
                print("Идем в галерею")
                self.fetchProfile(token)
            } else {
                print("Идем в авторизацию")
                self.goToAuthViewController()
            }
        }
    }
    
    // MARK: - Private Methods, Fetch Data
    private func fetchProfile(_ token: String){
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.username = result.username
                self.fetchImage()
                self.goToMainTabController()
            case .failure(let error):
                print("[SplashViewController], Ошибка в методе полученя профиля: \(error.localizedDescription)")
            }
        }
    }
    private func fetchImage(){
        ProfileImageService.shared.fetchProfileImageURL(username: self.username){ result in
            switch result {
            case .success(let result):
               print(result)
            case .failure(let error):
                print("SplashViewController], Ошибка в методе полученя аватарки: \(error.localizedDescription)")
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
            assertionFailure("SplashViewController] Неправильная конфигурация окна")
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
//MARK: SwiftUI - for working canvas
import SwiftUI
struct SplashViewControllerProvider: PreviewProvider {
    static var previews: some View {
        VCProvider<SplashViewController>.previews
    }
}
