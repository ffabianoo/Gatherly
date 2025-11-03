import Foundation
import Observation

@Observable
final class EventsViewModel {
    // Raw state
    var events: [Event] = []
    var isLoading = false
    var errorMessage: String?

    // Search / filter / sort state
    var searchText: String = ""
    enum Filter { case all, upcoming, past }
    enum Sort { case date, alphabetical }
    var selectedFilter: Filter = .all
    var selectedSort: Sort = .date

    // Derived view data
    var visibleEvents: [Event] {
        var list = events

        // Filter
        switch selectedFilter {
        case .all: break
        case .upcoming:
            list = list.filter { $0.timestamp >= Date() }
        case .past:
            list = list.filter { $0.timestamp < Date() }
        }

        // Search
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        // Sort
        switch selectedSort {
        case .date:
            list.sort { $0.timestamp < $1.timestamp }
        case .alphabetical:
            list.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return list
    }

    // Actions
    func load() async {
        guard !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        errorMessage = nil
        do {
            let fetched = try await EventService.shared.fetchEvents()
            self.events = fetched           // no MainActor.run wrapper
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func add(_ new: Event) {
        events.insert(new, at: 0)
    }

    func applyUpdate(_ updated: Event) {
        if let i = events.firstIndex(where: { $0.id == updated.id }) {
            events[i] = updated
        }
    }
}
