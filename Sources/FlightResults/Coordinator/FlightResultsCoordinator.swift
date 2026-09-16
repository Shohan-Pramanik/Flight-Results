import SwiftUI

/// The only place in this task that knows navigation exists. Owns the
/// `NavigationPath`, creates the ViewModel, sets itself as its delegate,
/// and turns delegate callbacks into real pushes onto the stack —
/// `FlightResultsView` never imports or references `WKWebView` or
/// navigation types directly.
@MainActor
final class FlightResultsCoordinator: ObservableObject, FlightResultsCoordinatorDelegate {
    @Published var path = NavigationPath()

    let viewModel: FlightResultsViewModel

    init(viewModel: FlightResultsViewModel) {
        self.viewModel = viewModel
        viewModel.delegate = self
    }

    @ViewBuilder
    func start() -> some View {
        // `self.$path` here is `Published<NavigationPath>.Publisher`, not a
        // `Binding` — that projection only exists when accessed through
        // `@ObservedObject`/`@StateObject` from within a View. Building the
        // binding manually is what actually lets NavigationStack read and
        // write `path` on this object.
        let pathBinding = Binding<NavigationPath>(
            get: { self.path },
            set: { self.path = $0 }
        )

        NavigationStack(path: pathBinding) {
            FlightResultsView(viewModel: viewModel)
                .navigationDestination(for: FlightResultsRoute.self) { route in
                    switch route {
                    case .webLink(let url):
                        WebLinkView(url: url)
                    }
                }
        }
        .environmentObject(self)
    }

    // MARK: FlightResultsCoordinatorDelegate

    func didTapLearnMore(url: URL) {
        path.append(FlightResultsRoute.webLink(url))
    }

    func didSelectFlight(_ offer: FlightOffer) {
        // No destination screen in scope for this task — intentionally a
        // no-op, but still routed through the Coordinator rather than
        // handled locally in the View or ViewModel.
    }
}
