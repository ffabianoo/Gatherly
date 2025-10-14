import Foundation
import Observation

@Observable
final class AddEventViewModel {
    var title: String = ""
    var location: String = ""
    var descriptionText: String = ""
    var date: Date = Date()

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func buildEvent() -> Event {
        let iso = ISO8601DateFormatter()
        return Event(
            id: UUID().uuidString,      // temp client id; replace with server id on POST later
            creatorPid: "123456789",    // stub for now
            title: title,
            location: location,
            description: descriptionText,
            timestamp: iso.string(from: date),
            image_url: nil
        )
    }
}
