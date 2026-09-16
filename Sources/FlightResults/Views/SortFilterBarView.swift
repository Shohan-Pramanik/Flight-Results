import SwiftUI

/// Sits directly above the flight cards. "Cheapest" reveals the sort
/// choices via a custom floating card — SwiftUI's native `Menu` renders as
/// a system context menu and can't match the design's rounded, shadowed
/// dropdown. "Filter" is decorative only — no filter criteria are in scope.
struct SortFilterBarView: View {
    let onSelectSort: (SortOption) -> Void
    let onTapFilter: () -> Void

    @State private var isSortMenuOpen = false
    @State private var selectedSort: SortOption = .cheapest

    var body: some View {
        HStack {
            Button {
                isSortMenuOpen.toggle()
            } label: {
                pill(
                    label: selectedSort.label,
                    systemImage: isSortMenuOpen ? "chevron.up" : "chevron.down",
                    background: .clear,
                    border: .white,
                    foreground: .white
                )
            }
            .overlay(alignment: .topLeading) {
                if isSortMenuOpen {
                    sortMenu.offset(y: 48)
                }
            }

            Spacer()

            Button(action: onTapFilter) {
                pill(label: "Filter", systemImage: "slider.horizontal.3", background: Color("SelectedDateGold"))
            }
        }
        .padding(16)
    }

    private var sortMenu: some View {
        VStack(spacing: 4) {
            sortRow(.cheapest)
            sortRow(.fastest)
        }
        .padding(16)
        .frame(width: 200, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }

    private func sortRow(_ option: SortOption) -> some View {
        Button {
            selectedSort = option
            isSortMenuOpen = false
            onSelectSort(option)
        } label: {
            Text(option.label)
                .font(.custom("AvenirNext-Bold", size: 12))
                .lineSpacing(6)
                .tracking(0)
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(option == selectedSort ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        }
    }

    private func pill(
        label: String,
        systemImage: String,
        background: Color,
        border: Color? = nil,
        foreground: Color = Color.accentColor
    ) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.custom("Gilroy-Bold", size: 12))
                .lineSpacing(2)
                .tracking(0)
                .multilineTextAlignment(.center)
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(background))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(border ?? .clear, lineWidth: 1.5))
    }
}
