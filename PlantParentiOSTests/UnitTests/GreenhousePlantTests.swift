import XCTest
@testable import PlantParentiOS

final class GreenhousePlantTests: XCTestCase {
    func testInitSetsAllProperties() {
        let now = Date()
        let plant = GreenhousePlant(
            plantID: 42,
            displayName: "Test Plant",
            imageURL: "http://example.com/image.png",
            imageName: "localImage",
            nickname: "Buddy",
            dateAdded: now,
            notes: "Needs lots of sun",
            quantity: 3,
            lastWatered: now,
            wateringIntervalDays: 5
        )
        XCTAssertEqual(plant.plantID, 42)
        XCTAssertEqual(plant.displayName, "Test Plant")
        XCTAssertEqual(plant.imageURL, "http://example.com/image.png")
        XCTAssertEqual(plant.imageName, "localImage")
        XCTAssertEqual(plant.nickname, "Buddy")
        XCTAssertEqual(plant.dateAdded, now)
        XCTAssertEqual(plant.notes, "Needs lots of sun")
        XCTAssertEqual(plant.quantity, 3)
        XCTAssertEqual(plant.lastWatered, now)
        XCTAssertEqual(plant.wateringIntervalDays, 5)
    }

    func testCodableRoundTrip() throws {
        let plant = GreenhousePlant(
            plantID: 1,
            displayName: "Test",
            imageURL: nil,
            imageName: nil,
            nickname: nil,
            dateAdded: Date(),
            notes: nil,
            quantity: 1,
            lastWatered: nil,
            wateringIntervalDays: nil
        )
        let data = try JSONEncoder().encode(plant)
        let decoded = try JSONDecoder().decode(GreenhousePlant.self, from: data)
        XCTAssertEqual(decoded.plantID, plant.plantID)
        XCTAssertEqual(decoded.displayName, plant.displayName)
    }
}
