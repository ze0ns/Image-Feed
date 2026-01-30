import Foundation

// MARK: - ProfileImageModel
struct UserResult: Codable {
    let profileImage: ProfileImage
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}

