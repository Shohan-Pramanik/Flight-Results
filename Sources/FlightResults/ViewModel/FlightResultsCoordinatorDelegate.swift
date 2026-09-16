import Foundation

/// The ViewModel reports outward through this delegate rather than calling
/// navigation methods directly. It imports no UIKit navigation types and
/// holds no reference to the Coordinator itself — only the Coordinator
/// conforms to and implements this protocol.
///
/// Marked `@MainActor` because its only conformer (`FlightResultsCoordinator`)
/// and only caller (`FlightResultsViewModel`) are both main-actor-isolated —
/// leaving the protocol nonisolated would make that conformance cross
/// actor boundaries, which is an error under the Swift 6 language mode.
@MainActor
protocol FlightResultsCoordinatorDelegate: AnyObject {
    func didSelectFlight(_ offer: FlightOffer)
    func didTapLearnMore(url: URL)
}
