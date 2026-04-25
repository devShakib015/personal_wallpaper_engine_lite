import Foundation

// MARK: - Pexels Models

struct PexelsPhoto: Identifiable, Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let src: PhotoSrc
    let alt: String?

    // Identifiable conformance needs String-based id for SwiftUI ForEach
    var stringId: String { String(id) }
}

extension PexelsPhoto {
    // Make Identifiable use the integer id directly
    typealias ID = Int
}

struct PhotoSrc: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let landscape: String
    let tiny: String
}
