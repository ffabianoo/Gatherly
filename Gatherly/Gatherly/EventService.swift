import Foundation
import Observation
import UIKit

@Observable
final class EventService {
    static let shared = EventService()
    private init() {}

    private let baseURL = URL(string: "https://gatherly-backend-q9vm.onrender.com/")!

    // MARK: GET /events  → EventsResponse → [Event]
    func getEvents() async throws -> [Event] {
        let url = baseURL.appendingPathComponent("events")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        #if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("GET /events raw:\n\(raw)")
        }
        #endif

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return try dec.decode(EventsResponse.self, from: data).events
    }

    // MARK: POST /events → Event
    func createEvent(
        title: String,
        description: String,
        timestamp: Date,
        location: String,
        uiImage: UIImage? = nil
    ) async throws -> Event {
        let url = baseURL.appendingPathComponent("events")

        var imageString = ""
        if let uiImage, let data = uiImage.jpegData(compressionQuality: 0.8) {
            imageString = "data:image/jpeg;base64,\(data.base64EncodedString())"
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = Event(
            id: nil,
            creatorPid: "YOUR_PID_HERE",
            title: title,
            location: location,
            description: description,
            timestamp: timestamp,
            image_url: nil,
            image: imageString
        )

        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        req.httpBody = try enc.encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 201 else {
            throw URLError(.cannotCreateFile)
        }

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return try dec.decode(Event.self, from: data)
    }

    // MARK: PUT /events/{id} → Event
    func editEvent(
        id: String,
        title: String,
        description: String,
        timestamp: Date,
        location: String,
        uiImage: UIImage? = nil
    ) async throws -> Event {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent(id)

        var imageString = ""
        if let uiImage, let data = uiImage.jpegData(compressionQuality: 0.8) {
            imageString = "data:image/jpeg;base64,\(data.base64EncodedString())"
        }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = Event(
            id: id,
            creatorPid: "YOUR_PID_HERE",
            title: title,
            location: location,
            description: description,
            timestamp: timestamp,
            image_url: nil,
            image: imageString
        )

        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        req.httpBody = try enc.encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.cannotWriteToFile)
        }

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return try dec.decode(Event.self, from: data)
    }

    // MARK: DELETE /events/{id}
    func deleteEvent(id: String) async throws {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent(id)

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Backend requires your creatorPid in the body
        let body = ["creatorPid": "YOUR_PID_HERE"]
        req.httpBody = try JSONEncoder().encode(body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.cannotRemoveFile)
        }
    }
}
