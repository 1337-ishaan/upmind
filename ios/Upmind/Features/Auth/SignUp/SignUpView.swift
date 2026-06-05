import SwiftUI

struct SignUpView: View {
    @State private var vm: SignUpViewModel
    let authStore: AuthStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    init(authStore: AuthStore) {
        self.authStore = authStore
        _vm = State(wrappedValue: SignUpViewModel(authStore: authStore))
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer().frame(height: Spacing.xxl)
            Text("Create your account")
                .font(.largeTitle).bold()
                .foregroundStyle(theme.textPrimary)
            VStack(spacing: Spacing.sm) {
                TextField("Email", text: $vm.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password (min 8 chars)", text: $vm.password)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task {
                        await vm.signUp()
                        if case .signedIn = authStore.state { dismiss() }
                    }
                } label: {
                    Text("Create account")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                        .background(theme.accentPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
                .disabled(vm.busy || vm.password.count < 8)
            }
            .padding(.horizontal, Spacing.lg)
            if case .error(let message) = authStore.state {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(theme.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            Spacer()
        }
        .background(theme.surfaceBase)
    }
}
