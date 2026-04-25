import Foundation

// MARK: - Wallpaper Category

enum WallpaperCategory: String, CaseIterable, Identifiable, Codable {
    case nature   = "nature"
    case city     = "city"
    case minimal  = "minimal"
    case abstract = "abstract"
    case space    = "space"
    case architecture = "architecture"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .nature:       return "Nature"
        case .city:         return "City"
        case .minimal:      return "Minimal"
        case .abstract:     return "Abstract"
        case .space:        return "Space"
        case .architecture: return "Architecture"
        }
    }

    var icon: String {
        switch self {
        case .nature:       return "leaf"
        case .city:         return "building.2"
        case .minimal:      return "square"
        case .abstract:     return "scribble"
        case .space:        return "moon.stars"
        case .architecture: return "house"
        }
    }
}
