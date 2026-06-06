import SwiftUI

/// Five-dot (or N-dot) step indicator. The dot at `current` is filled with
/// the accent color; earlier dots use a muted fill; later dots are stroked
/// outlines. Used by the onboarding flow.
struct ProgressDots: View {
    let total: Int
    let current: Int

    @Environment(\.theme) private var theme

    private let dotSize: CGFloat = 8
    private let spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<max(total, 0), id: \.self) { index in
                Circle()
                    .fill(fillStyle(for: index))
                    .overlay(
                        Circle().stroke(theme.strokeSubtle, lineWidth: index == current ? 0 : 1)
                    )
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(current + 1) of \(total)")
    }

    private func fillStyle(for index: Int) -> Color {
        if index < current { return theme.accentPrimary.opacity(0.4) }
        if index == current { return theme.accentPrimary }
        return theme.surfaceElevated
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressDots(total: 5, current: 0)
        ProgressDots(total: 5, current: 2)
        ProgressDots(total: 5, current: 4)
    }
    .padding()
    .background(ColorTokens.dark.surfaceBase)
}
