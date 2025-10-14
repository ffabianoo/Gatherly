import SwiftUI

struct EventDetailsView: View {
    let event: Event
    var onUpdate: (Event) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showActions = false
    @State private var goToEdit = false

    var body: some View {
        ScrollView {
            EventImageView(urlString: event.image_url, height: 240)

            VStack(alignment: .leading, spacing: 12) {
                Text(event.title).font(.title.bold())

                if let date = event.parsedDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline).foregroundStyle(.secondary)
                } else {
                    Text(event.timestamp).font(.subheadline).foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(event.location)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider().overlay(.clear)

                Text("About").font(.headline)
                Text(event.description).font(.body)

                Button {
                    // TODO: RSVP later
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
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showActions = true } label: {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                }
                .accessibilityLabel("More actions")
            }
        }
        .confirmationDialog("Actions", isPresented: $showActions, titleVisibility: .visible) {
            Button("Edit Event") { goToEdit = true }
            if let s = event.image_url, let url = URL(string: s) {
                ShareLink("Share", item: url)
            } else {
                ShareLink("Share", item: "Check out \(event.title) at \(event.location)")
            }
            Button("Delete", role: .destructive) {
                // TODO: Wire delete API; then dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
        .navigationDestination(isPresented: $goToEdit) {
            EditEventView(event: event) { updated in
                onUpdate(updated)
            }
        }
    }
}
