import SwiftUI

struct NotificationsSettingsView: View {
    @State private var service: NotificationCenterService
    @State private var showPrePrompt: Bool = false
    @Environment(\.theme) private var theme

    init() {
        _service = State(wrappedValue: NotificationCenterService())
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            permissionCard
            togglesCard
            pauseCard
            Spacer()
        }
        .padding(Spacing.lg)
        .background(theme.surfaceBase)
        .navigationTitle("Notifications")
        .task { await service.refreshPermissionState() }
        .alert("Get reminders?", isPresented: $showPrePrompt) {
            Button("Allow") {
                Task {
                    _ = await service.requestPermission()
                    await service.rescheduleAll()
                }
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("We'll send a few helpful reminders so you don't miss your daily drill. You can change this anytime.")
        }
    }

    private var permissionCard: some View {
        HStack {
            Image(systemName: permissionIcon)
                .foregroundStyle(permissionColor)
                .font(.title2)
            VStack(alignment: .leading) {
                Text(permissionTitle)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text(permissionSubtitle)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            if service.permissionState == .notDetermined {
                Button("Enable") { showPrePrompt = true }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.accentPrimary)
            }
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private var togglesCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ForEach(NotificationCategory.allCases) { category in
                Toggle(isOn: Binding(
                    get: { service.categoryOptIn[category] ?? category.defaultOptIn },
                    set: { service.categoryOptIn[category] = $0; Task { await service.rescheduleAll() } }
                )) {
                    VStack(alignment: .leading) {
                        Text(category.userFacingTitle)
                            .font(.subheadline).bold()
                            .foregroundStyle(theme.textPrimary)
                        Text(category.userFacingSubtitle)
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                .disabled(service.permissionState == .notDetermined || service.permissionState == .denied)
            }
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private var pauseCard: some View {
        Button {
            service.pauseAllFor24Hours()
        } label: {
            Text("Pause all for 24 hours")
                .font(.body)
                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                .foregroundStyle(theme.textSecondary)
        }
    }

    private var permissionIcon: String {
        switch service.permissionState {
        case .granted, .provisional: return "bell.fill"
        case .denied, .ephemeral: return "bell.slash.fill"
        case .notDetermined: return "bell"
        }
    }
    private var permissionColor: Color {
        switch service.permissionState {
        case .granted, .provisional: return theme.accentPrimary
        case .denied, .ephemeral: return theme.error
        case .notDetermined: return theme.textSecondary
        }
    }
    private var permissionTitle: String {
        switch service.permissionState {
        case .granted, .provisional: return "Notifications enabled"
        case .denied, .ephemeral: return "Notifications blocked"
        case .notDetermined: return "Notifications are off"
        }
    }
    private var permissionSubtitle: String {
        switch service.permissionState {
        case .granted, .provisional: return "Choose which reminders you'd like."
        case .denied, .ephemeral: return "Enable in iOS Settings → Upmind."
        case .notDetermined: return "Turn on to get daily reminders and streak alerts."
        }
    }
}
