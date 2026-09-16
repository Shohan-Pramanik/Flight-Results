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
        HStack(alignment: .center) {
            Spacer().frame(width: 32)

            VStack(spacing: 4) {
                Text("\(originCity) - \(destinationCity)")
                    .font(.custom("Gilroy-Bold", size: 20))
                    .lineSpacing(10)
                    .tracking(0)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                (Text("\(dateLabel) | ")
                    + Text(Image(systemName: "person"))
                    + Text(" 01 | One Way"))
                    .font(.custom("AvenirNext-Medium", size: 12))
                    .lineSpacing(6)
                    .tracking(0)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)

            // Present, tappable, decorative — there's no edit flow in scope.
            Button(action: onTapEdit) {
                VStack(spacing: 2) {
                    Image(systemName: "pencil.line")
                    Text("Edit")
                        .font(.caption2)
                }
                .foregroundStyle(.white)
            }
            .frame(width: 32)
        }
        .padding()
    }
}
