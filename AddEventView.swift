// AddEventView.swift
import SwiftUI
import PhotosUI
import Observation

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: AddEventViewModel
    var onCreate: (Event) -> Void

    var body: some View {
        SwiftUI.Form {
            Section {
                HStack {
                    PhotosPicker(selection: $vm.selectedPhoto, matching: .images) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .padding(20)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .task(id: vm.selectedPhoto) { await vm.loadImage() }

                    if let image = vm.image {
                        image.resizable().scaledToFit().frame(height: 75)
                    }
                }
            }

            Section("Details") {
                TextField("Title", text: $vm.title)
                TextField("Location", text: $vm.location)
                DatePicker("Date and Time",
                           selection: $vm.date,
                           displayedComponents: [.date, .hourAndMinute])
            }

            Section("Description") {
                TextEditor(text: $vm.descriptionText)
            }

            Section {
                Button {
                    Task {
                        if let created = await vm.create() {
                            onCreate(created)
                            dismiss()
                        }
                    }
                } label: {
                    Text("Create Event").frame(maxWidth: .infinity)
                }
                .disabled(!vm.isValid)
            }
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
    }
}
