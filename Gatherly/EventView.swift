import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: String
    var creatorPid: String
    var title: String
    var location: String
    var description: String
    var timestamp: String
    var image_url: String?
}

extension Event {
    static let example = Event(
        id: "abc123",
        creatorPid: "123456789",
        title: "Sunset Concert",
        location: "Student Union Ballroom",
        description: "Join fellow students for a night of collaborative coding, snacks, and fun.",
        timestamp: "Aug 8, 2025",
        image_url: nil
    )

    // ✅ Only one parsedDate exists now
    var parsedDate: Date? {
        let formats = [
            "MMM d, yyyy",            
            "MMMM d, yyyy",
            "MMMM d, yyyy, h:mm a",
            "yyyy-MM-dd"
        ]

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)

        for format in formats {
            df.dateFormat = format
            if let d = df.date(from: timestamp) {
                return d
            }
        }
        return nil
    }
}

