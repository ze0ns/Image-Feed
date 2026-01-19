//
//  ViewController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//

import UIKit

class ProfileViewController: UIViewController {
    
    
    private lazy var userFIO = UILabel()
    private lazy var loginName = UILabel()
    private lazy var comments = UILabel()
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupConstraints()
    }
    
    private func setupViews(){
        userFIO.text = "Екатерина Новикова"
        userFIO.textColor = .white
        userFIO.font = .boldSystemFont(ofSize: 23)
        
        loginName.text = "@ekaterina_nov"
        loginName.textColor = .gray
        loginName.font = .systemFont(ofSize: 13)
        
        comments.text = "Hello, world!"
        comments.textColor = .white
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
