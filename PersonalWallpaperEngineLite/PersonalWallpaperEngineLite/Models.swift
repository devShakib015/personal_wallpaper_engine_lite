import Foundation

// MARK: - Unsplash Models

struct UnsplashPhoto: Identifiable, Codable {
    let id: String
    let urls: PhotoURLs
    let description: String?
    let altDescription: String?

    enum CodingKeys: String, CodingKey {
        case id, urls, description
        case altDescription = "alt_description"
    }
}

struct PhotoURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
