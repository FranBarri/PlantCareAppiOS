//
//  ContentView.swift
//  PlantParentiOS
//
//  Created by stud on 23/10/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
//            MyGreenhouseView()
//                .tabItem { Label("Greenhouse", systemImage: "leaf") }
//            PlantLibraryView()
//                .tabItem { Label("Library", systemImage: "book") }
//            PlantDetailPlaceholder()
//                .tabItem { Label("Detail", systemImage: "info.circle") }
//            NotificationsView()
//                .tabItem { Label("bell", systemImage: "bell") }
        }
        .accentColor(.green)
    }
}
