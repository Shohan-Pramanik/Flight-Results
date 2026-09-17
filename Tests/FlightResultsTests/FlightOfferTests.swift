import XCTest
@testable import FlightResults

final class FlightOfferTests: XCTestCase {
    // MARK: stopsLabel

    func test_stopsLabel_zeroStops_isNonStop() {
        let offer = TestFixtures.offer(stops: 0)
        XCTAssertEqual(offer.stopsLabel, "Non-Stop")
    }

    func test_stopsLabel_oneStop_isSingularStop() {
        let offer = TestFixtures.offer(stops: 1)
        XCTAssertEqual(offer.stopsLabel, "1 Stop")
    }

    func test_stopsLabel_multipleStops_usesCount() {
        let offer = TestFixtures.offer(stops: 2)
        XCTAssertEqual(offer.stopsLabel, "2 Stop")

        let threeStops = TestFixtures.offer(stops: 3)
        XCTAssertEqual(threeStops.stopsLabel, "3 Stop")
    }

    // MARK: arrivalDayOffset

    func test_arrivalDayOffset_underADay_isZero() {
        let offer = TestFixtures.offer(totalDurationMinutes: 1_439)
        XCTAssertEqual(offer.arrivalDayOffset, 0)
    }

    func test_arrivalDayOffset_exactlyADay_isOne() {
        let offer = TestFixtures.offer(totalDurationMinutes: 1_440)
        XCTAssertEqual(offer.arrivalDayOffset, 1)
    }

    func test_arrivalDayOffset_overADay_flooredToWholeDays() {
        let offer = TestFixtures.offer(totalDurationMinutes: 1_500)
        XCTAssertEqual(offer.arrivalDayOffset, 1)
    }

    func test_arrivalDayOffset_multipleDays() {
        let offer = TestFixtures.offer(totalDurationMinutes: 2_880)
        XCTAssertEqual(offer.arrivalDayOffset, 2)
    }

    func test_arrivalDayOffset_zeroDuration_isZero() {
        let offer = TestFixtures.offer(totalDurationMinutes: 0)
        XCTAssertEqual(offer.arrivalDayOffset, 0)
    }
}
