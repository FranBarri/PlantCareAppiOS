import SwiftUI

struct HomeView: View {
    @StateObject private var store = PlantStore()
    @EnvironmentObject private var greenhouse: GreenhouseStore
    @State private var showBanner: Bool = true
    @State private var bannerMessage: String = "Hello Plant Parent!"
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsError: Bool = false
    // Carousel paging and displayed plant window
    @State private var pageSelection: Int = 0
    @State private var allUniquePlants: [PerenualPlant] = []
    @State private var displayedPlants: [PerenualPlant] = []

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
                        // Render the current displayed window (managed by refreshUniquePlants)
                        TabView(selection: $pageSelection) {
                            ForEach(Array(displayedPlants.enumerated()), id: \.1.id) { index, plant in
                                PlantCarouselCard(plant: plant, onAdd: { _ in
                                    addToGreenhouse(from: plant)
                                })
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 300)
                        .onAppear {
                            refreshUniquePlants()
                        }
                        .onChange(of: store.plants) { _ in
                            refreshUniquePlants()
                        }
                    }

                    // When the user reaches the last page, attempt to load/rotate in a new plant
                    .onChange(of: pageSelection) { newIndex in
                        // Only trigger when user lands on the last displayed index
                        guard newIndex == (displayedPlants.count - 1) else { return }

                        // Find the next plant from allUniquePlants that's not currently displayed
                        if let next = allUniquePlants.first(where: { a in !displayedPlants.contains(where: { $0.id == a.id }) }) {
                            // If there's room, append; otherwise rotate window (drop first, append)
                            if displayedPlants.count < 8 {
                                displayedPlants.append(next)
                                // Move selection to the new last item
                                pageSelection = displayedPlants.count - 1
                            } else {
                                // Rotate window to show new plant at the end
                                displayedPlants.removeFirst()
                                displayedPlants.append(next)
                                // Keep selection at last index to show newly appended plant
                                pageSelection = displayedPlants.count - 1
                            }
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
            .task {
                // Removed: await store.fetchPlants()
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
    
    private func addToGreenhouse(from source: PerenualPlant) {
        // Build a user-friendly display name: trim whitespace, fall back to scientific name, and capitalize words
        let commonRaw = source.common_name.trimmingCharacters(in: .whitespacesAndNewlines)
        let scientificRaw = source.scientific_name.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let baseName = commonRaw.isEmpty ? (scientificRaw.isEmpty ? "Unknown" : scientificRaw) : commonRaw
        let name = baseName.localizedCapitalized

        // Duplicate check should be case-insensitive
        let exists = greenhouse.plants.contains { $0.name.lowercased() == name.lowercased() }
        if exists {
            toastMessage = "\(name) is already in your greenhouse"
            toastIsError = true
            withAnimation(.spring()) { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut) { showToast = false }
            }
            return
        }
        // Prefer the remote image URL from the API; do not force a local fallback for every plant
        let imageURL = source.default_image?.regular_url
        // Do not set a local asset by default — prefer the API image. If you have a specific
        // local asset that matches the plant species, we could detect and set it here.
        let imageName: String? = nil
        let lastWatered = "Today"
        let status = "All good"
        let statusColor: Color = .green
        let plant = Plant(id: UUID(), name: name, imageName: imageName, imageURL: imageURL, lastWatered: lastWatered, status: status, statusColor: statusColor)
        greenhouse.add(plant)
        toastMessage = "Added \(name) to your greenhouse"
        toastIsError = false
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut) { showToast = false }
        }
    }

    private func refreshUniquePlants() {
        let uniquePlants = store.plants.uniqued(by: { (p: PerenualPlant) -> String in
            let name = p.common_name.trimmingCharacters(in: .whitespacesAndNewlines)
            let fallback = p.scientific_name.first ?? ""
            return (name.isEmpty ? fallback : name).lowercased()
        })

        // Update state only when changed
        if uniquePlants.map({ $0.id }) != allUniquePlants.map({ $0.id }) {
            allUniquePlants = uniquePlants
            // Preserve existing displayed window if possible, otherwise take first 8
            if displayedPlants.isEmpty {
                displayedPlants = Array(allUniquePlants.prefix(8))
                pageSelection = 0
            } else {
                // remove any displayed plants that no longer exist
                displayedPlants.removeAll { dp in !allUniquePlants.contains(where: { $0.id == dp.id }) }
                // fill up to 8
                for p in allUniquePlants where displayedPlants.count < 8 && !displayedPlants.contains(where: { $0.id == p.id }) {
                    displayedPlants.append(p)
                }
                pageSelection = min(pageSelection, max(0, displayedPlants.count - 1))
            }
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
