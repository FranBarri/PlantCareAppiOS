import XCTest
@testable import PlantParentiOS

final class AppIntegrationTests: XCTestCase {
    @MainActor
    func testFetchAndAddPlantToGreenhouse() async throws {
        // Use PlantStore's fetchPlants() function
        let plantStore = PlantStore()
        await plantStore.fetchPlants()
        
        guard let firstPlant = plantStore.plants.first else {
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
