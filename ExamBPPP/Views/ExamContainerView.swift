import SwiftUI

struct ExamContainerView: View {
    var onExitExam: () -> Void
    
    @State private var isLoading: Bool = true
    @State private var canGoBack: Bool = false
    @State private var loadError: String? = nil
    @State private var showExitAlert: Bool = false
    @State private var showScreenshotAlert: Bool = false
    @State private var isExamActive: Bool = false
    @State private var currentRoute: String = "/"
    @State private var reloadKey: UUID = UUID()
    
    private let targetURL = URL(string: "https://delivery-mobile.bppp.kemendikdasmen.go.id")!
    @StateObject private var bridgeDelegateHolder = BridgeDelegateHolder()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ExamWebViewRepresentable(
                url: targetURL,
                bridgeHandler: bridgeDelegateHolder.handler,
                isLoading: $isLoading,
                canGoBack: $canGoBack,
                loadError: $loadError
            )
            .id(reloadKey)
            .ignoresSafeArea()
            
            // Loading Overlay
            if isLoading {
                ZStack {
                    Color.white.opacity(0.95)
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0x42/255.0, green: 0x69/255.0, blue: 0x66/255.0)))
                            .scaleEffect(1.4)
                        
                        Text("Memuat Portal Ujian BPPP…")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0x1F/255.0, green: 0x23/255.0, blue: 0x23/255.0))
                    }
                }
                .ignoresSafeArea()
            }
            
            // Network Error Overlay
            if let error = loadError, !isLoading {
                ZStack {
                    Color.white
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0xB3/255.0, green: 0x26/255.0, blue: 0x1E/255.0))
                        
                        Text("Gagal Terhubung ke Server")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0x1F/255.0, green: 0x23/255.0, blue: 0x23/255.0))
                        
                        Text("Periksa koneksi internet Anda dan coba lagi.\n(\(error))")
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0x5F/255.0, green: 0x6B/255.0, blue: 0x69/255.0))
                            .padding(.horizontal, 32)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                reloadKey = UUID()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Muat Ulang")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(red: 0x42/255.0, green: 0x69/255.0, blue: 0x66/255.0))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                onExitExam()
                            }) {
                                Text("Keluar")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0x42/255.0, green: 0x69/255.0, blue: 0x66/255.0), lineWidth: 1.5)
                                    )
                                    .foregroundColor(Color(red: 0x42/255.0, green: 0x69/255.0, blue: 0x66/255.0))
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            bridgeDelegateHolder.onRequestNativeExitCallback = {
                showExitAlert = true
            }
            bridgeDelegateHolder.onExamStartedCallback = {
                isExamActive = true
            }
            bridgeDelegateHolder.onExamFinishedCallback = {
                isExamActive = false
            }
            bridgeDelegateHolder.onRouteChangedCallback = { route in
                currentRoute = route
            }
            
            // Observe screenshots for exam integrity
            NotificationCenter.default.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { _ in
                showScreenshotAlert = true
            }
        }
        .alert(isPresented: $showExitAlert) {
            Alert(
                title: Text("Keluar dari Ujian?"),
                message: Text("Apakah Anda yakin ingin keluar? Pastikan Anda sudah menyelesaikan ujian terlebih dahulu."),
                primaryButton: .destructive(Text("Keluar")) {
                    onExitExam()
                },
                secondaryButton: .cancel(Text("Batal"))
            )
        }
    }
}

final class BridgeDelegateHolder: ObservableObject, ExamBridgeDelegate {
    let handler = AndroidBridgeHandler()
    
    var onExamStartedCallback: (() -> Void)?
    var onExamFinishedCallback: (() -> Void)?
    var onRouteChangedCallback: ((String) -> Void)?
    var onRequestNativeExitCallback: (() -> Void)?
    
    init() {
        handler.delegate = self
    }
    
    func onExamStarted() {
        onExamStartedCallback?()
    }
    
    func onExamFinished() {
        onExamFinishedCallback?()
    }
    
    func onRouteChanged(route: String) {
        onRouteChangedCallback?(route)
    }
    
    func onRequestNativeExit() {
        onRequestNativeExitCallback?()
    }
}
