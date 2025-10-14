import SwiftUI
import PhotosUI
import Observation   // ← required for @Bindable

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: AddEventViewModel     // requires AddEventViewModel to be @Observable
    var onCreate: (Event) -> Void

    @State private var pickedItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        Form {
            // MARK: Cover Photo
            Section {
                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Label("Upload Cover Photo", systemImage: "photo.badge.plus")
                }
                if let data = imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // MARK: Details
            Section("Details") {
                TextField("Title", text: $vm.title)
                TextField("Location", text: $vm.location)
                DatePicker(
                    "Date and Time",
                    selection: $vm.date,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            // MARK: Description
            Section("Description") {
                TextEditor(text: $vm.descriptionText)
                    .frame(minHeight: 120)
            }

            // MARK: Create
            Section {
                Button("Create Event") {
                    let new = vm.buildEvent()
                    // TODO: if you upload imageData, set new.image_url before calling onCreate
                    onCreate(new)
                    dismiss()
                }
                .disabled(!vm.isValid)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
        // Use the single-parameter onChange to avoid overload issues
        .onChange(of: pickedItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}

