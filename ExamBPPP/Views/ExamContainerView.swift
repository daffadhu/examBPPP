import SwiftUI

struct ExamContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLoading: Bool = true
    @State private var canGoBack: Bool = false
    @State private var showExitAlert: Bool = false
    @State private var isExamActive: Bool = false
    @State private var currentRoute: String = "/"
    
    private let targetURL = URL(string: "https://delivery-mobile.bppp.kemendikdasmen.go.id")!
    @StateObject private var bridgeDelegateHolder = BridgeDelegateHolder()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ExamWebViewRepresentable(
                url: targetURL,
                bridgeHandler: bridgeDelegateHolder.handler,
                isLoading: $isLoading,
                canGoBack: $canGoBack
            )
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Loading Overlay
            if isLoading {
                ZStack {
                    Color(UIColor.systemBackground).opacity(0.85)
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Memuat Portal Ujian BPPP...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            bridgeDelegateHolder.onExitRequested = {
                showExitAlert = true
            }
            bridgeDelegateHolder.onExamStarted = {
                isExamActive = true
            }
            bridgeDelegateHolder.onExamFinished = {
                isExamActive = false
            }
            bridgeDelegateHolder.onRouteChanged = { route in
                currentRoute = route
            }
        }
        .alert(isPresented: $showExitAlert) {
            Alert(
                title: Text("Konfirmasi Keluar"),
                message: Text("Apakah Anda yakin ingin keluar dari aplikasi ujian?"),
                primaryButton: .destructive(Text("Keluar")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Lanjutkan Ujian"))
            )
        }
    }
}

final class BridgeDelegateHolder: ObservableObject, ExamBridgeDelegate {
    let handler = AndroidBridgeHandler()
    
    var onExamStarted: (() -> Void)?
    var onExamFinished: (() -> Void)?
    var onRouteChanged: ((String) -> Void)?
    var onRequestNativeExit: (() -> Void)?
    var onExitRequested: (() -> Void)?
    
    init() {
        handler.delegate = self
    }
    
    func onExamStarted() {
        onExamStarted?()
    }
    
    func onExamFinished() {
        onExamFinished?()
    }
    
    func onRouteChanged(route: String) {
        onRouteChanged?(route)
    }
    
    func onRequestNativeExit() {
        onExitRequested?()
    }
}
