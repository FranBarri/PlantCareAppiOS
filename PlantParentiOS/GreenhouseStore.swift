import SwiftUI
import Combine

final class GreenhouseStore: ObservableObject {
    @Published var plants: [GreenhousePlant] = []
    private let cacheFileName = "greenhouse_plants.json"

    init() {
        loadFromDisk()
    }

    func add(_ plant: GreenhousePlant) {
        // Prevent duplicates by displayName (case-insensitive) for this session
        guard !plants.contains(where: { $0.displayName.lowercased() == plant.displayName.lowercased() }) else { return }
        plants.append(plant)
        saveToDisk()
    }

    func remove(_ plant: GreenhousePlant) {
        plants.removeAll { $0.id == plant.id }
        saveToDisk()
    }

    func clear() {
        plants.removeAll()
        saveToDisk()
    }
    
    /// Sets the lastWatered date to now for the given plant, and persists the update.
    func markWatered(for plant: GreenhousePlant) {
        if let idx = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[idx].lastWatered = Date()
            saveToDisk()
        }
    }

    private func cacheFileURL() -> URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(cacheFileName)
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(plants)
            try data.write(to: cacheFileURL(), options: [.atomic])
        } catch {
            print("Failed to save plants to disk: \(error)")
        }
    }

    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: cacheFileURL())
            plants = try JSONDecoder().decode([GreenhousePlant].self, from: data)
        } catch {
            // If loading fails, just start with an empty list
            plants = []
        }
    }
}
