import Foundation

/// Reads the SerpApi key injected into Info.plist at build time via
/// `Config/Config.xcconfig` (`SERPAPI_API_KEY`), which in turn picks it up
/// from a gitignored `Config/Secrets.xcconfig` — the key itself is never
/// hardcoded or committed.
enum APIConfig {
    static var serpApiKey: String? {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "SERPAPI_API_KEY") as? String,
            !key.isEmpty
        else {
            return nil
        }
        return key
    }
}
