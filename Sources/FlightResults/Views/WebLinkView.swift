import SwiftUI
import WebKit

/// Wraps a plain `WKWebView`, not `SFSafariViewController` — Safari's view
/// controller is built for modal presentation (its own toolbar/"Done"
/// button) and looks wrong pushed onto a stack that already supplies a
/// back button from `NavigationStack`.
struct WebLinkView: View {
    let url: URL

    var body: some View {
        WebViewRepresentable(url: url)
            .navigationTitle(url.host ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
