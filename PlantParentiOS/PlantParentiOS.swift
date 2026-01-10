//
//  PlantParentiOSApp.swift
//  PlantParentiOS
//
//  Created by stud on 23/10/2025.
//

import SwiftUI

@main
struct PlantParentiOSApp: App {
    @StateObject private var greenhouse = GreenhouseStore()
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }

                MyGreenhouseView()
                    .tabItem { Label("Greenhouse", systemImage: "leaf") }

                PlantLibraryView()
                    .tabItem { Label("Library", systemImage: "book") }

                NotificationsView()
                    .tabItem { Label("Notifications", systemImage: "bell") }
            }
            .environmentObject(greenhouse)
            .accentColor(.green)
        }
    }
}
