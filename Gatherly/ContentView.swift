//
//  ContentView.swift
//  Gatherly
//
//  Created by Francesca Fabiano-Grossi on 10/13/25.
//

// ContentView.swift
import SwiftUI
import Observation

struct ContentView: View {
    @State private var eventsVM = EventsViewModel()
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
