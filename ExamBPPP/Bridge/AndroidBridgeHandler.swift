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
            if (!window.AndroidBridge) {
                window.AndroidBridge = {
                    getAppVersion: function() {
                        return "9.0.0";
                    },
                    isSecureEnvironment: function() {
                        return true;
                    },
                    notifyExamStarted: function() {
                        try {
                            window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                                action: "notifyExamStarted"
                            });
                        } catch (e) {
                            console.error("[ExamBPPP Bridge] notifyExamStarted error:", e);
                        }
                    },
                    notifyExamFinished: function() {
                        try {
                            window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                                action: "notifyExamFinished"
                            });
                        } catch (e) {
                            console.error("[ExamBPPP Bridge] notifyExamFinished error:", e);
                        }
                    },
                    notifyRouteChanged: function(route) {
                        try {
                            window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                                action: "notifyRouteChanged",
                                route: String(route)
                            });
                        } catch (e) {
                            console.error("[ExamBPPP Bridge] notifyRouteChanged error:", e);
                        }
                    },
                    requestNativeExit: function() {
                        try {
                            window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                                action: "requestNativeExit"
                            });
                        } catch (e) {
                            console.error("[ExamBPPP Bridge] requestNativeExit error:", e);
                        }
                    },
                    logNativeEvent: function(tag, event, data) {
                        try {
                            window.webkit.messageHandlers.\(scriptHandlerName).postMessage({
                                action: "logNativeEvent",
                                tag: String(tag),
                                event: String(event),
                                data: String(data)
                            });
                        } catch (e) {
                            console.error("[ExamBPPP Bridge] logNativeEvent error:", e);
                        }
                    }
                };
            }
            
            if (!window.ExamCallback) {
                window.ExamCallback = {};
            }
            
            console.log("[ExamBPPP iOS] AndroidBridge shim successfully initialized.");
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
