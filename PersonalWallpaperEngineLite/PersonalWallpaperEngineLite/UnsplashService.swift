import Foundation

// MARK: - Unsplash API Service
// Requires a free Unsplash Developer Access Key.
// Set your key in UserDefaults key "unsplash_access_key" or replace the placeholder below.

final class UnsplashService {

    static let shared = UnsplashService()
    private init() {}

    private let baseURL = "https://api.unsplash.com"

    // Returns a single random photo for the provided query terms
    func fetchRandomPhoto(from queries: [String],
                          completion: @escaping (Result<UnsplashPhoto, Error>) -> Void) {
        let key = accessKey
        guard !key.isEmpty else {
            completion(.failure(ServiceError.missingAPIKey))
            return
        }

        let query = queries.joined(separator: ",")
        var components = URLComponents(string: "\(baseURL)/photos/random")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "client_id", value: key)
        ]

        guard let url = components.url else {
            completion(.failure(ServiceError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                completion(.failure(ServiceError.noData)); return
            }
            do {
                let photo = try JSONDecoder().decode(UnsplashPhoto.self, from: data)
                completion(.success(photo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Fetch a page of photos for the grid preview
    func fetchPhotos(from queries: [String],
                     page: Int = 1,
                     perPage: Int = 20,
                     completion: @escaping (Result<[UnsplashPhoto], Error>) -> Void) {
        let key = accessKey
        guard !key.isEmpty else {
            completion(.failure(ServiceError.missingAPIKey))
            return
        }

        let query = queries.joined(separator: ",")
        var components = URLComponents(string: "\(baseURL)/search/photos")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "client_id", value: key)
        ]

        guard let url = components.url else {
            completion(.failure(ServiceError.invalidURL)); return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(ServiceError.noData)); return }
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Download raw image data
    func downloadImage(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL)); return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(ServiceError.noData)); return }
            completion(.success(data))
        }.resume()
    }

    // MARK: - Private
    var accessKey: String {
        // Priority: UserDefaults > hardcoded placeholder
        if let saved = UserDefaults.standard.string(forKey: "unsplash_access_key"), !saved.isEmpty {
            return saved
        }
        // Replace this with your actual Unsplash Access Key
        return ""
    }

    private struct SearchResult: Codable {
        let results: [UnsplashPhoto]
    }

    enum ServiceError: LocalizedError {
        case missingAPIKey, invalidURL, noData

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Unsplash API key is missing. Please add it in Settings."
            case .invalidURL:    return "Invalid URL."
            case .noData:        return "No data received from server."
            }
        }
    }
}
