import XCTest

/// Exercises the app against the bundled fixture (`Fixtures/lax_hnd_response.json`),
/// which `FixtureFlightSearchService` always serves in DEBUG builds — so these
/// assertions are pinned to that fixture's known airlines/prices/durations
/// rather than anything fetched live.
final class FlightResultsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func firstFlightCard() -> XCUIElement {
        app.otherElements.matching(identifier: "flightCard").element(boundBy: 0)
    }

    func test_launch_showsLoadingThenResultsWithFixtureData() {
        // The loading state is transient (the fixture's simulated delay is
        // only ~3s), so we don't assert on it directly to avoid a race —
        // just that results eventually replace it.
        let firstCard = firstFlightCard()
        XCTAssertTrue(
            firstCard.waitForExistence(timeout: 10),
            "Expected flight results to load within the fixture's simulated delay"
        )

        // Unsorted results are best_flights + other_flights concatenated as-is,
        // so the first card is the fixture's first best_flights entry: ANA, $582.
        XCTAssertTrue(firstCard.staticTexts["ANA"].exists)
        XCTAssertTrue(firstCard.staticTexts["582"].exists)
    }

    func test_tappingCheapestSort_reordersToCheapestOfferAcrossWholeList() {
        XCTAssertTrue(firstFlightCard().waitForExistence(timeout: 10))

        app.buttons["sortButton"].tap()
        app.buttons["sortOption.Cheapest"].tap()

        // The cheapest offer overall is in other_flights (United, $486), so
        // tapping Cheapest must pull it above the initially-first ANA/$582 card.
        let reorderedFirstCard = firstFlightCard()
        XCTAssertTrue(reorderedFirstCard.staticTexts["United"].waitForExistence(timeout: 2))
        XCTAssertTrue(reorderedFirstCard.staticTexts["486"].exists)
    }

    func test_tappingFastestSort_reordersToShortestDurationOffer() {
        XCTAssertTrue(firstFlightCard().waitForExistence(timeout: 10))

        app.buttons["sortButton"].tap()
        app.buttons["sortOption.Fastest"].tap()

        // Shortest total_duration in the fixture is JAL's best_flights entry
        // (685 min), even though it isn't the cheapest offer.
        let reorderedFirstCard = firstFlightCard()
        XCTAssertTrue(reorderedFirstCard.staticTexts["JAL"].waitForExistence(timeout: 2))
        XCTAssertTrue(reorderedFirstCard.staticTexts["781"].exists)
    }

    func test_tappingLearnMore_navigatesToWebLink() {
        XCTAssertTrue(firstFlightCard().waitForExistence(timeout: 10))

        app.buttons["learnMoreButton"].firstMatch.tap()

        // WebLinkView sets its nav title to the opened URL's host
        // (DiscountCarouselView always opens gozayaan.com).
        XCTAssertTrue(app.navigationBars["gozayaan.com"].waitForExistence(timeout: 3))

        app.navigationBars["gozayaan.com"].buttons.firstMatch.tap()
        XCTAssertTrue(firstFlightCard().waitForExistence(timeout: 3), "Expected back navigation to return to the results list")
    }
}
