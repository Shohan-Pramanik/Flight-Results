import SwiftUI

/// Same layout/size as `FlightCardView`, with gray placeholder blocks
/// instead of text, animated by the shared `.shimmer()` modifier. Shown
/// only in the `.loading` state.
struct FlightCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().frame(width: 24, height: 24)
                RoundedRectangle(cornerRadius: 4).frame(width: 100, height: 12)
                Spacer()
            }
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 4).frame(width: 50, height: 16)
                Spacer()
                RoundedRectangle(cornerRadius: 4).frame(width: 60, height: 24)
                Spacer()
                RoundedRectangle(cornerRadius: 4).frame(width: 50, height: 16)
            }
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4).frame(width: 80, height: 16)
            }
        }
        .foregroundStyle(Color(.systemGray5))
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .shimmer()
    }
}
