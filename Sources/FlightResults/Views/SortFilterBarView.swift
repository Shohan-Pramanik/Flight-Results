import SwiftUI

/// Sits directly above the flight cards. "Cheapest" reveals the sort
/// choices; "Filter" is decorative only — no filter criteria are in scope.
struct SortFilterBarView: View {
    let onSelectSort: (SortOption) -> Void
    let onTapFilter: () -> Void

    var body: some View {
        HStack {
            Menu {
                Button("Cheapest") { onSelectSort(.cheapest) }
                Button("Fastest") { onSelectSort(.fastest) }
            } label: {
                pill(label: "Cheapest", systemImage: "chevron.down", background: .white)
            }

            Spacer()

            Button(action: onTapFilter) {
                pill(label: "Filter", systemImage: "line.3.horizontal.decrease", background: .orange)
            }
        }
    }

    private func pill(label: String, systemImage: String, background: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
            Image(systemName: systemImage)
        }
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundStyle(Color.accentColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(background))
    }
}
