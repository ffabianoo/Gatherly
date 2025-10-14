import SwiftUI

struct HomeView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading events…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load events")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            Task { await load() }
                        }
                    }
                    .padding()
                } else if events.isEmpty {
                    ContentUnavailableView(
                        "No events yet",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Pull to refresh or check back later.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(events) { event in
                                NavigationLink(value: event) {
                                    EventCardView(event: event)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .refreshable {
                        await load()
                    }
                    .navigationDestination(for: Event.self) { event in
                        EventDetailsView(event: event)
                    }
                }
            }
            .navigationTitle("Gatherly")
            .task {
                await load()
            }
        }
    }

    private func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await EventService.shared.fetchEvents()
            await MainActor.run {
                self.events = fetched
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }
}

#Preview {
    HomeView()
}

