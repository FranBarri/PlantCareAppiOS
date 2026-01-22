import XCTest
@testable import PlantParentiOS

/// Integration test that covers fetching plants from the API and adding one to the GreenhouseStore.
final class AppIntegrationTests: XCTestCase {
    func testFetchAndAddPlantToGreenhouse() async throws {
        // Fetch plants from the API (integration with remote or fallback)
        let store = PlantStore()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds for async fetch
        let fetchedPlants = store.plants
        XCTAssertFalse(fetchedPlants.isEmpty, "Should fetch at least one plant from API or fallback")
        let firstPlant = fetchedPlants.first!

        // Convert to GreenhousePlant model
        let greenhousePlant = GreenhousePlant(
            plantID: firstPlant.id,
            displayName: firstPlant.displayName,
            imageURL: firstPlant.default_image?.regular_url,
            dateAdded: Date()
        )
        
        // Add to GreenhouseStore and verify
        let greenhouseStore = GreenhouseStore()
        greenhouseStore.clear()
        greenhouseStore.add(greenhousePlant)
        XCTAssertTrue(greenhouseStore.plants.contains(where: { $0.plantID == firstPlant.id }), "GreenhouseStore should contain the added plant")
    }
}
