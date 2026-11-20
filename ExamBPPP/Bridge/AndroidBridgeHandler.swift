import Foundation
import WebKit

protocol ExamBridgeDelegate: AnyObject {
    func onExamStarted()
    func onExamFinished()
    func onRouteChanged(route: String)
    func onRequestNativeExit()
}

final class AndroidBridgeHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: ExamBridgeDelegate?
    
    static let scriptHandlerName = "AndroidBridgeNative"
    
    static var injectionScript: String {
        return """
        (function() {
            if (window.AndroidBridge) return;
            
            window.AndroidBridge = {
                getAppVersion: function() {
                    return "9.0.0";
                },
                isSecureEnvironment: function() {
                    return true;
                },
                notifyExamStarted: function() {
                    window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                        action: "notifyExamStarted"
                    });
                },
                notifyExamFinished: function() {
                    window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                        action: "notifyExamFinished"
                    });
                },
                notifyRouteChanged: function(route) {
                    window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                        action: "notifyRouteChanged",
                        route: route
                    });
                },
                requestNativeExit: function() {
                    window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                        action: "requestNativeExit"
                    });
                },
                logNativeEvent: function(tag, event, data) {
                    window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                        action: "logNativeEvent",
                        tag: tag,
                        event: event,
                        data: data
                    });
                }
            };
            
            console.log("[ExamBPPP iOS] AndroidBridge shim successfully injected.");
        })();
        """
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == AndroidBridgeHandler.scriptHandlerName,
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            switch action {
            case "notifyExamStarted":
                self?.delegate?.onExamStarted()
            case "notifyExamFinished":
                self?.delegate?.onExamFinished()
            case "notifyRouteChanged":
                if let route = body["route"] as? String {
                    self?.delegate?.onRouteChanged(route: route)
                }
            case "requestNativeExit":
                self?.delegate?.onRequestNativeExit()
            case "logNativeEvent":
                let tag = body["tag"] as? String ?? ""
                let event = body["event"] as? String ?? ""
                print("[ExamBPPP Native Log] [\(tag)] \(event)")
            default:
                break
            }
        }
    }
}
