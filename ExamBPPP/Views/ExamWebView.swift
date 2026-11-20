import SwiftUI
import WebKit

struct ExamWebViewRepresentable: UIViewRepresentable {
    let url: URL
    let bridgeHandler: AndroidBridgeHandler
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var loadError: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            config.preferences.javaScriptEnabled = true
        }
        
        // 1. Inject AndroidBridge JavaScript shim at document start
        let userScript = WKUserScript(
            source: AndroidBridgeHandler.injectionScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(userScript)
        
        // 2. Register native script message handler safely
        config.userContentController.removeScriptMessageHandler(forName: AndroidBridgeHandler.scriptHandlerName)
        config.userContentController.add(bridgeHandler, name: AndroidBridgeHandler.scriptHandlerName)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        // 3. Set Custom User-Agent with the mandatory secret token expected by server
        let baseUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
        webView.customUserAgent = "\(baseUA) JSB8123BKDSB9239BJBJDS89JNSDKK17"
        
        // 4. Load Target URL
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // State updates if required
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: ExamWebViewRepresentable
        
        private let allowedHosts = [
            "delivery-mobile.bppp.kemendikdasmen.go.id",
            "delivery-abm.bppp.kemendikdasmen.go.id",
            "pengawas-ujian.bppp.kemendikdasmen.go.id",
            "storage.googleapis.com",
            "fcm.googleapis.com",
            "firebaseinstallations.googleapis.com"
        ]
        
        init(_ parent: ExamWebViewRepresentable) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let host = navigationAction.request.url?.host?.lowercased() else {
                decisionHandler(.cancel)
                return
            }
            
            let isAllowed = allowedHosts.contains { domain in
                host == domain || host.hasSuffix("." + domain)
            }
            
            if isAllowed {
                decisionHandler(.allow)
            } else {
                print("[ExamBPPP iOS] Blocked navigation to outside domain: \(host)")
                decisionHandler(.cancel)
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.loadError = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            
            // Ensure window.ExamCallback namespace exists on page finish
            webView.evaluateJavaScript("if (!window.ExamCallback) { window.ExamCallback = {}; }", completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = error.localizedDescription
        }
        
        // MARK: - WKUIDelegate (Camera WebRTC Permission for iOS 15+)
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            // Auto grant camera / proctoring media stream for the exam
            decisionHandler(.grant)
        }
        
        // Alert dialog handler from JS
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: "ExamBPPP", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            presentAlert(alert, fallback: completionHandler)
        }
        
        // Confirm dialog handler from JS
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: "ExamBPPP", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            alert.addAction(UIAlertAction(title: "Batal", style: .cancel) { _ in
                completionHandler(false)
            })
            presentAlert(alert, fallback: { completionHandler(false) })
        }
        
        private func presentAlert(_ alert: UIAlertController, fallback: @escaping () -> Void) {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
            
            guard let keyWindow = scenes.first?.windows.first(where: { $0.isKeyWindow }),
                  let rootVC = keyWindow.rootViewController else {
                fallback()
                return
            }
            
            var presenter = rootVC
            while let presented = presenter.presentedViewController {
                presenter = presented
            }
            presenter.present(alert, animated: true)
        }
    }
}
