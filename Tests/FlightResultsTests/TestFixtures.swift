import Foundation
@testable import FlightResults

/// Shared factories so each test only has to specify the fields it's
/// actually asserting on, instead of the full raw-model shape every time.
enum TestFixtures {
    static func rawLeg(
        origin: String = "LAX",
        destination: String = "HND",
        departure: String = "2026-09-30 10:00",
        arrival: String = "2026-09-30 12:00",
        duration: Int = 120,
        airline: String = "Test Air",
        airlineLogo: String? = nil
    ) -> RawFlightLeg {
        RawFlightLeg(
            departureAirport: RawAirportStop(id: origin, time: departure),
            arrivalAirport: RawAirportStop(id: destination, time: arrival),
            duration: duration,
            airline: airline,
            airlineLogo: airlineLogo
        )
    }

    static func rawGroup(
        flights: [RawFlightLeg]? = nil,
        layovers: [RawLayover]? = nil,
        totalDuration: Int = 120,
        price: Int? = 500
    ) -> RawFlightGroup {
        RawFlightGroup(
            flights: flights ?? [rawLeg()],
            layovers: layovers,
            totalDuration: totalDuration,
            price: price
        )
    }

    static func offer(
        id: String = UUID().uuidString,
        airline: String = "Test Air",
        airlineLogoURL: URL? = nil,
        originCode: String = "LAX",
        destinationCode: String = "HND",
        departureTime: Date = Date(timeIntervalSince1970: 0),
        arrivalTime: Date = Date(timeIntervalSince1970: 3_600),
        totalDurationMinutes: Int = 600,
        stops: Int = 0,
        price: Int = 500,
        currencyCode: String = "USD"
    ) -> FlightOffer {
        FlightOffer(
            id: id,
            airline: airline,
            airlineLogoURL: airlineLogoURL,
            originCode: originCode,
            destinationCode: destinationCode,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            totalDurationMinutes: totalDurationMinutes,
            stops: stops,
            price: price,
            currencyCode: currencyCode
        )
    }

    static func request(
        departureId: String = "LAX",
        arrivalId: String = "HND",
        outboundDate: Date = Date(timeIntervalSince1970: 0),
        currency: String = "USD"
    ) -> FlightSearchRequest {
        FlightSearchRequest(
            departureId: departureId,
            arrivalId: arrivalId,
            outboundDate: outboundDate,
            currency: currency
        )
    }
}

struct TestError: Error, Equatable {
    let message: String
    init(_ message: String = "test error") { self.message = message }
}
