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
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            /* MyGreenhouseView()
                .tabItem {
                    Label("My Greenhouse", systemImage: "leaf")
                }
            
            PlantLibraryView()
                .tabItem {
                    Label("Plant Library", systemImage: "book")
                }
            
            PlantDetailView()
                .tabItem {
                    Label("Plant Detail", systemImage: "info.circle")
                }
            
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }*/
        }
        .accentColor(.green)
    }
}
