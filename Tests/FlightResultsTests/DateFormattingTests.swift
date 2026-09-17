import XCTest
@testable import FlightResults

final class DateFormattingTests: XCTestCase {
    // MARK: apiDate

    func test_apiDate_parsesAndFormatsRoundTrip() throws {
        let date = try XCTUnwrap(DateFormatting.apiDate.date(from: "2026-09-30"))
        XCTAssertEqual(DateFormatting.apiDate.string(from: date), "2026-09-30")
    }

    func test_apiDate_rejectsWrongShape() {
        XCTAssertNil(DateFormatting.apiDate.date(from: "2026-09-30 10:00"))
        XCTAssertNil(DateFormatting.apiDate.date(from: "not-a-date"))
    }

    // MARK: apiDateTime

    func test_apiDateTime_parsesAndFormatsRoundTrip() throws {
        let date = try XCTUnwrap(DateFormatting.apiDateTime.date(from: "2026-09-30 14:35"))
        XCTAssertEqual(DateFormatting.apiDateTime.string(from: date), "2026-09-30 14:35")
    }

    func test_apiDateTime_rejectsMalformedInput() {
        XCTAssertNil(DateFormatting.apiDateTime.date(from: "2026-09-30"))
        XCTAssertNil(DateFormatting.apiDateTime.date(from: ""))
    }

    // MARK: flightTime — must be 24h, no AM/PM

    func test_flightTime_morning_is24Hour() throws {
        let date = try XCTUnwrap(DateFormatting.apiDateTime.date(from: "2026-09-30 05:00"))
        XCTAssertEqual(DateFormatting.flightTime.string(from: date), "05:00")
    }

    func test_flightTime_afternoon_doesNotShowPM() throws {
        let date = try XCTUnwrap(DateFormatting.apiDateTime.date(from: "2026-09-30 14:00"))
        XCTAssertEqual(DateFormatting.flightTime.string(from: date), "14:00")
    }

    func test_flightTime_midnight_isZeroZero() throws {
        let date = try XCTUnwrap(DateFormatting.apiDateTime.date(from: "2026-09-30 00:50"))
        XCTAssertEqual(DateFormatting.flightTime.string(from: date), "00:50")
    }

    func test_flightTime_noonIsTwelveHundred() throws {
        let date = try XCTUnwrap(DateFormatting.apiDateTime.date(from: "2026-09-30 12:00"))
        XCTAssertEqual(DateFormatting.flightTime.string(from: date), "12:00")
    }

    // MARK: displayDate

    func test_displayDate_formatsDayMonthYear() throws {
        let date = try XCTUnwrap(DateFormatting.apiDate.date(from: "2026-09-30"))
        XCTAssertEqual(DateFormatting.displayDate(date), "30 Sep 2026")
    }

    func test_displayDate_singleDigitDay_noLeadingZero() throws {
        let date = try XCTUnwrap(DateFormatting.apiDate.date(from: "2026-10-01"))
        XCTAssertEqual(DateFormatting.displayDate(date), "1 Oct 2026")
    }
}
