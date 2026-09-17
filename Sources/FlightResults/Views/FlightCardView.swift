import SwiftUI

/// Populated entirely from a mapped `FlightOffer`, except the "Get Points"
/// badge — that's purely cosmetic, identical on every card, with no
/// corresponding field anywhere in the SerpApi response or the brief.
struct FlightCardView: View {
    let offer: FlightOffer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            routeRow
            priceRow
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
    }

    private var header: some View {
        HStack {
            AsyncImage(url: offer.airlineLogoURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFit()
                } else {
                    Image(systemName: "airplane.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 24, height: 24)

            Text(offer.airline)
                .font(.custom("AvenirNext-Regular", size: 14))
                .lineSpacing(6)

            Spacer()

            HStack(spacing: 4) {
                Image("clubPoint")
                    .resizable()
                    .frame(width: 14, height: 14)
                Text("Get Points")
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .lineSpacing(6)
                    .multilineTextAlignment(.trailing)
            }
            .foregroundStyle(.orange)
        }
    }

    private var routeRow: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DateFormatting.flightTime.string(from: offer.departureTime))
                        .font(.custom("Gilroy-Bold", size: 16))
                        .lineSpacing(8)
                        
                    Text(offer.originCode)
                        .font(.custom("AvenirNext-Medium", size: 12))
                        .lineSpacing(6)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text(FlightOfferFormatting.duration(minutes: offer.totalDurationMinutes))
                        .font(.custom("AvenirNext-Regular", size: 12))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    routeVisual
                        .frame(width: 100)
                    Text(offer.stopsLabel)
                        .font(.custom("AvenirNext-Regular", size: 12))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .top, spacing: 2) {
                        Text(DateFormatting.flightTime.string(from: offer.arrivalTime))
                            .font(.custom("Gilroy-Bold", size: 16))
                            .lineSpacing(8)
                        if offer.arrivalDayOffset > 0 {
                            Text("+\(offer.arrivalDayOffset)Day")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                        }
                    }
                    Text(offer.destinationCode)
                        .font(.custom("AvenirNext-Medium", size: 12))
                        .lineSpacing(6)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                }
                .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
            .frame(height: 1)
        }
    }

    /// A dot-line-dot flight path — one filled dot per actual layover, so
    /// a 2-stop route shows 2 filled middle dots. The origin/destination
    /// dots stay hollow to distinguish them from layover markers.
    private var routeVisual: some View {
        HStack(spacing: 0) {
            routeEndDot
            ForEach(0..<offer.stops, id: \.self) { _ in
                routeLine
                routeStopDot
            }
            routeLine
            routeEndDot
        }
    }

    private var routeEndDot: some View {
        Circle()
            .strokeBorder(Color.blue, lineWidth: 1.5)
            .frame(width: 8, height: 8)
    }

    /// Filled — the layover marker, to draw the eye.
    private var routeStopDot: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 8, height: 8)
    }

    private var routeLine: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 1)
    }

    private var priceRow: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Starting from")
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .lineSpacing(6)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(offer.currencyCode)
                        .font(.custom("AvenirNext-Medium", size: 12))
                        .lineSpacing(6)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                    Text(FlightOfferFormatting.amount(offer.price))
                        .font(.custom("Gilroy-Bold", size: 16))
                        .lineSpacing(8)
                        .foregroundStyle(Color("AccentColor"))
                }
            }
        }
    }
}
