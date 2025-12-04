import SwiftUI

struct HomeView: View {
    @StateObject private var store = PlantStore()
    @EnvironmentObject private var greenhouse: GreenhouseStore
    @State private var showBanner: Bool = true
    @State private var bannerMessage: String = "Hello Plant Parent!"
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsError: Bool = false

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
                                PlantCarouselCard(plant: plant, onAdd: { _ in
                                    addToGreenhouse(from: plant)
                                })
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
        // Prefer the remote image URL from the API, fall back to a local asset name
        let imageURL = source.default_image?.regular_url
        let imageName = "monstera"
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
