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

    // Error message for UI
    @Published var errorMessage: String? = nil

    private let apiKey = "sk-M6ci690caf9f1d9a813339"
    private let cacheFileName = "perenual_cached_plants.json"

    init() {
        Task { await fetchPlants() }
    }

    // Save plants to cache
    private func saveCachedPlants(_ plants: [PerenualPlant]) {
        do {
            let data = try JSONEncoder().encode(plants)
            let url = cacheFileURL()
            try data.write(to: url, options: [.atomic])
        } catch {
            print("Failed to save cached plants: \(error)")
        }
    }

    // Load plants from cache
    private func loadCachedPlants() -> [PerenualPlant]? {
        do {
            let url = cacheFileURL()
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([PerenualPlant].self, from: data)
            return decoded
        } catch {
            print("Failed to load cached plants: \(error)")
            return nil
        }
    }

    // Helper to get cache file URL
    private func cacheFileURL() -> URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(cacheFileName)
    }
    
    func fetchPlants() async {
        isLoading = true
        defer { isLoading = false }
        let urlString = "https://perenual.com/api/species-list?page=1&key=\(apiKey)&indoor=1"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                // Handle rate limiting specially
                if http.statusCode == 429 {
                    // Try to extract Retry-After from header or body
                    var retrySeconds: Int? = nil
                    if let retryHeader = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Retry-After"), let n = Int(retryHeader) {
                        retrySeconds = n
                    } else if let bodyObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let r = bodyObj["Retry-After"] as? Int {
                        retrySeconds = r
                    }

                    let waitText = retrySeconds.map { "Please wait \($0) seconds before retrying." } ?? "Please try again later."
                    print("Plant list API returned HTTP 429: \(String(data: data, encoding: .utf8) ?? "(no body)"))")
                    errorMessage = "Rate limit exceeded. \(waitText)"

                    // Try to load cached plants; if available, use them so UI remains useful
                    if let cached = loadCachedPlants() {
                        plants = cached
                    }
                    return
                }

                // For other non-2xx responses provide debug info
                let body = String(data: data, encoding: .utf8) ?? "(no body)"
                print("Plant list API returned HTTP \(http.statusCode): \(body)")
                throw URLError(.badServerResponse)
            }

            // Decode response and pick up to 8 random plants with unique display names
            let responseObj = try JSONDecoder().decode(PerenualResponse.self, from: data)

            // Shuffle the full list, then pick plants while avoiding duplicate display names
            let shuffled = responseObj.data.shuffled()
            var picked: [PerenualPlant] = []
            var seenNames = Set<String>()

            func keyFor(_ p: PerenualPlant) -> String {
                let name = p.common_name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty { return name.lowercased() }
                return (p.scientific_name.first ?? "").lowercased()
            }

            for plant in shuffled {
                let key = keyFor(plant)
                if !key.isEmpty && !seenNames.contains(key) {
                    picked.append(plant)
                    seenNames.insert(key)
                }
                if picked.count == 8 { break }
            }

            // If we couldn't find 8 unique names, fill the remainder with any items (avoid empty list)
            if picked.count < 8 {
                for plant in shuffled where !picked.contains(where: { $0.id == plant.id }) {
                    picked.append(plant)
                    if picked.count == 8 { break }
                }
            }

            // NOTE: Detailed per-plant requests are disabled to avoid exceeding daily API limits.
            // Previously we fetched details for each picked plant in parallel using `fetchPlantDetails(for:)`.
            // That resulted in up to 8 additional API calls per refresh. To respect the API quota,
            // we now use the list response directly (the `picked` array) and do not call the detail endpoint.
            plants = picked
            // Save successful result to disk to survive rate limits / offline
            saveCachedPlants(plants)
            errorMessage = nil
        } catch {
            // Log the error so you can inspect why the API failed
            print("Plant list fetch error:", error)
            errorMessage = String(describing: error)
            // Try to load cached plants as a fallback before using the sample data
            if let cached = loadCachedPlants() {
                plants = cached
                return
            }

            // Fallback sample so canvas never breaks
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
                    poisonous_to_pets: ((id == 425 ? 1 : 0) != 0),
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

    // func fetchPlantDetails(for id: Int) async -> PerenualPlant? {
    //     let urlString = "https://perenual.com/api/v2/species/details/\(id)?key=\(apiKey)"
    //     guard let url = URL(string: urlString) else { return nil }
    //     do {
    //         let (data, response) = try await URLSession.shared.data(from: url)
    //         if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
    //             let body = String(data: data, encoding: .utf8) ?? "(no body)"
    //             print("Plant detail API returned HTTP \(http.statusCode) for id \(id): \(body)")
    //             return nil
    //         }
    //         let plant = try JSONDecoder().decode(PerenualPlant.self, from: data)
    //         return plant
    //     } catch {
    //         print("Detail API Error for id \(id):", error)
    //         return nil
    //     }
    // }
}

