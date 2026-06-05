import SwiftUI

struct PaywallView: View {
    @State private var vm: PaywallViewModel
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    let onPurchased: () -> Void

    init(onPurchased: @escaping () -> Void, manager: RevenueCatManager = .shared) {
        _vm = State(wrappedValue: PaywallViewModel(manager: manager))
        self.onPurchased = onPurchased
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.surfaceBase, theme.accentPrimary.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Spacer().frame(height: Spacing.xl)
                Text("Train your mind.")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text("42 games across 7 cognitive skills. Premium unlocks Executive Function and unlimited history.")
                    .font(.body)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)

                VStack(spacing: Spacing.sm) {
                    ForEach(PremiumPlan.allCases) { plan in
                        planCard(plan)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                Button {
                    Task { await buy() }
                } label: {
                    Text(vm.isPurchasing ? "Processing…" : "Start Premium")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                        .background(theme.accentPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
                .disabled(vm.isPurchasing)
                .padding(.horizontal, Spacing.lg)

                Button("Restore purchases") {
                    Task { await vm.restore() }
                }
                .foregroundStyle(theme.textSecondary)

                if let error = vm.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(theme.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }

                Button("Not now") { dismiss() }
                    .foregroundStyle(theme.textSecondary)
                    .padding(.top, Spacing.sm)

                Spacer()
            }
            .padding(.vertical, Spacing.lg)
        }
    }

    private func planCard(_ plan: PremiumPlan) -> some View {
        let isSelected = vm.selectedPlan == plan
        return Button {
            vm.selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(plan.rawValue.capitalized)
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text(plan.displayPrice)
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                if let badge = plan.discountBadge {
                    Text(badge)
                        .font(.caption2).bold()
                        .padding(.horizontal, Spacing.xs).padding(.vertical, 2)
                        .background(theme.accentPrimary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accentPrimary : theme.strokeSubtle)
            }
            .padding(Spacing.md)
            .background(theme.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(isSelected ? theme.accentPrimary : theme.strokeSubtle, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
    }

    private func buy() async {
        let success = await vm.purchase()
        if success { onPurchased(); dismiss() }
    }
}
