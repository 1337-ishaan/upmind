import Foundation
import Observation

@MainActor
@Observable
final class SignUpViewModel {
    var email: String = ""
    var password: String = ""
    var busy: Bool = false

    let authStore: AuthStore

    init(authStore: AuthStore) {
        self.authStore = authStore
    }

    func signUp() async {
        busy = true
        defer { busy = false }
        await authStore.signUpWithEmail(email: email, password: password)
        if case .signedIn = authStore.state {
            PostHogManager.shared.track(.authCompleted(method: "email", isNewUser: true))
        }
    }
}
