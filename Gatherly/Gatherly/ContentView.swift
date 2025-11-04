import SwiftUI

struct ContentView: View {
    @State private var eventsVM = EventsViewModel()   // single source of truth
    @State private var profileVM = ProfileViewModel()

    var body: some View {
        TabView {
            HomeView(vm: eventsVM)
                .tabItem { Image(systemName: "house") }

            ProfileView(vm: profileVM, eventsVM: eventsVM)
                .tabItem { Image(systemName: "person.fill") }
        }
    }
}
