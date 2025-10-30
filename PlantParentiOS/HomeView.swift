//
//  HomeView.swift
//  PlantParentiOS
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
    private let carouselPlants: [CarouselPlant] = [
        .init(imageName: "Monstera", name: "Monstera Deliciosa", light: "Thrives in bright, indirect  light"),
        .init(imageName: "SnakePlant", name: "Snake Plant", light: "Bright, filtered light")
    ]
    
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
                    
                    // Plant Carousel
                    TabView(selection: .constant(0)) {
                        ForEach(carouselPlants) { plant in
                            PlantCarouselCard(plant: plant)
                                .tag(plant.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 220)
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct PlantCarouselCard: View {
    let plant: CarouselPlant
    
    var body: some View {
        VStack(spacing: 12) {
            Image(plant.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 90)
                .clipped()
                .cornerRadius(8)
            
            Text(plant.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(plant.light)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 12) {
                Button {
                    //add functionality
                } label: {
                    Label("Add to My Garden", systemImage: "plus")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
                
                Button {
                    //add functionality
                } label: {
                    Label("Browse Library", systemImage: "book")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            .frame(height: 36)
        }
        .padding()
        .frame(maxWidth: .infinity)
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
