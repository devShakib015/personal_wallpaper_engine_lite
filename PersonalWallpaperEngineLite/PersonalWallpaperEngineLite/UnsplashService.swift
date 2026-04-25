import Foundation

// MARK: - Pexels API Service
// Free API — get your key at https://www.pexels.com/api/
// Set your key in the Settings tab or in UserDefaults key "pexels_api_key"

final class UnsplashService {   // Name kept for compatibility — backed by Pexels

    static let shared = UnsplashService()
    private init() {}

    private let baseURL = "https://api.pexels.com/v1"

    // Returns a single random photo for the provided query terms
    func fetchRandomPhoto(from queries: [String],
                          completion: @escaping (Result<PexelsPhoto, Error>) -> Void) {
        let key = accessKey
        guard !key.isEmpty else {
            completion(.failure(ServiceError.missingAPIKey)); return
        }

        let query = queries.joined(separator: " ")
        // Pick a random page (1–5) for variety within free tier limits
        let randomPage = Int.random(in: 1...5)

        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "query",       value: query),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "per_page",    value: "15"),
            URLQueryItem(name: "page",        value: "\(randomPage)")
        ]

        guard let url = components.url else {
            completion(.failure(ServiceError.invalidURL)); return
        }

        var request = URLRequest(url: url)
        request.setValue(key, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(ServiceError.noData)); return }
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                guard let photo = result.photos.randomElement() else {
                    completion(.failure(ServiceError.noData)); return
                }
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
                     completion: @escaping (Result<[PexelsPhoto], Error>) -> Void) {
        let key = accessKey
        guard !key.isEmpty else {
            completion(.failure(ServiceError.missingAPIKey)); return
        }

        let query = queries.joined(separator: " ")
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "query",       value: query),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "per_page",    value: "\(perPage)"),
            URLQueryItem(name: "page",        value: "\(page)")
        ]

        guard let url = components.url else {
            completion(.failure(ServiceError.invalidURL)); return
        }

        var request = URLRequest(url: url)
        request.setValue(key, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(ServiceError.noData)); return }
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(result.photos))
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
        if let saved = UserDefaults.standard.string(forKey: "pexels_api_key"), !saved.isEmpty {
            return saved
        }
        return ""
    }

    private struct SearchResult: Codable {
        let photos: [PexelsPhoto]
    }

    enum ServiceError: LocalizedError {
        case missingAPIKey, invalidURL, noData

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Pexels API key is missing. Please add it in Settings."
            case .invalidURL:    return "Invalid URL."
            case .noData:        return "No data received from server."
            }
        }
    }
}
