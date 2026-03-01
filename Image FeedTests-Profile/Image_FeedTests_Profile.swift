//
//  Image_FeedTests_Profile.swift
//  Image FeedTests-Profile
//
//  Created by Oschepkov Aleksandr on 28.02.2026.
//

import XCTest
@testable import Image_Feed


// MARK: - Mock Objects
final class MockProfileViewController: ProfileViewProtocol {
    var isDisplayProfileDataCalled = false
    var isDisplayAvatarCalled = false
    
    var receivedName: String?
    var receivedLogin: String?
    var receivedBio: String?
    var receivedAvatarURL: URL?
    
    func displayProfileData(name: String, login: String, bio: String) {
        isDisplayProfileDataCalled = true
        receivedName = name
        receivedLogin = login
        receivedBio = bio
    }
    
    func displayAvatar(url: URL?) {
        isDisplayAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func showAvatarSkeleton() {}
    func hideAvatarSkeleton() {}
    func showLogoutConfirmation() {}
}

final class MockProfileService: ProfileServiceProtocol {
    var mockProfile: Profile?
    
    var profile: Profile? {
        return mockProfile
    }
}

final class MockProfileImageService: ProfileImageServiceProtocol {
    var mockUserImageURL: String = ""
    
    var userImage: String {
        return mockUserImageURL
    }
}
final class ProfilePresenterTests: XCTestCase {

    var presenter: ProfilePresenter!
    var mockView: MockProfileViewController!
    var mockProfileService: MockProfileService!
    var mockImageService: MockProfileImageService!

    override func setUp() {
        super.setUp()
        
        mockView = MockProfileViewController()
        mockProfileService = MockProfileService() // Теперь это работает
        mockImageService = MockProfileImageService() // И это тоже
        
        presenter = ProfilePresenter(
            view: mockView,
            profileService: mockProfileService,
            profileImageService: mockImageService
        )
    }

    func testViewDidLoadCallsDisplayProfileDataAndDisplayAvatar() {
        // Arrange
        let testProfile = Profile(username: "u", name: "Name", loginName: "@login", bio: "Bio")
        mockProfileService.mockProfile = testProfile
        mockImageService.mockUserImageURL = "https://test.com/img.png"
        
        // Act
        presenter.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.isDisplayProfileDataCalled)
        XCTAssertEqual(mockView.receivedName, "Name")
        XCTAssertTrue(mockView.isDisplayAvatarCalled)
    }
}
