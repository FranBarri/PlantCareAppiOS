import SwiftUI

struct HomeView: View {
    @StateObject private var store = PlantStore()
    @State private var showBanner: Bool = true
    @State private var bannerMessage: String = "Hello Plant Parent!"

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
            .overlay(alignment: .top) {
                if showBanner {
                    BannerView(message: bannerMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await store.fetchPlants()
                // Auto-dismiss banner after 3 seconds
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                        showBanner = false
                    }
                }
            }
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
                .frame(width: 30, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BannerView: View {
    let message: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .foregroundColor(.white)
            Text(message)
                .font(.subheadline).bold()
                .foregroundColor(.white)
            Spacer(minLength: 0)
            Button {
                withAnimation(.easeInOut) { }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.9))
            }
            .buttonStyle(.plain)
            .disabled(true) // non-interactive placeholder; can be wired to dismiss if desired
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.green)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

#Preview("Sample Data") {
    let store = PlantStore()
    store.isLoading = false
    store.plants = [
        PerenualPlant(id: 425, common_name: "Swiss Cheese Plant", scientific_name: ["Monstera"], watering: "Average", sunlight: ["bright indirect"], indoor: true, poisonous_to_pets: 1, default_image: PerenualPlant.DefaultImage(regular_url: "https://perenual.com/storage/species_image/425_monstera_deliciosa/og/monstera.jpg", thumbnail: nil)),
        PerenualPlant(id: 426, common_name: "Snake Plant", scientific_name: ["Sansevieria"], watering: "Minimum", sunlight: ["low light"], indoor: true, poisonous_to_pets: 0, default_image: PerenualPlant.DefaultImage(regular_url: "https://perenual.com/storage/species_image/426_sansevieria_trifasciata/og/snakeplant.jpg", thumbnail: nil))
    ]
    return HomeView()
        .environmentObject(store)
}
