import XCTest
@testable import PlantParentiOS

final class GreenhousePersistenceIntegrationTests: XCTestCase {
    func testGreenhouseStorePersistsPlants() {
        // Create a unique plant
        let uniquePlant = GreenhousePlant(
            plantID: 99999,
            displayName: "Test Persist Plant",
            imageURL: nil,
            dateAdded: Date()
        )
        // Add to store and persist
        var store = GreenhouseStore()
        store.clear()
        store.add(uniquePlant)
        XCTAssertTrue(store.plants.contains(where: { $0.plantID == uniquePlant.plantID }), "Plant should be added and present before reload")
        // Simulate app restart by creating a new store
        let reloadedStore = GreenhouseStore()
        XCTAssertTrue(reloadedStore.plants.contains(where: { $0.plantID == uniquePlant.plantID }), "Plant should persist after reload (disk persistence)")
        // Clean up
        reloadedStore.clear()
    }
}
