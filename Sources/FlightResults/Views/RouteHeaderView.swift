import SwiftUI

/// Static, fixed at the top of the screen, never scrolls away. Origin/
/// destination and date come from the search request, not the API
/// response, so this renders identically regardless of loading/success/
/// empty/error state.
struct RouteHeaderView: View {
    let request: FlightSearchRequest
    let onTapEdit: () -> Void

    private var originCity: String { AirportCity.name(forCode: request.departureId) }
    private var destinationCity: String { AirportCity.name(forCode: request.arrivalId) }
    private var dateLabel: String { DateFormatting.displayDate(request.outboundDate) }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(originCity) → \(destinationCity)")
                    .font(.headline)
                Text("\(dateLabel) · 1 Adult · One Way")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Present, tappable, decorative — there's no edit flow in scope.
            Button(action: onTapEdit) {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
