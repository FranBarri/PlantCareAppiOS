//
//  ContentView.swift
//  PlantParentiOS
//
//  Created by stud on 23/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var greenhouse = GreenhouseStore()
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house") }

            MyGreenhouseView()
                .tabItem { Label("Greenhouse", systemImage: "leaf") }

            PlantLibraryView()
                .tabItem { Label("Library", systemImage: "book") }

            //PlantDetailPlaceholder()
            //    .tabItem { Label("Detail", systemImage: "info.circle") }

            NotificationsView()
                .tabItem { Label("Notifications", systemImage: "bell") }
        }
        .environmentObject(greenhouse)
        .accentColor(.green)
    }
}
