import Foundation
import Observation
import AuthenticationServices

@MainActor
@Observable
final class SignInViewModel {
    var email: String = ""
    var password: String = ""
    var showSignUp: Bool = false
    var busy: Bool = false

    let authStore: AuthStore

    init(authStore: AuthStore) {
        self.authStore = authStore
    }

    func signInWithEmail() async {
        busy = true
        defer { busy = false }
        await authStore.signInWithEmail(email: email, password: password)
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        busy = true
        defer { busy = false }
        await authStore.signInWithApple(credential: credential)
    }
}
