import SwiftUI

struct HomeView: View {
    @StateObject private var store = PlantStore()
    @EnvironmentObject private var greenhouse: GreenhouseStore
    @State private var showBanner: Bool = true
    @State private var bannerMessage: String = "Hello Plant Parent!"
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsError: Bool = false
    // Displayed plants for the carousel (8 random, deduplicated)
    @State private var displayedPlants: [PerenualPlant] = []

    // Helper to find the next watering plant info
    private var nextWateringPlantInfo: (plant: GreenhousePlant, nextWatering: Date)? {
        // Filter plants that have lastWatered or wateringIntervalDays
        let now = Date()
        
        // Calculate next watering date for each plant
        // If lastWatered or wateringIntervalDays missing, assume default interval 7 days with lastWatered = dateAdded or now
        let candidates: [(GreenhousePlant, Date)] = greenhouse.plants.compactMap { plant in
            let intervalDays = plant.wateringIntervalDays ?? 7
            
            // Prefer lastWatered, fallback to dateAdded, fallback to now
            let lastWatered = plant.lastWatered ?? plant.dateAdded ?? now
            
            let nextWatering = Calendar.current.date(byAdding: .day, value: intervalDays, to: lastWatered)!
            
            // Only future or today watering dates
            if nextWatering >= now {
                return (plant, nextWatering)
            } else {
                return nil
            }
        }
        
        // Find the one with soonest next watering date
        return candidates.min(by: { $0.1 < $1.1 })
    }

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
                            if let info = nextWateringPlantInfo {
                                Text(info.plant.displayName)
                                    .font(.headline)
                                Text(info.nextWatering, style: .date) // Show date only
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("No plants needing watering soon")
                                    .font(.headline)
                                Text("Add plants to your greenhouse")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
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
                        // Render the current selected random plants
                        TabView {
                            ForEach(displayedPlants) { plant in
                                PlantCarouselCard(plant: plant, onAdd: { _ in
                                    addToGreenhouse(from: plant)
                                })
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 300)
                        .onAppear {
                            refreshUniquePlants()
                        }
                        .onChange(of: store.plants.map { $0.id }) { _, _ in
                            refreshUniquePlants()
                        }
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
            .overlay(alignment: .bottom) {
                if showToast {
                    HStack(spacing: 8) {
                        Image(systemName: toastIsError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(toastMessage)
                            .foregroundColor(.white)
                            .font(.subheadline).bold()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(toastIsError ? Color.red : Color.green)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: store.errorMessage) { _, new in
                if let msg = new {
                    toastMessage = msg
                    toastIsError = true
                    withAnimation(.spring()) { showToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut) { showToast = false }
                    }
                }
            }
            .task {
                // Only fetch if we don't already have plants loaded
                if store.plants.isEmpty {
                    await store.fetchPlants()
                }
                // Auto-dismiss banner after 3 seconds (keep this part as is)
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                        showBanner = false
                    }
                }
            }
        }
    }
    
    private func addToGreenhouse(from source: PerenualPlant) {
        let displayName = source.displayName

        // Duplicate check should be case-insensitive on displayName
        let exists = greenhouse.plants.contains { $0.displayName.lowercased() == displayName.lowercased() }
        if exists {
            toastMessage = "\(displayName) is already in your greenhouse"
            toastIsError = true
            withAnimation(.spring()) { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut) { showToast = false }
            }
            return
        }
        // Create and add a GreenhousePlant
        let plant = GreenhousePlant(
            plantID: source.id,
            displayName: displayName,
            imageURL: source.default_image?.regular_url,
            imageName: nil,
            nickname: nil,
            dateAdded: Date(),
            notes: nil,
            quantity: 1
        )
        greenhouse.add(plant)
        toastMessage = "Added \(displayName) to your greenhouse"
        toastIsError = false
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut) { showToast = false }
        }
    }

    private func refreshUniquePlants() {
        // Build unique list by display name and pick 8 random plants from it
        let uniquePlants = store.plants.uniqued(by: { (p: PerenualPlant) -> String in
            let name = p.common_name.trimmingCharacters(in: .whitespacesAndNewlines)
            let fallback = p.scientific_name.first ?? ""
            return (name.isEmpty ? fallback : name).lowercased()
        })

        // Shuffle and choose up to 8 unique plants
        let picked = Array(uniquePlants.shuffled().prefix(8))

        // Update displayedPlants only when changed
        if picked.map({ $0.id }) != displayedPlants.map({ $0.id }) {
            displayedPlants = picked
        }
    }
}

// Small helper to deduplicate arrays by a selector key
extension Array {
    func uniqued<T: Hashable>(by keySelector: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        var result: [Element] = []
        for item in self {
            let key = keySelector(item)
            if !seen.contains(key) {
                seen.insert(key)
                result.append(item)
            }
        }
        return result
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
    HomeView()
        .environmentObject(store)
        .environmentObject(GreenhouseStore())
}
