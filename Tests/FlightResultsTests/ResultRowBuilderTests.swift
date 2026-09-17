import XCTest
@testable import FlightResults

final class ResultRowBuilderTests: XCTestCase {
    func test_rows_noOffers_isEmpty() {
        XCTAssertTrue(ResultRowBuilder.rows(for: []).isEmpty)
    }

    func test_rows_oneOffer_noPromo() {
        let offers = [TestFixtures.offer()]
        let rows = ResultRowBuilder.rows(for: offers)
        XCTAssertEqual(rows.count, 1)
        XCTAssertTrue(isFlight(rows[0]))
    }

    func test_rows_twoOffers_noPromo() {
        let offers = [TestFixtures.offer(), TestFixtures.offer()]
        let rows = ResultRowBuilder.rows(for: offers)
        XCTAssertEqual(rows.count, 2)
        XCTAssertTrue(rows.allSatisfy(isFlight))
    }

    func test_rows_threeOffers_insertsPromoAtIndexTwo() {
        let offers = (0..<3).map { _ in TestFixtures.offer() }
        let rows = ResultRowBuilder.rows(for: offers)

        XCTAssertEqual(rows.count, 4)
        XCTAssertTrue(isFlight(rows[0]))
        XCTAssertTrue(isFlight(rows[1]))
        XCTAssertTrue(isPromo(rows[2]))
        XCTAssertTrue(isFlight(rows[3]))
    }

    func test_rows_manyOffers_promoStaysAtIndexTwo_restPreserveOrder() {
        let offers = (0..<5).map { i in TestFixtures.offer(id: "offer-\(i)") }
        let rows = ResultRowBuilder.rows(for: offers)

        XCTAssertEqual(rows.count, 6)
        XCTAssertTrue(isPromo(rows[2]))

        let flightIds = rows.compactMap { row -> String? in
            if case .flight(let offer) = row { return offer.id }
            return nil
        }
        XCTAssertEqual(flightIds, ["offer-0", "offer-1", "offer-2", "offer-3", "offer-4"])
    }

    func test_rows_ids_flightUsesOfferId_promoIsFixed() {
        let offer = TestFixtures.offer(id: "abc-123")
        let rows = ResultRowBuilder.rows(for: [offer])
        XCTAssertEqual(rows[0].id, "abc-123")

        let manyOffers = (0..<3).map { _ in TestFixtures.offer() }
        let rowsWithPromo = ResultRowBuilder.rows(for: manyOffers)
        XCTAssertEqual(rowsWithPromo[2].id, "promo")
    }

    // MARK: helpers

    private func isFlight(_ row: ResultRow) -> Bool {
        if case .flight = row { return true }
        return false
    }

    private func isPromo(_ row: ResultRow) -> Bool {
        if case .promo = row { return true }
        return false
    }
}
