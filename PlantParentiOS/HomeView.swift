import SwiftUI

struct HomeView: View {
    @StateObject private var store = PlantStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: .constant(""))
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Watering Reminder
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.green)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("Next Watering Reminder")
                                .font(.subheadline).bold()
                            Text("Fiddle Leaf Fig")
                                .font(.headline)
                            Text("Tomorrow, 9:00 AM")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Carousel (exactly like screenshot)
                    if store.isLoading {
                        ProgressView().frame(height: 300)
                    } else {
                        TabView {
                            ForEach(store.plants.prefix(8)) { plant in
                                PlantCarouselCard(plant: plant)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 300)
                    }

                    // Quick Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Tips")
                            .font(.title3).bold()

                        TipRow(icon: "drop.fill", title: "Watering", text: "Water when the top inch of soil is dry.\nAvoid Overwatering.")
                        TipRow(icon: "sun.max.fill", title: "Sunlight", text: "Rotate your plants weekly for even growth towards the light.")
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Hello Plant Parent!")
            .navigationBarTitleDisplayMode(.inline)
            .task { await store.fetchPlants() }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let text: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}