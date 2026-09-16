import Foundation

enum FlightOfferMapper {
    /// Maps both `best_flights` and `other_flights` through the same
    /// per-group mapping, concatenating best-first. "Best" is Google's own
    /// ranking, so keeping it first gives a sensible default order for
    /// free; there's no badge in the UI distinguishing the two groups.
    static func map(_ response: FlightSearchResponse, request: FlightSearchRequest) -> [FlightOffer] {
        let best = (response.bestFlights ?? []).compactMap { map($0, currencyCode: request.currency) }
        let other = (response.otherFlights ?? []).compactMap { map($0, currencyCode: request.currency) }
        return best + other
    }

    /// A group that fails to produce every required field (empty `flights`,
    /// missing `price`, unparseable times) is dropped rather than crashing
    /// the whole mapping pass — one bad entry shouldn't take down the
    /// results screen.
    static func map(_ group: RawFlightGroup, currencyCode: String) -> FlightOffer? {
        guard
            let firstLeg = group.flights.first,
            let lastLeg = group.flights.last,
            let price = group.price,
            let departureTime = DateFormatting.apiDateTime.date(from: firstLeg.departureAirport.time),
            let arrivalTime = DateFormatting.apiDateTime.date(from: lastLeg.arrivalAirport.time)
        else {
            return nil
        }

        return FlightOffer(
            id: UUID().uuidString,
            airline: firstLeg.airline,
            airlineLogoURL: firstLeg.airlineLogo.flatMap(URL.init(string:)),
            originCode: firstLeg.departureAirport.id,
            destinationCode: lastLeg.arrivalAirport.id,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            totalDurationMinutes: group.totalDuration,
            stops: group.layovers?.count ?? 0,
            price: price,
            currencyCode: currencyCode
        )
    }
}
