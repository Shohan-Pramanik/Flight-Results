import Foundation

/// The domain model the UI binds to. No Codable, no networking types —
/// it's produced by `FlightOfferMapper` from a `RawFlightGroup`.
struct FlightOffer: Identifiable, Equatable {
    let id: String
    let airline: String
    let airlineLogoURL: URL?
    let originCode: String
    let destinationCode: String
    let departureTime: Date
    let arrivalTime: Date
    let totalDurationMinutes: Int
    let stops: Int
    let price: Int
    let currencyCode: String

    var stopsLabel: String {
        switch stops {
        case 0: return "Non-Stop"
        case 1: return "1 Stop"
        default: return "\(stops) Stop"
        }
    }

    /// The "arrives N day(s) later" badge, driven by total travel time
    /// rather than a calendar-date crossing: 24h+ of travel is +1Day,
    /// 48h+ is +2Days, and so on.
    var arrivalDayOffset: Int {
        totalDurationMinutes / (24 * 60)
    }
}
