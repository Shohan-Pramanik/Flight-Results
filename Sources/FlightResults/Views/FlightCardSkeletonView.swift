import SwiftUI

/// A simplified placeholder (logo circle + two shimmering bars) shown
/// only in the `.loading` state, on a translucent card so it reads as
/// "ghosted" against the navy background rather than a loaded card.
struct FlightCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle().frame(width: 36, height: 36)
                RoundedRectangle(cornerRadius: 4).frame(height: 14)
            }
            RoundedRectangle(cornerRadius: 4).frame(width: 70, height: 14)
        }
        .foregroundStyle(Color.white.opacity(0.35))
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.12)))
        .shimmer()
    }
}
