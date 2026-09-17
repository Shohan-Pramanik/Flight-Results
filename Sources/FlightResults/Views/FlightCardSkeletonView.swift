import SwiftUI

/// A simplified placeholder (logo circle + two shimmering bars) shown
/// only in the `.loading` state, on a translucent card so it reads as
/// "ghosted" against the navy background rather than a loaded card.
struct FlightCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Circle().frame(width: 24, height: 24)
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 80).frame(width: 200, height: 8)
                    RoundedRectangle(cornerRadius: 80).frame(width: 100, height: 8)
                }
            }
            RoundedRectangle(cornerRadius: 4).frame(width: 48, height: 16)
        }
        .foregroundStyle(Color.white.opacity(0.35))
        .padding()
        .frame(maxWidth: .infinity, minHeight: 116,  alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.07, blue: 0.32),
                    Color(red: 0.20, green: 0.36, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shimmer(cornerRadius: 8)
    }
}
