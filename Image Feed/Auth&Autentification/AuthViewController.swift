//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 23.01.2026.
//

import UIKit
final class AuthViewController: UIViewController {
    // MARK: - UI Elements
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.circle.fill") // Системная иконка
        // Или используйте свою картинку: UIImage(named: "your_image_name")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вход", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
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
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Изображение по центру
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Кнопка внизу
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        print("Кнопка 'Вход' нажата")
        let nextVC = WebViewViewController()
        let navController = UINavigationController(rootViewController: nextVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
