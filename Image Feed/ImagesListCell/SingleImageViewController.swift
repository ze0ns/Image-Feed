//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 20.01.2026.
//

import UIKit

class SingleImageViewController: UIViewController {
    private let imagesView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    private func setupViews() {
        imagesView.image = UIImage(resource: ._10)
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
         
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    private lazy var backButton: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Back", for: .normal)
          button.setTitleColor(.systemBlue, for: .normal)
          button.translatesAutoresizingMaskIntoConstraints = false
          
          button.addTarget(self, action: #selector(backToFirstScreen), for: .touchUpInside)
          return button
      }()
    @objc private func backToFirstScreen() {
           guard let navController = navigationController else { return }
           
           // Возвращаем исходный экран как root
           let sourceVC = ImagesListViewController()
           navController.setViewControllers([sourceVC], animated: true)
       }
}
