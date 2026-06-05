import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var vm: SignInViewModel
    let authStore: AuthStore
    @Environment(\.theme) private var theme

    init(authStore: AuthStore) {
        self.authStore = authStore
        _vm = State(wrappedValue: SignInViewModel(authStore: authStore))
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer().frame(height: Spacing.xxl)
            Text("Welcome back")
                .font(.largeTitle).bold()
                .foregroundStyle(theme.textPrimary)
            Text("Sign in to keep your training streak")
                .font(.body)
                .foregroundStyle(theme.textSecondary)

            VStack(spacing: Spacing.sm) {
                TextField("Email", text: $vm.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $vm.password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await vm.signInWithEmail() }
                } label: {
                    Text("Sign in")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                        .background(theme.accentPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
                .disabled(vm.busy)
            }
            .padding(.horizontal, Spacing.lg)

            HStack {
                Rectangle().fill(theme.strokeSubtle).frame(height: 1)
                Text("or").foregroundStyle(theme.textSecondary).padding(.horizontal, Spacing.xs)
                Rectangle().fill(theme.strokeSubtle).frame(height: 1)
            }
            .padding(.horizontal, Spacing.lg)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                if case .success(let auth) = result, let cred = auth.credential as? ASAuthorizationAppleIDCredential {
                    Task { await vm.signInWithApple(credential: cred) }
                }
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: MinTapTarget.size)
            .padding(.horizontal, Spacing.lg)

            if case .error(let message) = authStore.state {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(theme.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            Spacer()

            Button("Create account") { vm.showSignUp = true }
                .foregroundStyle(theme.accentPrimary)
        }
        .background(theme.surfaceBase)
        .sheet(isPresented: $vm.showSignUp) {
            SignUpView(authStore: vm.authStore)
        }
        .padding(.vertical, Spacing.lg)
    }
}
