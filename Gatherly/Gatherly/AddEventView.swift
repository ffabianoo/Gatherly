import SwiftUI
import PhotosUI
import Observation

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: EventsViewModel

    private var canSave: Bool {
        !vm.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.isSaving
    }

    var body: some View {
        Form {
            // Cover Photo
            Section("Upload Cover Photo") {
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

            // Details
            Section("Details") {
                TextField("Title", text: $vm.title).submitLabel(.next)
                TextField("Location", text: $vm.location).submitLabel(.next)
                DatePicker("Date and Time", selection: $vm.date, displayedComponents: [.date, .hourAndMinute])
            }

            // Description
            Section("Description") {
                ZStack(alignment: .topLeading) {
                    if vm.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Enter a short description…")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                    TextEditor(text: $vm.descriptionText)
                        .frame(minHeight: 90)
                        .scrollContentBackground(.hidden)
                }
            }

            // Create
            Section {
                Button("Create Event") {
                    Task {
                        await vm.create()
                        if case .success = vm.saveState { dismiss() }
                    }
                }
                .disabled(!canSave)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // Feedback
            switch vm.saveState {
            case .failure(let message):
                Section { Label(message, systemImage: "xmark.octagon.fill").foregroundStyle(.red) }
            case .loading:
                Section { HStack { ProgressView(); Text("Creating…") } }
            default:
                EmptyView()
            }
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
        .onAppear { vm.resetForm(with: nil) }
    }
}
