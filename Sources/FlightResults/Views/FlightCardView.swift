import SwiftUI

/// Populated entirely from a mapped `FlightOffer`, except the "Get Points"
/// badge — that's purely cosmetic, identical on every card, with no
/// corresponding field anywhere in the SerpApi response or the brief.
struct FlightCardView: View {
    let offer: FlightOffer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            routeRow
            priceRow
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
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
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                Text("Get Points")
            }
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.orange)
        }
    }

    private var routeRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(DateFormatting.flightTime.string(from: offer.departureTime))
                    .font(.headline)
                Text(offer.originCode)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 4) {
                Text(FlightOfferFormatting.duration(minutes: offer.totalDurationMinutes))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Rectangle().frame(height: 1)
                    Image(systemName: "airplane").font(.caption2)
                    Rectangle().frame(height: 1)
                }
                .foregroundStyle(.secondary)
                Text(offer.stopsLabel)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(DateFormatting.flightTime.string(from: offer.arrivalTime))
                    .font(.headline)
                Text(offer.destinationCode)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var priceRow: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Starting from")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(FlightOfferFormatting.price(offer.price, currencyCode: offer.currencyCode))
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
    }
}
