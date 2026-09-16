import SwiftUI

/// Shown above the skeleton cards while results are loading — a static
/// progress bar plus reassurance copy. Not tied to real progress, since
/// there's nothing to measure progress against (a single fixture fetch).
struct FlightSearchLoadingHeaderView: View {
    // Matches FixtureFlightSearchService's artificial load delay, so the
    // bar finishes filling right as results actually arrive.
    private let simulatedLoadDuration: Double = 3

    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.3))
                    Capsule().fill(Color.orange).frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 4)
            .onAppear {
                withAnimation(.linear(duration: simulatedLoadDuration)) {
                    progress = 1
                }
            }

            Text("Hang tight! We're finding the best flight options for you.")
                .font(.custom("Gilroy-SemiBold", size: 20))
                .lineSpacing(10)
                .tracking(0)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}
