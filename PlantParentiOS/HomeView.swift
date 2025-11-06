import SwiftUI

struct HomeView: View {
    @StateObject private var store = PlantStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Hello Plant Parent!")
                            .font(.title2).bold()
                        Spacer()
                        Image(systemName: "bell.badge")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                    .padding(.horizontal)

                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: .constant(""))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Watering Reminder
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "drop.fill").foregroundColor(.white)
                            Text("Next Watering Reminder").font(.headline).foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.white)
                        }
                        Text("Fiddle Leaf Fig").foregroundColor(.white.opacity(0.9))
                        Text("Tomorrow, 9:00 AM").foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Carousel
                    if store.isLoading {
                        ProgressView().frame(height: 260)
                    } else {
                        TabView {
                            ForEach(store.plants.prefix(8)) { plant in
                                PlantCarouselCard(plant: plant)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 260)
                    }

                    // Quick Tips
                    Text("Quick Tips")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    TipCard(icon: "drop.fill", title: "Watering", tip: "Water when the top inch of soil is dry.")
                    TipCard(icon: "sun.max.fill", title: "Sunlight", tip: "Rotate your plants weekly.")
                }
                .padding(.vertical)
            }
            .navigationTitle("Hello Plant Parent!")
            .task { 
                await store.fetchPlants() 
            }
        }
    }
}

// Keep your PlantCarouselCard, TipCard, etc. exactly as you have them
// Just add this at the bottom:
#Preview {
    MainTabView()   // This makes Canvas show the full app with tabs
}