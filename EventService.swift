import Foundation
import Observation
import UIKit

struct EventsResponse: Decodable {
    let events: [Event]
}

@Observable
final class EventService {
    static let shared = EventService()
    private init() {}

    private let base = URL(string: "https://gatherly-backend-q9vm.onrender.com")!

    // MARK: - GET (Fetch all events)
    func fetchEvents() async throws -> [Event] {
        let url = base.appending(path: "events")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // backend returns { "events": [...] }
        return try decoder.decode(EventsResponse.self, from: data).events
    }

    // MARK: - POST (Create an event)
    func createEvent(
        title: String,
        description: String,
        timestamp: Date,
        location: String,
        uiImage: UIImage? = nil
    ) async throws -> Event? {

        let url = base.appending(path: "events")

        var imageString: String?
        if let uiImage, let data = uiImage.jpegData(compressionQuality: 0.8) {
            imageString = "data:image/jpeg;base64,\(data.base64EncodedString())"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = Event(
            id: nil,
            creatorPid: "123456789",   // ← replace with your PID
            title: title,
            location: location,
            description: description,
            timestamp: timestamp,
            image_url: nil,
            image: imageString
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            print("❌ Failed to create event")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Event.self, from: data)
    }

    // MARK: - PUT (Edit an event)
    func editEvent(
        id: String,
        title: String,
        description: String,
        timestamp: Date,
        location: String,
        uiImage: UIImage? = nil
    ) async throws -> Event? {

        let url = base.appending(path: "events/\(id)")

        var imageString: String?
        if let uiImage, let data = uiImage.jpegData(compressionQuality: 0.8) {
            imageString = "data:image/jpeg;base64,\(data.base64EncodedString())"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = Event(
            id: id,
            creatorPid: "123456789",   // ← replace with your PID
            title: title,
            location: location,
            description: description,
            timestamp: timestamp,
            image_url: nil,
            image: imageString
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            print("❌ Failed to edit event")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Event.self, from: data)
    }

    // MARK: - DELETE (Remove an event)
    func deleteEvent(id: String) async throws {
        let url = base.appending(path: "events/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Only the creator can delete; send PID in body
        let body = ["creatorPid": "123456789"]   // ← replace with your PID
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.cannotRemoveFile)
        }
    }
}
