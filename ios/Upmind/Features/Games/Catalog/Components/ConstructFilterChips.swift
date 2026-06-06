import SwiftUI

/// Horizontally-scrolling row of chips that filter the catalog by
/// construct. The first chip is "All" (selection = nil); the rest mirror
/// `Construct.allCases` in declaration order.
struct ConstructFilterChips: View {
    @Binding var selection: Construct?
    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                chip(label: "All", value: nil)
                ForEach(Construct.allCases) { c in
                    chip(label: c.label, value: c)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func chip(label: String, value: Construct?) -> some View {
        let isSelected = (value == selection)
        return Button {
            selection = value
        } label: {
            Text(label)
                .font(.subheadline).bold()
                .padding(.horizontal, Spacing.md)
                .frame(minHeight: 32)
                .background(isSelected ? theme.accentPrimary : theme.surfaceElevated)
                .foregroundStyle(isSelected ? .white : theme.textPrimary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? .clear : theme.strokeSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
