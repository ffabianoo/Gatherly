struct AddEventView: View {
    @State private var vm = AddEventViewModel()

    var body: some View {
        Form {
            Section("Upload Cover Photo") {
                PhotosPicker(selection: $vm.photo, matching: .images) {
                    if let image = vm.photo {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                    } else {
                        Label("Upload Cover Photo", systemImage: "photo")
                    }
                }
            }
            TextField("Title", text: $vm.title)
            DatePicker("Date", selection: $vm.date, displayedComponents: .date)
            TextField("Description", text: $vm.description)
            Button("Create Event") { vm.createEvent() }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Create Event")
    }
}
