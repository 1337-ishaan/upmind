import Foundation

/// Centralized access to build-time secrets. Values are read from
/// `Info.plist` (which gets them from `.xcconfig` / build settings).
/// Placeholders like `$(SUPABASE_URL)` are detected and treated as
/// "not configured" so the app still runs during development.
enum AppSecrets {
    static let supabaseURLString: String = {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
              !s.isEmpty, s != "$(SUPABASE_URL)" else {
            return ""
        }
        return s
    }()

    static let supabaseAnonKey: String = {
        guard let k = Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String,
              !k.isEmpty, k != "$(SUPABASE_ANON_KEY)" else {
            return ""
        }
        return k
    }()

    static var hasSupabaseConfig: Bool {
        !supabaseURLString.isEmpty && !supabaseAnonKey.isEmpty
    }
}
