import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Bindable var vm: ProfileViewModel
    @Bindable var eventsVM: EventsViewModel

    @State private var pickedItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Avatar
                    if let data = imageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable().scaledToFill()
                            .frame(width: 120, height: 120).clipShape(Circle())
                    } else {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .overlay(Image(systemName: "person.fill").font(.largeTitle))
                            .frame(width: 120, height: 120)
                    }

                    PhotosPicker(selection: $pickedItem, matching: .images) {
                        Text("Upload Profile Photo")
                    }

                    Text("Francesca Fabiano-Grossi")
                        .font(.title2).bold()

                    // Tabs
                    HStack(spacing: 0) {
                        ForEach(vm.tabs, id: \.self) { tab in
                            Button {
                                vm.selectTab(tab)
                            } label: {
                                VStack(spacing: 6) {
                                    Text(tab).padding(.horizontal, 8)
                                    Rectangle()
                                        .fill(vm.selectedTab == tab ? .blue : .clear)
                                        .frame(height: 2)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)

                    // Content under tabs (placeholder)
                    VStack(alignment: .leading, spacing: 8) {
                        switch vm.selectedTab {
                        case "My Events":
                            Text("Your created events (\(eventsVM.events.count))").font(.headline)
                        case "RSVP'd":
                            Text("RSVP’d Events (coming soon)").font(.headline)
                        case "Past Events":
                            let past = eventsVM.events.filter { $0.timestamp < Date() }
                            Text("Past events (\(past.count))").font(.headline)
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .padding(.top, 24)
            }
            .navigationTitle("Profile")
        }
        .onChange(of: pickedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}
