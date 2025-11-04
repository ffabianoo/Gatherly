import SwiftUI

struct EventDetailsView: View {
    let event: Event
    let vm: EventsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showActions = false
    @State private var goToEdit = false

    var body: some View {
        ScrollView {
            EventImageView(urlString: event.image_url, height: 240)

            VStack(alignment: .leading, spacing: 12) {
                Text(event.title).font(.title.bold())

                Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline).foregroundStyle(.secondary)

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
                    // future RSVP
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
            if let id = event.id {
                Button("Delete", role: .destructive) {
                    Task {
                        await vm.delete(id: id)
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .navigationDestination(isPresented: $goToEdit) {
            EditEventView(event: event, vm: vm)
        }
    }
}
