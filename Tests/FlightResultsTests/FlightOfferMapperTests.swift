import XCTest
@testable import FlightResults

final class FlightOfferMapperTests: XCTestCase {
    // MARK: Single-group mapping

    func test_map_group_happyPath_mapsAllFields() throws {
        let leg = TestFixtures.rawLeg(
            origin: "LAX",
            destination: "HND",
            departure: "2026-09-30 10:00",
            arrival: "2026-09-30 12:30",
            airline: "ANA",
            airlineLogo: "https://example.com/ana.png"
        )
        let group = TestFixtures.rawGroup(flights: [leg], layovers: nil, totalDuration: 150, price: 582)

        let offer = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))

        XCTAssertEqual(offer.airline, "ANA")
        XCTAssertEqual(offer.airlineLogoURL, URL(string: "https://example.com/ana.png"))
        XCTAssertEqual(offer.originCode, "LAX")
        XCTAssertEqual(offer.destinationCode, "HND")
        XCTAssertEqual(offer.totalDurationMinutes, 150)
        XCTAssertEqual(offer.stops, 0)
        XCTAssertEqual(offer.price, 582)
        XCTAssertEqual(offer.currencyCode, "USD")
        XCTAssertEqual(offer.departureTime, DateFormatting.apiDateTime.date(from: "2026-09-30 10:00"))
        XCTAssertEqual(offer.arrivalTime, DateFormatting.apiDateTime.date(from: "2026-09-30 12:30"))
    }

    func test_map_group_usesFirstLegOriginAndLastLegDestination() throws {
        let firstLeg = TestFixtures.rawLeg(origin: "LAX", destination: "SFO", departure: "2026-09-30 08:00", arrival: "2026-09-30 09:00")
        let secondLeg = TestFixtures.rawLeg(origin: "SFO", destination: "HND", departure: "2026-09-30 11:00", arrival: "2026-09-30 20:00")
        let layover = RawLayover(duration: 120, name: "San Francisco", id: "SFO")
        let group = TestFixtures.rawGroup(flights: [firstLeg, secondLeg], layovers: [layover], totalDuration: 660, price: 700)

        let offer = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))

        // Origin comes from the FIRST leg's departure, destination from the
        // LAST leg's arrival — not the first leg's own arrival.
        XCTAssertEqual(offer.originCode, "LAX")
        XCTAssertEqual(offer.destinationCode, "HND")
        XCTAssertEqual(offer.airline, firstLeg.airline)
        XCTAssertEqual(offer.stops, 1)
    }

    func test_map_group_noLayovers_zeroStops() throws {
        let group = TestFixtures.rawGroup(layovers: nil)
        let offer = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))
        XCTAssertEqual(offer.stops, 0)
    }

    func test_map_group_multipleLayovers_countsAsStops() throws {
        let layovers = [
            RawLayover(duration: 60, name: "A", id: "A"),
            RawLayover(duration: 90, name: "B", id: "B")
        ]
        let group = TestFixtures.rawGroup(layovers: layovers)
        let offer = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))
        XCTAssertEqual(offer.stops, 2)
    }

    func test_map_group_missingAirlineLogo_nilURL() throws {
        let leg = TestFixtures.rawLeg(airlineLogo: nil)
        let group = TestFixtures.rawGroup(flights: [leg])
        let offer = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))
        XCTAssertNil(offer.airlineLogoURL)
    }

    func test_map_group_missingPrice_returnsNil() {
        let group = TestFixtures.rawGroup(price: nil)
        XCTAssertNil(FlightOfferMapper.map(group, currencyCode: "USD"))
    }

    func test_map_group_emptyFlights_returnsNil() {
        let group = TestFixtures.rawGroup(flights: [])
        XCTAssertNil(FlightOfferMapper.map(group, currencyCode: "USD"))
    }

    func test_map_group_unparseableDepartureTime_returnsNil() {
        let leg = TestFixtures.rawLeg(departure: "not-a-date")
        let group = TestFixtures.rawGroup(flights: [leg])
        XCTAssertNil(FlightOfferMapper.map(group, currencyCode: "USD"))
    }

    func test_map_group_unparseableArrivalTime_returnsNil() {
        let leg = TestFixtures.rawLeg(arrival: "not-a-date")
        let group = TestFixtures.rawGroup(flights: [leg])
        XCTAssertNil(FlightOfferMapper.map(group, currencyCode: "USD"))
    }

    func test_map_group_assignsAFreshIdentifier() throws {
        let group = TestFixtures.rawGroup()
        let first = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))
        let second = try XCTUnwrap(FlightOfferMapper.map(group, currencyCode: "USD"))
        XCTAssertNotEqual(first.id, second.id)
    }

    // MARK: Full response mapping

    func test_map_response_concatenatesBestThenOther() {
        let best = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Best Air")], price: 100)
        let other = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Other Air")], price: 200)
        let response = FlightSearchResponse(bestFlights: [best], otherFlights: [other])

        let offers = FlightOfferMapper.map(response, request: TestFixtures.request())

        XCTAssertEqual(offers.map(\.airline), ["Best Air", "Other Air"])
    }

    func test_map_response_nilGroups_treatedAsEmpty() {
        let response = FlightSearchResponse(bestFlights: nil, otherFlights: nil)
        let offers = FlightOfferMapper.map(response, request: TestFixtures.request())
        XCTAssertTrue(offers.isEmpty)
    }

    func test_map_response_dropsUnmappableGroupsWithoutFailingOthers() {
        let valid = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Valid")], price: 100)
        let invalid = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Invalid")], price: nil)
        let response = FlightSearchResponse(bestFlights: [valid, invalid], otherFlights: nil)

        let offers = FlightOfferMapper.map(response, request: TestFixtures.request())

        XCTAssertEqual(offers.count, 1)
        XCTAssertEqual(offers.first?.airline, "Valid")
    }

    func test_map_response_usesRequestCurrency() {
        let group = TestFixtures.rawGroup()
        let response = FlightSearchResponse(bestFlights: [group], otherFlights: nil)

        let offers = FlightOfferMapper.map(response, request: TestFixtures.request(currency: "JPY"))

        XCTAssertEqual(offers.first?.currencyCode, "JPY")
    }
}
