// HomeView.swift
import SwiftUI

struct HomeView: View {
    @Bindable var vm: EventsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading events…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let msg = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load events").font(.headline)
                        Text(msg).font(.subheadline).foregroundStyle(.secondary)
                        Button("Retry") { Task { await vm.load() } }
                    }.padding()
                } else if vm.visibleEvents.isEmpty {
                    ContentUnavailableView(
                        "No events yet",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Pull to refresh or create a new one.")
                    )
                } else {
                    ScrollView {
                        // Filter/Sort row (they don’t have to do anything yet)
                        HStack {
                            Menu {
                                Button("All") { vm.selectedFilter = .all }
                                Button("Upcoming") { vm.selectedFilter = .upcoming }
                                Button("Past") { vm.selectedFilter = .past }
                            } label: {
                                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                            }

                            Menu {
                                Button("Date") { vm.selectedSort = .date }
                                Button("A–Z") { vm.selectedSort = .alphabetical }
                            } label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                            }

                            Spacer()

                            NavigationLink {
                                AddEventView(vm: AddEventViewModel()) { newEvent in
                                    vm.add(newEvent)
                                }
                            } label: {
                                Label("+ Create Event", systemImage: "plus.circle.fill")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(vm.visibleEvents) { event in
                                NavigationLink(value: event) {
                                    EventCardView(event: event)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .refreshable { await vm.load() }
                    .navigationDestination(for: Event.self) { event in
                        EventDetailsView(event: event) { updated in
                            vm.applyUpdate(updated)
                            // optional: also call an update API
                        }
                    }
                }
            }
            .navigationTitle("Gatherly")
            .task { await vm.load() }
        }
        .searchable(text: $vm.searchText)
    }
}
