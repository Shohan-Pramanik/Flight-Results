import SwiftUI

struct EmptyResultsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No flights found for this route")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
