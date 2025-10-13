//
//  EventsViewModel.swift
//  Gatherly
//
//  Created by Francesca Fabiano-Grossi on 10/6/25.
//
// EventsViewModel.swift
import Foundation
import Observation

@Observable
final class EventsViewModel {
    // Raw state
    var events: [Event] = []
    var isLoading = false
    var errorMessage: String? = nil

    // Search state
    var searchText: String = ""

    // Filter/sort state (you can wire these later)
    enum Filter { case all, upcoming, past }
    enum Sort { case date, alphabetical }
    var selectedFilter: Filter = .all
    var selectedSort: Sort = .date

    // Derived (computed) list the View shows
    var visibleEvents: [Event] {
        var list = events

        // Filter
        switch selectedFilter {
        case .all:
            break
        case .upcoming:
            list = list.filter { ($0.parsedDate ?? .distantPast) >= Date() }
        case .past:
            list = list.filter { ($0.parsedDate ?? .distantFuture) < Date() }
        }

        // Search
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        // Sort
        switch selectedSort {
        case .date:
            list.sort {
                ($0.parsedDate ?? .distantPast) < ($1.parsedDate ?? .distantPast)
            }
        case .alphabetical:
            list.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return list
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await EventService.shared.fetchEvents()
            events = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // Local update after edits
    func applyUpdate(_ updated: Event) {
        if let i = events.firstIndex(where: { $0.id == updated.id }) {
            events[i] = updated
        }
    }

    // Local add after creating a new event
    func add(_ new: Event) {
        events.insert(new, at: 0)
    }
}
