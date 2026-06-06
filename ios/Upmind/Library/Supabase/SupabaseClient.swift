import Foundation
import Supabase

/// Singleton wrapper over the Supabase Swift SDK. If `AppSecrets.hasSupabaseConfig`
/// is false, the client is nil and any auth call returns a clear error.
enum SupabaseClient {
    static let shared: Supabase.SupabaseClient? = {
        guard AppSecrets.hasSupabaseConfig,
              let url = URL(string: AppSecrets.supabaseURLString) else {
            return nil
        }
        return Supabase.SupabaseClient(
            supabaseURL: url,
            supabaseKey: AppSecrets.supabaseAnonKey,
            options: SupabaseClientOptions()
        )
    }()
}
