import SwiftUI

struct EventDetailsView: View {
    let event: Event
    var onUpdate: (Event) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showActions = false
    @State private var goToEdit = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    var body: some View {
        ScrollView {
            // Header image (uses your shared helper)
            EventImageView(urlString: event.image_url, height: 240)

            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(event.title)
                    .font(.title.bold())

                // Date (timestamp is Date)
                Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Location
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(event.location)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider().overlay(.clear)

                // About
                Text("About").font(.headline)
                Text(event.description).font(.body)

                // RSVP-style primary button (matches Figma look you used elsewhere)
                Button {
                    // TODO: RSVP flow later
                } label: {
                    Text("RSVP")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Back handled by default; add actions menu on the right
            ToolbarItem(placement: .topBarTrailing) {
                Button { showActions = true } label: {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                }
                .accessibilityLabel("More actions")
            }
        }
        .confirmationDialog("Actions",
                            isPresented: $showActions,
                            titleVisibility: .visible) {
            Button("Edit Event") { goToEdit = true }

            if let s = event.image_url, let url = URL(string: s) {
                ShareLink("Share", item: url)
            } else {
                ShareLink("Share", item: "Check out \(event.title) at \(event.location)")
            }

            Button(isDeleting ? "Deleting…" : "Delete", role: .destructive) {
                Task { await deleteCurrentEvent() }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete Failed", isPresented: .constant(deleteError != nil)) {
            Button("OK") { deleteError = nil }
        } message: {
            Text(deleteError ?? "")
        }
        .navigationDestination(isPresented: $goToEdit) {
            EditEventView(event: event) { updated in
                onUpdate(updated)   // bubble change up to parent view model
            }
        }
    }

    // MARK: - Delete
    private func deleteCurrentEvent() async {
        guard let id = event.id, !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await EventService.shared.deleteEvent(id: id)
            dismiss()
        } catch {
            deleteError = error.localizedDescription
        }
    }
}
