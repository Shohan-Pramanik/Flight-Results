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
                pill(label: "Cheapest", systemImage: "chevron.down")
            }

            Spacer()

            Button(action: onTapFilter) {
                pill(label: "Filter", systemImage: "line.3.horizontal.decrease")
            }
        }
    }

    private func pill(label: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
            Image(systemName: systemImage)
        }
        .font(.footnote)
        .fontWeight(.medium)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color(.systemGray6)))
    }
}
