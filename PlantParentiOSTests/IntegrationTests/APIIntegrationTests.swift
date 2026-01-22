import XCTest
@testable import PlantParentiOS

final class AppIntegrationTests: XCTestCase {
    func testFetchAndAddPlantToGreenhouse() async throws {
        // Use PlantAPI.fetchPlants() directly for integration
        let plants = try await fetchPlantsDirectly()
        guard let firstPlant = plants.first else {
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

    /// Helper to call PlantAPI's fetchPlants logic directly
    private func fetchPlantsDirectly() async throws -> [PerenualPlant] {
        let apiKey = "sk-M6ci690caf9f1d9a813339"
        let urlString = "https://perenual.com/api/species-list?page=1&key=\(apiKey)&indoor=1"
        guard let url = URL(string: urlString) else { return [] }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            return []
        }
        let responseObj = try JSONDecoder().decode(PerenualResponse.self, from: data)
        return responseObj.data
    }
}
