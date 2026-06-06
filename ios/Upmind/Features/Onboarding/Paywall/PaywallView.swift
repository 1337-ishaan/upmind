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
            GradientTokens.hero.ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Spacer().frame(height: Spacing.xl)
                HeroText("Train your mind.")
                SubtitleText(
                    "42 games across 7 cognitive skills. Premium unlocks Executive Function and unlimited history."
                )
                .padding(.horizontal, Spacing.lg)

                HStack(spacing: Spacing.md) {
                    featureBadge("5", "Executive games")
                    featureBadge("∞", "Unlimited history")
                    featureBadge("🔥", "Streak protection")
                }
                .padding(.horizontal, Spacing.lg)

                VStack(spacing: Spacing.sm) {
                    ForEach(PremiumPlan.allCases) { plan in
                        planCard(plan)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xs)

                PrimaryButton(
                    vm.isPurchasing ? "Processing…" : "Start Premium",
                    icon: vm.isPurchasing ? nil : "crown.fill",
                    style: .gradient
                ) {
                    Task { await buy() }
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
                    .padding(.top, Spacing.xs)

                Spacer()
            }
            .padding(.vertical, Spacing.lg)
        }
    }

    @ViewBuilder
    private func featureBadge(_ value: String, _ label: String) -> some View {
        VStack(spacing: Spacing.xxs) {
            Text(value)
                .font(.title3).bold()
                .foregroundStyle(theme.accentPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.xs)
        .background(theme.surfaceElevated.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(theme.strokeSubtle.opacity(0.5), lineWidth: 1)
        )
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
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(GradientTokens.proAccent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accentPrimary : theme.strokeSubtle)
            }
            .padding(Spacing.md)
            .background(theme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(
                        isSelected
                            ? theme.accentPrimary
                            : theme.strokeSubtle.opacity(0.5),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func buy() async {
        let success = await vm.purchase()
        if success { onPurchased(); dismiss() }
    }
}
