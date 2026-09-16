import Foundation

enum FlightResultsState {
    case loading
    case success([FlightOffer])
    case empty
    case error(String)
}
