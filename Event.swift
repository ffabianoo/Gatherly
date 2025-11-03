import Foundation

struct Event: Identifiable, Hashable, Codable {
    var id: String?                       // optional until server creates it
    var creatorPid: String = "123456789"  // <-- set to your actual PID
    var title: String
    var location: String
    var description: String
    var timestamp: Date                   // use ISO8601 in service

    // Returned by GET; used to render remote images
    var image_url: String?

    // Used when encoding for POST/PUT
    var image: String?
}

