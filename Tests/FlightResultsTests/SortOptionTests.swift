import XCTest
@testable import FlightResults

final class SortOptionTests: XCTestCase {
    func test_label_cheapest() {
        XCTAssertEqual(SortOption.cheapest.label, "Cheapest")
    }

    func test_label_fastest() {
        XCTAssertEqual(SortOption.fastest.label, "Fastest")
    }
}

@MainActor
final class FlightResultsViewModelSortingTests: XCTestCase {
    func test_sortedOffers_cheapest_ascendingByPrice() {
        let offers = [
            TestFixtures.offer(id: "a", price: 300),
            TestFixtures.offer(id: "b", price: 100),
            TestFixtures.offer(id: "c", price: 200)
        ]

        let sorted = FlightResultsViewModel.sortedOffers(offers, by: .cheapest)

        XCTAssertEqual(sorted.map(\.id), ["b", "c", "a"])
    }

    func test_sortedOffers_fastest_ascendingByDuration() {
        let offers = [
            TestFixtures.offer(id: "a", totalDurationMinutes: 600),
            TestFixtures.offer(id: "b", totalDurationMinutes: 200),
            TestFixtures.offer(id: "c", totalDurationMinutes: 400)
        ]

        let sorted = FlightResultsViewModel.sortedOffers(offers, by: .fastest)

        XCTAssertEqual(sorted.map(\.id), ["b", "c", "a"])
    }

    func test_sortedOffers_cheapest_tiesKeepOriginalOrder() {
        // Stable-sort guarantee: equal-price offers must not be reordered
        // relative to each other.
        let offers = [
            TestFixtures.offer(id: "first", price: 100),
            TestFixtures.offer(id: "second", price: 100),
            TestFixtures.offer(id: "third", price: 100)
        ]

        let sorted = FlightResultsViewModel.sortedOffers(offers, by: .cheapest)

        XCTAssertEqual(sorted.map(\.id), ["first", "second", "third"])
    }

    func test_sortedOffers_fastest_tiesKeepOriginalOrder() {
        let offers = [
            TestFixtures.offer(id: "first", totalDurationMinutes: 500),
            TestFixtures.offer(id: "second", totalDurationMinutes: 500)
        ]

        let sorted = FlightResultsViewModel.sortedOffers(offers, by: .fastest)

        XCTAssertEqual(sorted.map(\.id), ["first", "second"])
    }

    func test_sortedOffers_empty_returnsEmpty() {
        XCTAssertTrue(FlightResultsViewModel.sortedOffers([], by: .cheapest).isEmpty)
    }
}
