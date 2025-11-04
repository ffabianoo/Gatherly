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
                switch vm.screenState {
                case .loading:
                    ProgressView("Loading events…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failure(let msg):
                    VStack(spacing: 12) {
                        Text("Failed to load events").font(.headline)
                        Text(msg).font(.subheadline).foregroundStyle(.secondary)
                        Button("Retry") { Task { await vm.load() } }
                    }
                    .padding()

                default:
                    if vm.visibleEvents.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Pull to refresh or create a new one.")
                        )
                    } else {
                        ScrollView {
                            // Filter / Sort / Create
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
                                    AddEventView(vm: vm)   // reuse same VM
                                } label: {
                                    Label("Create Event", systemImage: "plus.circle.fill")
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
                            EventDetailsView(event: event, vm: vm) // reuse same VM
                        }
                    }
                }
            }
            .navigationTitle("Gatherly")
            .task { await vm.load() }
        }
        .searchable(text: $vm.searchText)
        .buttonStyle(.plain) // keep cards from looking like buttons
    }
}

// Small card (ensure you only have ONE definition project-wide)
struct EventCardView: View {
    let event: Event

    var body: some View {
        VStack(spacing: 0) {
            EventImageView(urlString: event.image_url, height: 160)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(event.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08))
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

