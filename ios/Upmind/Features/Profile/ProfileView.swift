import SwiftUI

struct ProfileView: View {
    @State private var vm: ProfileViewModel
    @State private var showSignIn: Bool = false
    @State private var showPaywall: Bool = false
    @Environment(\.theme) private var theme

    init(authStore: AuthStore, syncWorker: SyncWorker) {
        _vm = State(wrappedValue: ProfileViewModel(authStore: authStore, syncWorker: syncWorker))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    identityCard
                    if !vm.email.isEmpty {
                        syncCard
                    }
                    premiumCard
                    actionsCard
                    Spacer().frame(height: Spacing.xl)
                }
                .padding(Spacing.lg)
            }
            .background(theme.surfaceBase)
            .navigationTitle("Profile")
            .onAppear { vm.refresh() }
            .sheet(isPresented: $showSignIn) {
                SignInView(authStore: vm.authStore)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onPurchased: { showPaywall = false; vm.refresh() })
            }
        }
    }

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(theme.accentPrimary.opacity(0.2))
                        .frame(width: 64, height: 64)
                    Text(initials(from: vm.email))
                        .font(.title2).bold()
                        .foregroundStyle(theme.accentPrimary)
                }
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(vm.email.isEmpty ? "Anonymous" : vm.email)
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text(vm.isPremium ? "Premium" : "Free tier")
                        .font(.subheadline)
                        .foregroundStyle(vm.isPremium ? theme.accentPrimary : theme.textSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private var syncCard: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: vm.lastSyncError == nil ? "checkmark.circle" : "exclamationmark.triangle")
                .foregroundStyle(vm.lastSyncError == nil ? theme.success : theme.warning)
            VStack(alignment: .leading) {
                Text(vm.lastSyncError == nil ? "All sessions synced" : "Sync issue")
                    .font(.subheadline)
                    .foregroundStyle(theme.textPrimary)
                if vm.pendingSyncCount > 0 {
                    Text("\(vm.pendingSyncCount) pending")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private var premiumCard: some View {
        Button {
            if vm.isPremium { return }
            showPaywall = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(vm.isPremium ? "Upmind Premium" : "Upgrade to Premium")
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text(vm.isPremium ? "All 42 games unlocked" : "Unlock 5 Executive games")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                if !vm.isPremium {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .padding(Spacing.lg)
            .background(theme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
    }

    private var actionsCard: some View {
        VStack(spacing: Spacing.sm) {
            if vm.email.isEmpty {
                Button {
                    showSignIn = true
                } label: {
                    Text("Sign in")
                        .font(.body).bold()
                        .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                        .background(theme.accentPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
            } else {
                Button(role: .destructive) {
                    Task { await vm.signOut() }
                } label: {
                    Text("Sign out")
                        .font(.body)
                        .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                        .foregroundStyle(theme.error)
                }
            }
            NavigationLink {
                NotificationsSettingsView()
            } label: {
                HStack {
                    Text("Notifications").foregroundStyle(theme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(theme.textSecondary)
                }
                .padding(Spacing.lg)
                .background(theme.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
        }
    }

    private func initials(from email: String) -> String {
        guard !email.isEmpty else { return "?" }
        return String(email.first!).uppercased()
    }
}
