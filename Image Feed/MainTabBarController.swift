//
//  MainTabBarController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//
import UIKit
class MainTabBarController: UITabBarController {
    
    private let customTabBarHeight: CGFloat = 83
    private var customTabBar: CustomTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        makeUI()
    }

    private func setupCustomTabBar() {
        // Скрываем стандартный tabBar
        tabBar.isHidden = true

        // Элементы вкладок
        let tabItems = [
            UITabBarItem(title: "", image: UIImage(resource: .activeLenta), tag: 0),
            UITabBarItem(title: "", image: UIImage(resource: .activeProfile), tag: 1)
        ]

        // Создаём кастомный TabBar
        customTabBar = CustomTabBar(items: tabItems)
        customTabBar.backgroundColor = .ypBlack
        customTabBar.height = customTabBarHeight
        customTabBar.translatesAutoresizingMaskIntoConstraints = false


        // Обрабатываем выбор вкладки через замыкание
        customTabBar.onItemSelected = { [weak self] index in
            self?.selectedIndex = index  // Переключаем вкладку
        }

        view.addSubview(customTabBar)

        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: customTabBarHeight)
        ])
    }
    private func makeUI() {
        let firstVC = ImagesListViewController()
        let secondVC = ProfileViewController()
        viewControllers = [firstVC, secondVC]
    }
    // Синхронизируем визуальный статус при переключении через контроллер
     func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        customTabBar.selectedIndex = index
    }
}
