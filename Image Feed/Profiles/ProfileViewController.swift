//
//  ViewController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var userFIO = UILabel()
    private lazy var loginName = UILabel()
    private lazy var comments = UILabel()
    private lazy var storege = OAuth2TokenStorage.shared
    private var profileService = ProfileService()
    
    private lazy var avatar: UIImageView = {
        var avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 16
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
        fetchProfile()
        setupViews()
        setupConstraints()
    }
    // MARK: - Private Methods, Fetch Data
    private func fetchProfile(){
        guard let token = storege.get() else { return  }
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.userFIO.text = profile.name.isEmpty ? "Имя не задано": profile.name
                self.comments.text = profile.bio ?? "Профиль не заполнен"
                self.loginName.text = profile.username.isEmpty ? "Имя не задано" : "@\(String(describing: profile.username))"
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    // MARK: - Private Methods, configure UI
    private func setupViews(){
        userFIO.text = "Екатерина Новикова"
        userFIO.textColor = .ypWhite
        userFIO.font = .boldSystemFont(ofSize: 23)
        
        loginName.text = "@ekaterina_nov"
        loginName.textColor = .ypGray
        loginName.font = .systemFont(ofSize: 13)
        
        comments.text = "Hello, world!"
        comments.textColor = .ypWhite
        comments.font = .systemFont(ofSize: 13)
        
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
    // MARK: - Private Methods, configure Constraints
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatar.heightAnchor.constraint(equalToConstant: 70),
            avatar.widthAnchor.constraint(equalToConstant: 70)
        ])
        
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
}

//MARK: - SwiftUI
import SwiftUI
struct ProfileVCProvider: PreviewProvider{
    
    static var previews: some View{
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let tabBarVC = ProfileViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ProfileVCProvider.ContainerView>) ->
        ProfileViewController{
            return tabBarVC
        }
        func updateUIViewController(_ uiViewController: ProfileVCProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ProfileVCProvider.ContainerView>) {
            
        }
    }
    
}
