import Foundation

struct EventsResponse: Decodable {
    let events: [Event]
}

final class EventService {
    static let shared = EventService()
    private init() {}

    private let base = "https://gatherly-backend-q9vm.onrender.com"

    func fetchEvents() async throws -> [Event] {
        guard let url = URL(string: "\(base)/events") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        #if DEBUG
        if let raw = String(data: data, encoding: .utf8) { print("Raw /events JSON:\n\(raw)") }
        #endif
        return try JSONDecoder().decode(EventsResponse.self, from: data).events
    }
}
