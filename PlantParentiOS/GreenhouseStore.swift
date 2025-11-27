import SwiftUI
import Combine

final class GreenhouseStore: ObservableObject {
    @Published var plants: [Plant] = []

    func add(_ plant: Plant) {
        // Prevent duplicates by name for this session
        guard !plants.contains(where: { $0.name == plant.name }) else { return }
        plants.append(plant)
    }

    func clear() { plants.removeAll() }
}
