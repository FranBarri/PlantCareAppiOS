import Foundation

struct QuickTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let text: String
}

class QuickTipStore {
    static let tips: [QuickTip] = [
        QuickTip(icon: "drop.fill", title: "Watering", text: "Water when the top inch of soil is dry.\nAvoid Overwatering."),
        QuickTip(icon: "sun.max.fill", title: "Sunlight", text: "Rotate your plants weekly for even growth towards the light."),
        QuickTip(icon: "leaf.fill", title: "Fertilizing", text: "Feed your plants every 4-6 weeks during growing season."),
        QuickTip(icon: "thermometer", title: "Temperature", text: "Keep plants away from cold drafts and heat sources."),
        QuickTip(icon: "wind", title: "Air Circulation", text: "Ensure good airflow to prevent mold and pests."),
        QuickTip(icon: "scissors", title: "Pruning", text: "Remove dead leaves to encourage new growth."),
        QuickTip(icon: "ladybug.fill", title: "Pests", text: "Check leaves regularly for pests and treat promptly."),
        QuickTip(icon: "cloud.rain.fill", title: "Humidity", text: "Mist plants or use a tray of water for humidity-loving plants."),
        QuickTip(icon: "arrow.2.circlepath", title: "Repotting", text: "Repot when roots outgrow the pot, usually every 1-2 years."),
        QuickTip(icon: "moon.stars.fill", title: "Rest Period", text: "Some plants need less water and food in winter."),
        QuickTip(icon: "magnifyingglass", title: "Inspection", text: "Inspect plants weekly for signs of stress or disease."),
        QuickTip(icon: "flame.fill", title: "Sunburn", text: "Avoid direct midday sun for sensitive plants."),
        QuickTip(icon: "drop.triangle.fill", title: "Drainage", text: "Use pots with drainage holes to prevent root rot."),
        QuickTip(icon: "bolt.fill", title: "Growth", text: "Growth slows in winter—don’t worry, it’s normal!"),
        QuickTip(icon: "globe", title: "Placement", text: "Group plants with similar needs together.")
    ]
    
    static func randomTips(count: Int) -> [QuickTip] {
        Array(tips.shuffled().prefix(count))
    }
}
