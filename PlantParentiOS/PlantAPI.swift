// PlantAPI.swift
import Foundation

struct PerenualResponse: Codable {
    let data: [PerenualPlant]
    let to: Int
    let per_page: Int
    let current_page: Int
    let from: Int
    let last_page: Int
    let total: Int
}

struct PerenualPlant: Codable, Identifiable {
    let id: Int
    let common_name: String
    let scientific_name: [String]
    let watering: String?
    let sunlight: [String]?
    let indoor: Bool?
    let poisonous_to_pets: Int?
    let default_image: DefaultImage?

    struct DefaultImage: Codable {
        let regular_url: String?
        let thumbnail: String?
    }
}

@MainActor
class PlantStore: ObservableObject {
    @Published var plants: [PerenualPlant] = []
    @Published var isLoading = true

    private let apiKey = "sk-M6ci690caf9f1d9a813339"

    init() {
        Task { await fetchPlants() }
    }

    func fetchPlants() async {
        isLoading = true
        defer { isLoading = false }

        let urlString = "https://perenual.com/api/species-list?page=1&key=\(apiKey)&indoor=1"
        
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PerenualResponse.self, from: data)
            plants = response.data.shuffled().prefix(8).map { $0 } // random 8 plants
        } catch {
            print("API Error: \(error)")
            // Fallback so canvas never breaks
            plants = [
                PerenualPlant(id: 425, common_name: "Swiss Cheese Plant", scientific_name: ["Monstera"], watering: "Average", sunlight: ["bright indirect"], indoor: true, poisonous_to_pets: 1, default_image: DefaultImage(regular_url: "https://perenual.com/storage/species_image/425_monstera_deliciosa/og/monstera.jpg")),
                PerenualPlant(id: 426, common_name: "Snake Plant", scientific_name: ["Sansevieria"], watering: "Minimum", sunlight: ["low light"], indoor: true, poisonous_to_pets: 0, default_image: DefaultImage(regular_url: "https://perenual.com/storage/species_image/426_sansevieria_trifasciata/og/snakeplant.jpg"))
            ]
        }
    }   x
}