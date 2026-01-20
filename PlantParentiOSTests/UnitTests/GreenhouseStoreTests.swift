import XCTest
@testable import PlantParentiOS

final class GreenhouseStoreTests: XCTestCase {
    func testAddPlantPreventsDuplicates() {
        let store = GreenhouseStore()
        let plant1 = GreenhousePlant(
            plantID: 1,
            displayName: "Monstera",
            imageURL: nil,
            imageName: nil,
            nickname: nil,
            dateAdded: Date(),
            notes: nil,
            quantity: 1,
            lastWatered: nil,
            wateringIntervalDays: nil
        )
        let plant2 = GreenhousePlant(
            plantID: 2,
            displayName: "monstera", // lowercased to test case-insensitive
            imageURL: nil,
            imageName: nil,
            nickname: nil,
            dateAdded: Date(),
            notes: nil,
            quantity: 1,
            lastWatered: nil,
            wateringIntervalDays: nil
        )
        store.add(plant1)
        store.add(plant2)
        XCTAssertEqual(store.plants.count, 1, "Duplicate plant names should not be added.")
    }

    func testRemovePlant() {
        let store = GreenhouseStore()
        let plant = GreenhousePlant(
            plantID: 1,
            displayName: "Snake Plant",
            imageURL: nil,
            imageName: nil,
            nickname: nil,
            dateAdded: Date(),
            notes: nil,
            quantity: 1,
            lastWatered: nil,
            wateringIntervalDays: nil
        )
        store.add(plant)
        store.remove(plant)
        XCTAssertEqual(store.plants.count, 0, "Plant should be removed from the store.")
    }

    func testMarkWateredUpdatesDate() {
        let store = GreenhouseStore()
        var plant = GreenhousePlant(
            plantID: 1,
            displayName: "Aloe Vera",
            imageURL: nil,
            imageName: nil,
            nickname: nil,
            dateAdded: Date(),
            notes: nil,
            quantity: 1,
            lastWatered: nil,
            wateringIntervalDays: nil
        )
        store.add(plant)
        store.markWatered(for: plant)
        let updatedPlant = store.plants.first(where: { $0.id == plant.id })
        XCTAssertNotNil(updatedPlant?.lastWatered, "lastWatered should be set after marking watered.")
    }
}
