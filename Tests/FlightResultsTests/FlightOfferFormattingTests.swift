import XCTest
@testable import FlightResults

final class FlightOfferFormattingTests: XCTestCase {
    // MARK: duration

    func test_duration_zeroMinutes() {
        XCTAssertEqual(FlightOfferFormatting.duration(minutes: 0), "0h 00m")
    }

    func test_duration_underAnHour() {
        XCTAssertEqual(FlightOfferFormatting.duration(minutes: 45), "0h 45m")
    }

    func test_duration_exactHour_padsZeroMinutes() {
        XCTAssertEqual(FlightOfferFormatting.duration(minutes: 600), "10h 00m")
    }

    func test_duration_hoursAndMinutes_padsSingleDigitMinutes() {
        XCTAssertEqual(FlightOfferFormatting.duration(minutes: 125), "2h 05m")
    }

    func test_duration_matchesFixtureExample() {
        // 12h10m non-stop LAX -> HND, as seen in the bundled fixture.
        XCTAssertEqual(FlightOfferFormatting.duration(minutes: 730), "12h 10m")
    }

    // MARK: amount

    func test_amount_smallValue_noGrouping() {
        XCTAssertEqual(FlightOfferFormatting.amount(582), "582")
    }

    func test_amount_thousands_insertsGroupingSeparator() {
        XCTAssertEqual(FlightOfferFormatting.amount(37_400), "37,400")
    }

    func test_amount_millions_insertsMultipleSeparators() {
        XCTAssertEqual(FlightOfferFormatting.amount(1_000_000), "1,000,000")
    }

    func test_amount_zero() {
        XCTAssertEqual(FlightOfferFormatting.amount(0), "0")
    }
}
