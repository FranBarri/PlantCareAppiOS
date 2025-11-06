//
//  PlantAPI.swift
//  PlantParentiOS
//
//  Created by stud on 06/11/2025.
//

import Foundation
import Combine

struct PerenualResponse: Codable {
    let data: [PerenualPlant]
}

struct PerenualPlant: Codable, Identifiable {
    let id: Int
    let common_name: String
    let watering: String
    let sunlight: [String]
    let indoor: Bool
    let poisonous_to_pets: Int?
    let default_image: DefaultImage?
    
    struct DefaultImage: Codable {
        let regular_url: String
    }
}

@MainActor
class PlantStore: ObservableObject {
    @Published var plants: [PerenualPlant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "kM6ci69caf9f1d9a813339"
    
    init () {}
    
    func fetchPlants(page: Int = 1) async {
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "https://www.perenual.com/api/v2/species-list?page=\(page)&key=\(apiKey)&indoor1") else {
            errorMessage = "Invalid URL"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PerenualResponse.self, from: data)
            plants.append(contentsOf: response.data)
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            print("Error: \(error)")
        }
    }
}
