import XCTest
@testable import PlantParentiOS

final class PlantAPITests: XCTestCase {
    func testPerenualPlantInitSetsProperties() {
        let image = PerenualPlant.DefaultImage(regular_url: "http://img.com", thumbnail: "thumb.png")
        let plant = PerenualPlant(
            id: 7,
            common_name: "Aloe",
            scientific_name: ["Aloe vera"],
            watering: "Moderate",
            sunlight: ["Full Sun"],
            indoor: true,
            poisonous_to_pets: false,
            default_image: image
        )
        XCTAssertEqual(plant.id, 7)
        XCTAssertEqual(plant.common_name, "Aloe")
        XCTAssertEqual(plant.scientific_name, ["Aloe vera"])
        XCTAssertEqual(plant.watering, "Moderate")
        XCTAssertEqual(plant.sunlight, ["Full Sun"])
        XCTAssertEqual(plant.indoor, true)
        XCTAssertEqual(plant.poisonous_to_pets, false)
        XCTAssertEqual(plant.default_image?.regular_url, "http://img.com")
    }

    func testDisplayNameCapitalization() {
        let plant = PerenualPlant(
            id: 1,
            common_name: "snake plant",
            scientific_name: ["Sansevieria"],
            watering: nil,
            sunlight: nil,
            indoor: nil,
            poisonous_to_pets: nil,
            default_image: nil
        )
        XCTAssertEqual(plant.displayName, "Snake Plant")
    }
}
