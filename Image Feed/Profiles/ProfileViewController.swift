//
//  ViewController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//

import UIKit
import Kingfisher

protocol ProfileViewProtocol: AnyObject {
    func displayProfileData(name: String, login: String, bio: String)
    func displayAvatar(url: URL?)
    func showAvatarSkeleton()
    func hideAvatarSkeleton()
    func showLogoutConfirmation()
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    // MARK: - Private Properties
    private lazy var userFIO = UILabel()
    private lazy var loginName = UILabel()
    private lazy var comments = UILabel()
    private var animationLayer: CAGradientLayer?
    
    private lazy var avatar: UIImageView = {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        avatar.image = UIImage(resource: .avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        return avatar
    }()
    
    private lazy var exit: UIButton = {
        let exit = UIButton()
        exit.setImage(UIImage(resource: .logoutButton), for: .normal)
        exit.addTarget(self, action: #selector(tapExit), for: .touchUpInside)
        exit.translatesAutoresizingMaskIntoConstraints = false
        exit.accessibilityIdentifier = "logout button"
        return exit
    }()
    
    private var presenter: ProfilePresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureAppearance()
        
        // Инициализация презентера
        presenter = ProfilePresenter(view: self)
        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animationLayer?.frame = avatar.bounds
        avatar.layer.cornerRadius = avatar.frame.height / 2
        presenter?.viewDidLayoutSubviews()
    }
    
    // MARK: - ProfileViewProtocol
    func displayProfileData(name: String, login: String, bio: String) {
        DispatchQueue.main.async {
            self.userFIO.text = name
            self.loginName.text = login
            self.comments.text = bio
        }
    }
    
    func displayAvatar(url: URL?) {
        guard let imageUrl = url else { return }
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        avatar.kf.indicatorType = .activity
        avatar.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("Avatar loaded: \(value.image)")
            case .failure(let error):
                print("Avatar loading error: \(error)")
            }
        }
    }
    
    func showAvatarSkeleton() {
        hideAvatarSkeleton()
        
        let gradient = CAGradientLayer()
        gradient.frame = avatar.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.8, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        gradient.add(animation, forKey: "skeletonAnimation")
        
        animationLayer = gradient
        avatar.layer.addSublayer(gradient)
        avatar.backgroundColor = .clear
        avatar.image = nil
    }
    
    func hideAvatarSkeleton() {
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
        avatar.backgroundColor = .ypBlack
    }
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        
        present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.backgroundColor = .ypBlack
        view.addSubview(avatar)
        view.addSubview(exit)
        view.addSubview(userFIO)
        view.addSubview(loginName)
        view.addSubview(comments)
    }
    
    private func configureAppearance() {
        userFIO.textColor = .ypWhite
        userFIO.font = .boldSystemFont(ofSize: 23)
        userFIO.translatesAutoresizingMaskIntoConstraints = false
        userFIO.accessibilityIdentifier = "Name Lastname"
        
        loginName.textColor = .ypGray
        loginName.font = .systemFont(ofSize: 13)
        loginName.translatesAutoresizingMaskIntoConstraints = false
        loginName.accessibilityIdentifier = "@username"
        
        comments.textColor = .ypWhite
        comments.font = .systemFont(ofSize: 13)
        comments.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatar.heightAnchor.constraint(equalToConstant: 70),
            avatar.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        avatar.layer.cornerRadius = 35
        avatar.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            exit.topAnchor.constraint(equalTo: view.topAnchor, constant: 89),
            exit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exit.heightAnchor.constraint(equalToConstant: 44),
            exit.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            userFIO.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8),
            userFIO.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            loginName.topAnchor.constraint(equalTo: userFIO.bottomAnchor, constant: 8),
            loginName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            comments.topAnchor.constraint(equalTo: loginName.bottomAnchor, constant: 8),
            comments.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func performLogout() {
        ProfileLogoutService.shared.logout()
        let navController = UINavigationController(rootViewController: AuthViewController())
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    // MARK: - Actions
    @objc private func tapExit(_ sender: UIButton) {
        presenter?.didTapLogout()
    }
}

