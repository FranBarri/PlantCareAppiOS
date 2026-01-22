import XCTest
@testable import PlantParentiOS

final class AppIntegrationTests: XCTestCase {
    func testFetchAndAddPlantToGreenhouse() async throws {
        // Fetch plants from the API (integration with remote or fallback)
        let store = PlantStore()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        let fetchedPlants = store.plants
        guard let firstPlant = fetchedPlants.first else {
            XCTFail("No plants were fetched from the API or fallback. Test cannot proceed.")
            return
        }

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
