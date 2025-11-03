import SwiftUI
import PhotosUI
import UIKit

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    var event: Event
    var onSave: (Event) -> Void

    @State private var title: String
    @State private var location: String
    @State private var descriptionText: String
    @State private var date: Date
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var uiImage: UIImage?

    init(event: Event, onSave: @escaping (Event) -> Void) {
        self.event = event
        self.onSave = onSave
        _title = State(initialValue: event.title)
        _location = State(initialValue: event.location)
        _descriptionText = State(initialValue: event.description)
        _date = State(initialValue: event.timestamp)
    }

    var body: some View {
        // inside var body: some View
        SwiftUI.Form {

            // Cover Photo picker styled per Figma (square with thinMaterial, plain plus)
            Section {
                HStack {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .padding(20)                   // square hit area
                            .background(.thinMaterial)     // per Figma
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .task(id: selectedPhoto) {
                        await loadImage()
                    }

                    if let uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                    }
                }
            }

            Section("Details") {
                TextField("Title", text: $title)
                TextField("Location", text: $location)
                DatePicker("Date and Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Description") {
                TextEditor(text: $descriptionText)       // no minHeight per review
            }

            Section {
                Button {
                    Task {
                        guard let id = event.id else { return }
                        _ = try? await EventService.shared.editEvent(
                            id: id,
                            title: title,
                            description: descriptionText,
                            timestamp: date,
                            location: location,
                            uiImage: uiImage
                        )

                        var updated = event
                        updated.title = title
                        updated.location = location
                        updated.description = descriptionText
                        updated.timestamp = date
                        onSave(updated)
                        dismiss()
                    }
                } label: {
                    // Style like RSVP in EventDetailsView
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()   // no default Back + Cancel duplication
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
    }

    private func loadImage() async {
        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
            self.uiImage = UIImage(data: data)
        }
    }
}

