import Foundation

// Matches backend: { "events": [ ... ] }
struct EventsResponse: Codable {
    let events: [Event]
}

struct Event: Hashable, Codable, Identifiable {
    var id: String?                          // server assigns on POST
    var creatorPid: String = "YOUR_PID_HERE" // <-- set yours
    var title: String
    var location: String
    var description: String
    var timestamp: Date                      // ISO-8601 (e.g., 2025-10-27T02:42:55Z)

    // GET-only: URL for display
    var image_url: String?

    // POST/PUT-only: base64 data URL when uploading
    var image: String?
}
