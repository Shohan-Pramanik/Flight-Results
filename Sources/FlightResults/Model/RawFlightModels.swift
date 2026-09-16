import Foundation

/// Mirrors the SerpApi `google_flights` (one-way) response shape.
/// Only the fields the UI actually needs are declared — `Codable` ignores
/// any key that isn't listed here, so the rest of the payload
/// (`carbon_emissions`, `extensions`, `booking_token`, `price_insights`, …)
/// is safely dropped rather than causing a decode failure.
struct FlightSearchResponse: Codable {
    let bestFlights: [RawFlightGroup]?
    let otherFlights: [RawFlightGroup]?

    enum CodingKeys: String, CodingKey {
        case bestFlights = "best_flights"
        case otherFlights = "other_flights"
    }
}

struct RawFlightGroup: Codable {
    let flights: [RawFlightLeg]
    let layovers: [RawLayover]?
    let totalDuration: Int
    let price: Int?

    enum CodingKeys: String, CodingKey {
        case flights, layovers, price
        case totalDuration = "total_duration"
    }
}

struct RawFlightLeg: Codable {
    let departureAirport: RawAirportStop
    let arrivalAirport: RawAirportStop
    let duration: Int
    let airline: String
    let airlineLogo: String?

    enum CodingKeys: String, CodingKey {
        case departureAirport = "departure_airport"
        case arrivalAirport = "arrival_airport"
        case duration, airline
        case airlineLogo = "airline_logo"
    }
}

struct RawAirportStop: Codable {
    let id: String
    let time: String
}

struct RawLayover: Codable {
    let duration: Int
    let name: String
    let id: String
}
