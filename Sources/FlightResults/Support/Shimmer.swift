import SwiftUI

/// A moving gradient mask over static gray shapes. `.redacted(reason:
/// .placeholder)` needs real content to redact against, which doesn't
/// exist yet while the request is in flight, so this is the more direct
/// fit for skeleton cards.
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.5), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: phase * geometry.size.width * 2)
                    // Sized off the same `geometry` the sweep itself uses,
                    // so the highlight is guaranteed to span the card's
                    // actual full width. Using `content` as a `.mask` here
                    // instead re-lays it out as a separate instance inside
                    // this overlay, which isn't guaranteed the same width
                    // as the real card — clipping to rounded corners this
                    // way keeps both the full-width sweep and the rounding.
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer(cornerRadius: CGFloat = 0) -> some View {
        modifier(ShimmerModifier(cornerRadius: cornerRadius))
    }
}
