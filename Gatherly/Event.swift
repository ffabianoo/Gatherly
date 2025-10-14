import Foundation

struct Event: Identifiable, Hashable, Codable {
    var id: String
    var creatorPid: String?
    var title: String
    var location: String
    var description: String
    var timestamp: String        // ISO8601 from backend
    var image_url: String?       // snake_case matches backend

    var parsedDate: Date? {
        ISO8601DateFormatter().date(from: timestamp)
    }

    static let example = Event(
        id: "demo-1",
        creatorPid: "123456789",
        title: "Campus Career Fair",
        location: "UNC Student Union",
        description: "Meet recruiters and explore roles.",
        timestamp: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86_400)),
        image_url: nil
    )
}
