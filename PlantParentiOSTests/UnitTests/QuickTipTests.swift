import XCTest
@testable import PlantParentiOS

final class QuickTipTests: XCTestCase {
    func testQuickTipInit() {
        let tip = QuickTip(icon: "leaf", title: "Watering", text: "Water your plants weekly.")
        XCTAssertEqual(tip.icon, "leaf")
        XCTAssertEqual(tip.title, "Watering")
        XCTAssertEqual(tip.text, "Water your plants weekly.")
    }
}
