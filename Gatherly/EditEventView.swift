import SwiftUI
import PhotosUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    var event: Event
    var onSave: (Event) -> Void

    @State private var title: String
    @State private var location: String
    @State private var descriptionText: String
    @State private var date: Date
    @State private var pickedItem: PhotosPickerItem?
    @State private var imageData: Data?

    init(event: Event, onSave: @escaping (Event) -> Void) {
        self.event = event
        self.onSave = onSave
        _title = State(initialValue: event.title)
        _location = State(initialValue: event.location)
        _descriptionText = State(initialValue: event.description)
        _date = State(initialValue: event.parsedDate ?? Date())
    }

    var body: some View {
        Form {
            Section {
                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Label("Change Cover Photo", systemImage: "photo.on.rectangle.angled")
                }
                if let data = imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable().scaledToFill()
                        .frame(height: 160).clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Section("Details") {
                TextField("Title", text: $title)
                TextField("Location", text: $location)
                DatePicker("Date and Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Description") {
                TextEditor(text: $descriptionText)
                    .frame(minHeight: 120)
            }

            Section {
                Button("Save") {
                    var updated = event
                    updated.title = title
                    updated.location = location
                    updated.description = descriptionText
                    updated.timestamp = ISO8601DateFormatter().string(from: date)
                    // TODO: upload imageData and set updated.image_url
                    onSave(updated)
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
        .onChange(of: pickedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}
