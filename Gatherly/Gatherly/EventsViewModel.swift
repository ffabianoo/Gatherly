import Foundation
import Observation
import PhotosUI
import SwiftUI

@Observable
@MainActor
final class EventsViewModel {
    // UI state (like lesson LoadingState demo)
    enum ScreenState { case idle, loading, success(String), failure(String) }
    enum SaveState   { case idle, loading, success(String), failure(String) }

    var screenState: ScreenState = .idle
    var saveState: SaveState = .idle

    // Data
    var events: [Event] = []
    var errorMessage: String?
    var isLoading = false

    // Search / filter / sort
    var searchText: String = ""
    enum Filter { case all, upcoming, past }
    enum Sort { case date, alphabetical }
    var selectedFilter: Filter = .all
    var selectedSort: Sort = .date

    // Shared form state (Add/Edit)
    var title: String = ""
    var location: String = ""
    var descriptionText: String = ""
    var date: Date = Date().addingTimeInterval(3600)

    // Image picking (lesson pattern)
    var selectedPhoto: PhotosPickerItem?
    var uiImage: UIImage?
    var image: Image? { uiImage.map(Image.init(uiImage:)) }

    var isSaving: Bool {
        if case .loading = saveState { return true }
        return false
    }

    // Derived list for Home
    var visibleEvents: [Event] {
        var list = events

        switch selectedFilter {
        case .all: break
        case .upcoming: list = list.filter { $0.timestamp >= Date() }
        case .past:     list = list.filter { $0.timestamp < Date() }
        }

        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        switch selectedSort {
        case .date:         list.sort { $0.timestamp < $1.timestamp }
        case .alphabetical: list.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return list
    }

    // PhotosPicker loader
    func loadImage() async {
        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
            self.uiImage = UIImage(data: data)
        }
    }

    func resetForm(with event: Event? = nil) {
        if let e = event {
            title = e.title
            location = e.location
            descriptionText = e.description
            date = e.timestamp
        } else {
            title = ""
            location = ""
            descriptionText = ""
            date = Date().addingTimeInterval(3600)
        }
        selectedPhoto = nil
        uiImage = nil
        saveState = .idle
    }

    // Networking
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        screenState = .loading
        defer { isLoading = false }

        do {
            events = try await EventService.shared.getEvents()
            errorMessage = nil
            screenState = .success("Loaded")
        } catch {
            errorMessage = error.localizedDescription
            screenState = .failure(error.localizedDescription)
        }
    }

    func create() async {
        saveState = .loading
        do {
            let created = try await EventService.shared.createEvent(
                title: title,
                description: descriptionText,
                timestamp: date,
                location: location,
                uiImage: uiImage
            )
            events.insert(created, at: 0)
            saveState = .success("Created")
        } catch {
            saveState = .failure(error.localizedDescription)
        }
    }

    func saveEdit(for id: String) async {
        saveState = .loading
        do {
            let updated = try await EventService.shared.editEvent(
                id: id,
                title: title,
                description: descriptionText,
                timestamp: date,
                location: location,
                uiImage: uiImage
            )
            if let i = events.firstIndex(where: { $0.id == id }) {
                events[i] = updated
            }
            saveState = .success("Saved")
        } catch {
            saveState = .failure(error.localizedDescription)
        }
    }

    func delete(id: String) async {
        do {
            try await EventService.shared.deleteEvent(id: id)
            events.removeAll { $0.id == id }
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
        }
    }
}
