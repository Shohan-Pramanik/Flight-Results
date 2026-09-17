import XCTest
@testable import FlightResults

final class AirportCityTests: XCTestCase {
    func test_knownCode_LAX() {
        XCTAssertEqual(AirportCity.name(forCode: "LAX"), "Los Angeles")
    }

    func test_knownCode_HND() {
        XCTAssertEqual(AirportCity.name(forCode: "HND"), "Tokyo")
    }

    func test_unknownCode_fallsBackToRawCode() {
        XCTAssertEqual(AirportCity.name(forCode: "JFK"), "JFK")
    }

    func test_emptyCode_fallsBackToEmptyString() {
        XCTAssertEqual(AirportCity.name(forCode: ""), "")
    }
}
