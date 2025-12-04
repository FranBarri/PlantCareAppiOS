// PlantAPI.swift
import Foundation
import Combine

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
    let poisonous_to_pets: Bool?
    let default_image: DefaultImage?
    
    var displayName: String {
        common_name.capitalized
    }
    
    var sunLightText: String {
        guard let sunlight = sunlight, !sunlight.isEmpty else { return "Any light" }
        return sunlight.map {$0.capitalized }.joined(separator: ", ")
    }

    struct DefaultImage: Codable {
        let regular_url: String?
        let thumbnail: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, common_name, scientific_name, watering, sunlight, indoor, poisonous_to_pets, default_image
    }
    
    init(id: Int, common_name: String, scientific_name: [String], watering: String?, sunlight: [String]?, indoor: Bool?, poisonous_to_pets: Bool?, default_image: DefaultImage?) {
        self.id = id
        self.common_name = common_name
        self.scientific_name = scientific_name
        self.watering = watering
        self.sunlight = sunlight
        self.indoor = indoor
        self.poisonous_to_pets = poisonous_to_pets
        self.default_image = default_image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        common_name = try container.decode(String.self, forKey: .common_name)
        scientific_name = try container.decode([String].self, forKey: .scientific_name)
        watering = try container.decodeIfPresent(String.self, forKey: .watering)
        sunlight = try container.decodeIfPresent([String].self, forKey: .sunlight)
        indoor = try container.decodeIfPresent(Bool.self, forKey: .indoor)
        default_image = try container.decodeIfPresent(DefaultImage.self, forKey: .default_image)
        // Flexible decoding for poisonous_to_pets
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: .poisonous_to_pets) {
            poisonous_to_pets = intValue == 1 ? true : (intValue == 0 ? false : nil)
        } else if let boolValue = try? container.decodeIfPresent(Bool.self, forKey: .poisonous_to_pets) {
            poisonous_to_pets = boolValue
        } else {
            poisonous_to_pets = nil
        }
    }
}

@MainActor
class PlantStore: ObservableObject {
    @Published var plants: [PerenualPlant] = []
    @Published var isLoading = true
    @Published var errorMessage: String? = nil

    private let apiKey = "sk-M6ci690caf9f1d9a813339"

    init() {
        Task { await fetchPlants() }
    }

    func fetchPlants() async {
        isLoading = true
        defer { isLoading = false }

        let urlString = "https://perenual.com/api/species-list?key=\(apiKey)&indoor=1"
        
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                // Provide more actionable debug info
                let body = String(data: data, encoding: .utf8) ?? "(no body)"
                print("Plant list API returned HTTP \(http.statusCode): \(body)")
                throw URLError(.badServerResponse)
            }

            // Debug: print raw JSON when decoding fails
            // print(String(data: data, encoding: .utf8) ?? "Could not decode JSON as string")
            let responseObj = try JSONDecoder().decode(PerenualResponse.self, from: data)
            let selected = responseObj.data.shuffled().prefix(8)
            var detailedPlants: [PerenualPlant] = []
            await withTaskGroup(of: PerenualPlant?.self) { group in
                for plant in selected {
                    group.addTask { await self.fetchPlantDetails(for: plant.id) }
                }
                for await detailed in group {
                    if let plant = detailed { detailedPlants.append(plant) }
                }
            }
            plants = detailedPlants
        } catch {
            // Log the error so you can inspect why the API failed
            print("Plant list fetch error:", error)
            errorMessage = String(describing: error)
            // Fallback so canvas never breaks
            plants = [
                PerenualPlant(id: 425, common_name: "Swiss Cheese Plant", scientific_name: ["Monstera"], watering: "Average", sunlight: ["bright indirect"], indoor: true, poisonous_to_pets: true, default_image: PerenualPlant.DefaultImage(regular_url: "https://perenual.com/storage/species_image/425_monstera_deliciosa/og/monstera.jpg", thumbnail: nil)),
                PerenualPlant(id: 426, common_name: "Snake Plant", scientific_name: ["Sansevieria"], watering: "Minimum", sunlight: ["low light"], indoor: true, poisonous_to_pets: false, default_image: PerenualPlant.DefaultImage(regular_url: "https://perenual.com/storage/species_image/426_sansevieria_trifasciata/og/snakeplant.jpg", thumbnail: nil))
            ]
        }
    }

    func fetchPlantDetails(for id: Int) async -> PerenualPlant? {
        let urlString = "https://perenual.com/api/v2/species/details/\(id)?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? "(no body)"
                print("Plant detail API returned HTTP \(http.statusCode) for id \(id): \(body)")
                return nil
            }
            let plant = try JSONDecoder().decode(PerenualPlant.self, from: data)
            return plant
        } catch {
            print("Detail API Error for id \(id):", error)
            return nil
        }
    }
}

