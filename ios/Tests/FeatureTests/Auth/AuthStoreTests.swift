import XCTest
@testable import Upmind

@MainActor
final class AuthStoreTests: XCTestCase {

    func testBootstrapWithNoConfigGoesAnonymous() async {
        let store = AuthStore(client: nil)
        await store.bootstrap()
        XCTAssertEqual(store.state, .anonymous)
    }

    func testSignOutResetsToAnonymous() async {
        let store = AuthStore(client: nil)
        await store.bootstrap()
        await store.signOut()
        XCTAssertEqual(store.state, .anonymous)
    }

    func testSignInWithEmailWithNoConfigSurfacesError() async {
        let store = AuthStore(client: nil)
        await store.signInWithEmail(email: "user@example.com", password: "password123")
        if case .error(let message) = store.state {
            XCTAssertTrue(message.contains("Supabase"),
                          "Error message should mention Supabase config; got: \(message)")
        } else {
            XCTFail("Expected .error state, got \(store.state)")
        }
    }

    func testAppSecretsReadEmptyWhenNotConfigured() {
        XCTAssertFalse(AppSecrets.hasSupabaseConfig,
                       "hasSupabaseConfig should be false when Info.plist placeholders are empty")
    }
}
