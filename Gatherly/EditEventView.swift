import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    var event: Event

    @State private var title: String = ""
    @State private var location: String = ""
    @State private var descriptionText: String = ""
    @State private var date: Date = Date()

    var body: some View {
        Form {
            Section {
                Button {
        
                } label: {
                    Label("Add Image", systemImage: "plus.circle")
                }
            }

            Section("Details") {
                TextField("Title", text: $title)
                TextField("Location", text: $location)
                DatePicker(
                    "Date and Time",
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            Section("Description") {
                TextEditor(text: $descriptionText)
                    .frame(minHeight: 120)
            }

            Section {
                Button("Save") {
                   
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            title = event.title
            location = event.location
            descriptionText = event.description
            date = event.parsedDate ?? Date()
        }
    }
}

#Preview {
    NavigationStack {
        EditEventView(event: Event.example)
    }
}
