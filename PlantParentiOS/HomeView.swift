//
//  HomeView.swift
//  PlantParentiOSApp
//
//  Created by stud on 23/10/2025.
//

import SwiftUI

struct CarouselPlant: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
    let light: String
}

struct HomeView: View {
    @StateObject private var store = PlantStore()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Hello Plant Parent!")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "bell.badge")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: .constant(""))
                        .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.white)
                            Text("Next Watering Reminder")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Plant carousel
                    if store.isLoading && store.plants.isEmpty {
                        ProgressView("Loading plants...")
                            .frame(height:260)
                    } else {
                        TabView {
                            ForEach(store.plants.prefix(10)) { plant in
                                PlantCarouselCard(plant: plant)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 260)
                    }
                    task {
                        await store.fetchPlants()
                    }
                    .alert("API Error", isPresented: .constant(store.errorMessage != nil)) {
                        Button("OK") { store.errorMessage = nil }
                    } message: {
                        Text(store.errorMessage ?? "")
                    }
                }
            }
        }
    }
}

struct PlantCarouselCard: View {
    let plant: PerenualPlant
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: plant.default_image?.regular_url ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green.opacity(0.3))
            }
            .frame(height: 100)
            .cornerRadius(10)
            
            Text(plant.common_name)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(plant.sunlight.first ?? "Any light")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button {
                    print("Added \(plant.common_name) to My Garden")
                } label: {
                    Label("Add to My Garden", systemImage: "plus")
                        .font(.caption).frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered).tint(.green)
                
                Button {
                    print("Browsing \(plant.common_name)")
                } label: {
                    Label("Browse Library", systemImage: "book")
                        .font(.caption).frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered).tint(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 3)
        .padding(.horizontal, 8)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
