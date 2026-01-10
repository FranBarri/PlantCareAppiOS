// GreenhousePlant.swift
// Model to store plants added by user to their greenhouse
import Foundation

struct GreenhousePlant: Identifiable, Codable {
    let id: UUID
    let plantID: Int // Corresponds to PerenualPlant.id
    var displayName: String
    var imageURL: String?
    var imageName: String? // fallback local asset
    var nickname: String?
    var dateAdded: Date
    var notes: String?
    var quantity: Int
    
    /// The date this plant was last watered.
    var lastWatered: Date?
    
    /// The recommended interval in days between waterings for this plant.
    /// This can be set by the user or inferred from API data.
    var wateringIntervalDays: Int?
    
    init(plantID: Int, displayName: String, imageURL: String? = nil, imageName: String? = nil, nickname: String? = nil, dateAdded: Date = Date(), notes: String? = nil, quantity: Int = 1, lastWatered: Date? = nil, wateringIntervalDays: Int? = nil) {
        self.id = UUID()
        self.plantID = plantID
        self.displayName = displayName
        self.imageURL = imageURL
        self.imageName = imageName
        self.nickname = nickname
        self.dateAdded = dateAdded
        self.notes = notes
        self.quantity = quantity
        self.lastWatered = lastWatered
        self.wateringIntervalDays = wateringIntervalDays
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case plantID
        case displayName
        case imageURL
        case imageName
        case nickname
        case dateAdded
        case notes
        case quantity
        case lastWatered
        case wateringIntervalDays
    }
}

