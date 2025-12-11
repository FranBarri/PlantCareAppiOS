// PlantAPI.swift
import Foundation
import Combine

// MARK: - List API models
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
        return sunlight.map { $0.capitalized }.joined(separator: ", ")
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

// MARK: - Detail API model
struct PerenualPlantDetail: Codable, Identifiable {
    let id: Int
    let common_name: String
    let scientific_name: [String]
    let other_name: [String]?
    let family: String?
    let origin: [String]?
    let type: String?
    let cycle: String?
    let watering: String?
    let sunlight: [String]?
    let indoor: Bool?
    let poisonous_to_pets: Int?
    
    let default_image: PerenualPlant.DefaultImage?
    
    let watering_general_benchmark: WateringBenchmark?
    let dimensions: Dimensions?

    
    struct WateringBenchmark: Codable {
        let value: String?
        let unit: String?
    }

    struct Dimensions: Codable {
        let type: String?
        let min_value: Double?
        let max_value: Double?
        let unit: String?
    }
    
    var displayName: String { common_name.capitalized }
    var sunLightText: String {
        guard let sunlight = sunlight, !sunlight.isEmpty else { return "Any light" }
        return sunlight.map { $0.capitalized }.joined(separator: ", ")
    }
    
    var wateringFrequencyText: String {
        if let bench = watering_general_benchmark,
           let v = bench.value, !v.isEmpty,
           let unit = bench.unit, !unit.isEmpty {
            return "Every \(v) \(unit)"
        }
        return (watering?.capitalized) ?? "Watering"
    }
}

// MARK: - Store
@MainActor
class PlantStore: ObservableObject {
    @Published var plants: [PerenualPlant] = []
    @Published var isLoading = true
    
    @Published var selectedPlant: PerenualPlant?
    @Published var selectedPlantDetail: PerenualPlantDetail?

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
            // print(String(data: data, encoding: .utf8) ?? "Could not decode JSON as string")
            let response = try JSONDecoder().decode(PerenualResponse.self, from: data)
            // let filtered = response.data.filter { $0.sunlight != nil && !$0.sunlight!.isEmpty }
            let selected = response.data.shuffled().prefix(8)
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
            // print("API Error: \(error)")
            // Fallback so canvas never breaks
            plants = [
                PerenualPlant(id: 425, common_name: "Swiss Cheese Plant", scientific_name: ["Monstera"], watering: "Average", sunlight: ["bright indirect"], indoor: true, poisonous_to_pets: true, default_image: PerenualPlant.DefaultImage(regular_url: "https://perenual.com/storage/species_image/425_monstera_deliciosa/og/monstera.jpg", thumbnail: nil)),
                PerenualPlant(id: 426, common_name: "Snake Plant", scientific_name: ["Sansevieria"], watering: "Minimum", sunlight: ["low light"], indoor: true, poisonous_to_pets: false, default_image: PerenualPlant.DefaultImage(regular_url: "https://perenual.com/storage/species_image/426_sansevieria_trifasciata/og/snakeplant.jpg", thumbnail: nil))
            ]
        }
    }
    
    func fetchPlant(id: Int) async {
        isLoading = true
        selectedPlant = nil
        defer { isLoading = false }
        
        let urlString = "https://perenual.com/api/species/details/\(id)?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let plant = try JSONDecoder().decode(PerenualPlant.self, from: data)
            selectedPlant = plant
        } catch {
            print("Detail API Error(id=\(id)): \(error)")
            // Fallback
            if id == 425 || id == 426 {
                selectedPlant = PerenualPlant(
                    id: id,
                    common_name: id == 425 ? "Swiss Cheese Plant" : "Snake Plant",
                    scientific_name: id == 425 ? ["Monstera"] : ["Sansevieria"],
                    watering: id == 425 ? "Average" : "Minimum",
                    sunlight: id == 425 ? ["bright indirect"] : ["low light"],
                    indoor: true,
                    poisonous_to_pets: id == 425 ? 1 : 0,
                    default_image: PerenualPlant.DefaultImage(
                        regular_url: id == 425
                        ? "https://perenual.com/storage/species_image/425_monstera_deliciosa/og/monstera.jpg"
                        : "https://perenual.com/storage/species_image/426_sansevieria_trifasciata/og/snakeplant.jpg",
                        thumbnail: nil
                    )
                )
            } else {
                selectedPlant = nil
            }
        }
    }
    

    func fetchPlantDetail(id: Int) async {
        isLoading = true
        selectedPlantDetail = nil
        defer { isLoading = false }
        
        let urlString = "https://perenual.com/api/species/details/\(id)?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let detail = try JSONDecoder().decode(PerenualPlantDetail.self, from: data)
            selectedPlantDetail = detail
        } catch {
            print("Detail API Error(id=\(id)): \(error)")
            // Fallback: 425/426
            if id == 425 || id == 426 {
                selectedPlantDetail = PerenualPlantDetail(
                    id: id,
                    common_name: id == 425 ? "Swiss Cheese Plant" : "Snake Plant",
                    scientific_name: id == 425 ? ["Monstera"] : ["Sansevieria"],
                    other_name: nil,
                    family: nil,
                    origin: nil,
                    type: nil,
                    cycle: "Perennial",
                    watering: id == 425 ? "Average" : "Minimum",
                    sunlight: id == 425 ? ["Bright Indirect"] : ["Low Light"],
                    indoor: true,
                    poisonous_to_pets: id == 425 ? 1 : 0,
                    default_image: PerenualPlant.DefaultImage(
                        regular_url: id == 425
                        ? "https://perenual.com/storage/species_image/425_monstera_deliciosa/og/monstera.jpg"
                        : "https://perenual.com/storage/species_image/426_sansevieria_trifasciata/og/snakeplant.jpg",
                        thumbnail: nil
                    ),
                    watering_general_benchmark: .init(value: "5-7", unit: "days"),
                    dimensions: .init(type: nil, min_value: 1, max_value: 1.5, unit: "ft")
                )
            } else {
                selectedPlantDetail = nil
            }
        }
    }
}

