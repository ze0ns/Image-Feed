//
//  ViewController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var userFIO = UILabel()
    private lazy var loginName = UILabel()
    private lazy var comments = UILabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayer: CAGradientLayer?
    private lazy var avatar: UIImageView = {
        var avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        avatar = UIImageView(image: UIImage(resource: .avatar))
        return avatar
    }()
    
    private lazy var exit: UIButton = {
        var exit = UIButton()
        exit.setImage(UIImage(resource: .logoutButton), for: .normal)
        return exit
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        userFIO.text = "Екатерина Новикова"
        loginName.text = "@ekaterina_nov"
        comments.text = "Hello, world!"
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        setupViews()
        setupConstraints()
    }
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         animationLayer?.frame = avatar.bounds
         avatar.layer.cornerRadius = avatar.frame.height / 2
     }
    private func updateAvatar() {
        guard let imageUrl = URL(string: ProfileImageService.shared.userImage) else {
            showAvatarSkeleton()
            return
        }
        hideAvatarSkeleton()
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
            ]) { result in
                switch result {
                case .success(let value):
                    // Картинка
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }
    }
    //MARK: - Private Methods, Load Data
    private func updateProfileDetails(profile: Profile) {
        print("Заполняем профиль")
        DispatchQueue.main.async {
            self.userFIO.text = profile.name
            self.loginName.text = profile.loginName
            self.comments.text = profile.bio ?? "Нет описания"
       //     self.upadeAvatar(urlImage: ProfileImageService.shared.userImage)
        }
    }

    
    // MARK: - Private Methods, configure UI
    private func setupViews(){
        userFIO.textColor = .ypWhite
        userFIO.font = .boldSystemFont(ofSize: 23)
        
        loginName.textColor = .ypGray
        loginName.font = .systemFont(ofSize: 13)
        
        comments.textColor = .ypWhite
        comments.font = .systemFont(ofSize: 13)
        
        exit.addTarget(self, action: #selector(tapExit), for: .touchUpInside)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        exit.translatesAutoresizingMaskIntoConstraints = false
        userFIO.translatesAutoresizingMaskIntoConstraints = false
        loginName.translatesAutoresizingMaskIntoConstraints = false
        comments.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(avatar)
        view.addSubview(exit)
        view.addSubview(userFIO)
        view.addSubview(loginName)
        view.addSubview(comments)
        
    }
    private func showAvatarSkeleton() {
           // Убираем существующий градиент, если есть
           hideAvatarSkeleton()
           
           // Создаем градиент для скелетона
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
           
           // Добавляем анимацию движения градиента
           let animation = CABasicAnimation(keyPath: "locations")
           animation.fromValue = [0, 0.1, 0.3]
           animation.toValue = [0.7, 0.8, 1.0]
           animation.duration = 1.5
           animation.repeatCount = .infinity
           animation.autoreverses = true
           gradient.add(animation, forKey: "skeletonAnimation")
           
           // Сохраняем ссылку и добавляем слой
           animationLayer = gradient
           avatar.layer.addSublayer(gradient)
           
           // Делаем фон аватара прозрачным, чтобы был виден градиент
           avatar.backgroundColor = .clear
           avatar.image = nil
       }
       
       private func hideAvatarSkeleton() {
           animationLayer?.removeFromSuperlayer()
           animationLayer = nil
           avatar.backgroundColor = .ypBlack
       }
    // MARK: - Private Methods, configure Constraints
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatar.heightAnchor.constraint(equalToConstant: 70),
            avatar.widthAnchor.constraint(equalToConstant: 70)
        ])
        self.avatar.layer.cornerRadius = self.avatar.frame.height / 2
        self.avatar.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            exit.topAnchor.constraint(equalTo: view.topAnchor, constant: 89),
            exit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exit.heightAnchor.constraint(equalToConstant: 44),
            exit.widthAnchor.constraint(equalToConstant: 44)
        ])
        NSLayoutConstraint.activate([
            userFIO.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8),
            userFIO.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        NSLayoutConstraint.activate([
            loginName.topAnchor.constraint(equalTo: userFIO.bottomAnchor, constant: 8),
            loginName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        NSLayoutConstraint.activate([
            comments.topAnchor.constraint(equalTo: loginName.bottomAnchor, constant: 8),
            comments.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
    }
    // MARK: - Public Methods
    func configure(
        avatarGet: UIImage,
        loginNameGet: String,
        commentsGet: String
    ) {
        avatar.image = avatarGet
        loginName.text = loginNameGet
        comments.text = commentsGet
    }
    // MARK: - Actions
    @objc private func tapExit(_ sender: UIButton) {
        print("Нажата кнопка выход")
        
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            ProfileLogoutService.shared.logout()
            let navController = UINavigationController(rootViewController: AuthViewController())
            navController.modalPresentationStyle = .fullScreen
            self?.present(navController, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        
        present(alert, animated: true)
    }
}
//MARK: SwiftUI - for working canvas
import SwiftUI
struct ProfileViewControllerProvider: PreviewProvider {
    static var previews: some View {
        VCProvider<ProfileViewController>.previews
    }
}
