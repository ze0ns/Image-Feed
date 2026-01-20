//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 20.01.2026.
//

import UIKit

class SingleImageViewController: UIViewController {
    private let imagesView = UIImageView()
    var imageURL = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    private func setupViews() {
        imagesView.image = imageURL
        imagesView.contentMode = .scaleAspectFill
        imagesView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imagesView)
        view.addSubview(backButton)
    }
    // MARK: - Private Methods, setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imagesView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            imagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imagesView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -4),
         
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
          button.setImage(UIImage(resource: .backward), for: .normal)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.addTarget(self, action: #selector(backToFirstScreen), for: .touchUpInside)
          return button
      }()
    @objc private func backToFirstScreen() {
           guard let navController = navigationController else { return }
           let sourceVC = MainTabBarController()
           navController.setViewControllers([sourceVC], animated: true)
       }
}
