import Foundation
import AuthenticationServices
import Observation
import Supabase

enum AuthState: Equatable {
    case loading
    case anonymous          // never signed in
    case signedIn(userId: String, email: String?)
    case error(String)
}

@MainActor
@Observable
final class AuthStore {
    var state: AuthState = .loading

    private let client: Supabase.SupabaseClient?

    init(client: Supabase.SupabaseClient? = SupabaseClient.shared) {
        self.client = client
    }

    /// Bootstrap on app launch. Checks for an existing session.
    func bootstrap() async {
        guard let client else {
            state = .anonymous
            return
        }
        do {
            let session = try await client.auth.session
            let user = session.user
            state = .signedIn(userId: user.id.uuidString, email: user.email)
        } catch {
            // No active session — that's fine, user can sign in later.
            state = .anonymous
        }
    }

    /// Sign in with email + password.
    func signInWithEmail(email: String, password: String) async {
        guard let client else {
            state = .error("Supabase not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in Info.plist.")
            return
        }
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            let user = session.user
            state = .signedIn(userId: user.id.uuidString, email: user.email)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Sign up with email + password.
    func signUpWithEmail(email: String, password: String) async {
        guard let client else {
            state = .error("Supabase not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in Info.plist.")
            return
        }
        do {
            // signUp returns AuthResponse (session may be nil until email is confirmed).
            let response = try await client.auth.signUp(email: email, password: password)
            let user = response.user
            if response.session != nil {
                state = .signedIn(userId: user.id.uuidString, email: user.email)
            } else {
                // No session yet — email confirmation is likely required.
                state = .error("Check your email to confirm your account, then sign in.")
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Sign in with Apple. The `SignInWithAppleCredential` is sent to Supabase
    /// which exchanges it for a session. See:
    /// https://supabase.com/docs/guides/auth/social-login/auth-apple
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        guard let client else {
            state = .error("Supabase not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in Info.plist.")
            return
        }
        guard let idTokenData = credential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8) else {
            state = .error("Apple Sign In: missing identity token")
            return
        }
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: Supabase.OpenIDConnectCredentials(provider: .apple, idToken: idToken)
            )
            let user = session.user
            state = .signedIn(userId: user.id.uuidString, email: user.email ?? credential.email)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Sign out the current user. Local state resets to anonymous.
    func signOut() async {
        if let client {
            try? await client.auth.signOut()
        }
        state = .anonymous
    }
}
