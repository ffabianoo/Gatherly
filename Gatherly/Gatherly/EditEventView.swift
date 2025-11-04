import SwiftUI
import PhotosUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    let event: Event
    @Bindable var vm: EventsViewModel

    var body: some View {
        Form {
            Section("Cover Photo") {
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

                    vm.image?
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75)
                }
            }

            Section("Details") {
                TextField("Title", text: $vm.title)
                TextField("Location", text: $vm.location)
                DatePicker("Date and Time", selection: $vm.date, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Description") {
                TextEditor(text: $vm.descriptionText)
            }

            Section {
                Button("Save") {
                    Task {
                        if let id = event.id {
                            await vm.saveEdit(for: id)
                            if case .success = vm.saveState { dismiss() }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
        }
        .onAppear { vm.resetForm(with: event) }
    }
}
