//
//  ProfileViewPresenter.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 22.02.2026.
//

import UIKit

// MARK: - Profile Presenter Protocol
protocol ProfilePresenterProtocol {
    func viewDidLoad()
    func viewDidLayoutSubviews()
    func didTapLogout()
    func handleAvatarUpdate()
}

// MARK: - Profile Presenter
final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Properties
    private weak var view: ProfileViewProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Initializer
    init(view: ProfileViewProtocol,
         profileService: ProfileService = .shared,
         profileImageService: ProfileImageService = .shared,
         logoutService: ProfileLogoutService = .shared) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        setupObservers()
        loadProfileData()
        loadAvatar()
    }
    
    func viewDidLayoutSubviews() {
        // Обработка layout если нужно
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func handleAvatarUpdate() {
        loadAvatar()
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleAvatarUpdate()
            }
    }
    
    private func loadProfileData() {
        if let profile = profileService.profile {
            view?.displayProfileData(
                name: profile.name,
                login: profile.loginName,
                bio: profile.bio ?? "Нет описания"
            )
        }
    }
    
    private func loadAvatar() {
        guard let imageUrl = URL(string: profileImageService.userImage) else {
            view?.showAvatarSkeleton()
            return
        }
        view?.hideAvatarSkeleton()
        view?.displayAvatar(url: imageUrl)
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
