import Foundation
import AVFoundation
import UIKit

enum CheckStatus: Equatable {
    case loading
    case pass(displayValue: String)
    case fail(displayValue: String)
}

struct DeviceCheckItem: Identifiable {
    let id: String
    let label: String
    let description: String
    var status: CheckStatus = .loading
    var displayValue: String = "Memeriksa…"
}

enum SummaryState {
    case loading
    case allPass
    case someFail
}

final class DeviceCheckManager: ObservableObject {
    @Published var items: [DeviceCheckItem] = []
    @Published var summaryState: SummaryState = .loading
    @Published var isChecking: Bool = false
    @Published var showCameraPermissionAlert: Bool = false
    
    init() {
        resetItems()
    }
    
    func resetItems() {
        items = [
            DeviceCheckItem(
                id: "camera",
                label: "Kamera",
                description: "Kamera diperlukan untuk verifikasi identitas peserta ujian.",
                status: .loading,
                displayValue: "Memeriksa…"
            ),
            DeviceCheckItem(
                id: "network",
                label: "Internet",
                description: "Koneksi internet harus memadai untuk memuat soal ujian.",
                status: .loading,
                displayValue: "Memeriksa…"
            ),
            DeviceCheckItem(
                id: "os",
                label: "Versi sistem",
                description: "Aplikasi memerlukan iOS 15.0 atau lebih baru.",
                status: .loading,
                displayValue: "Memeriksa…"
            ),
            DeviceCheckItem(
                id: "security",
                label: "Keamanan perangkat",
                description: "Perangkat tidak boleh di-jailbreak, dan layar harus terlindungi.",
                status: .loading,
                displayValue: "Memeriksa…"
            ),
            DeviceCheckItem(
                id: "call",
                label: "Telepon",
                description: "Harap akhiri semua panggilan aktif sebelum memulai ujian.",
                status: .loading,
                displayValue: "Memeriksa…"
            )
        ]
        summaryState = .loading
    }
    
    func runAllChecks() {
        isChecking = true
        resetItems()
        
        // Add a smooth visual delay like Android's lifecycleScope delay(300)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // 1. OS Check
            self.checkOS()
            
            // 2. Security Check
            self.checkSecurity()
            
            // 3. Active Call Check
            self.checkActiveCall()
            
            // 4. Network Check
            self.checkNetwork()
            
            // 5. Camera Check
            self.checkCamera()
        }
    }
    
    private func updateItem(id: String, status: CheckStatus, displayValue: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.items.firstIndex(where: { $0.id == id }) {
                self.items[index].status = status
                self.items[index].displayValue = displayValue
            }
            self.evaluateSummary()
        }
    }
    
    private func evaluateSummary() {
        let hasLoading = items.contains { item in
            if case .loading = item.status { return true }
            return false
        }
        
        if hasLoading {
            summaryState = .loading
            isChecking = true
            return
        }
        
        isChecking = false
        let hasFail = items.contains { item in
            if case .fail = item.status { return true }
            return false
        }
        
        if hasFail {
            summaryState = .someFail
        } else {
            summaryState = .allPass
        }
    }
    
    // MARK: - Individual Checks
    
    private func checkOS() {
        let systemVersion = UIDevice.current.systemVersion
        let majorVersion = Int(systemVersion.split(separator: ".").first ?? "15") ?? 15
        if majorVersion >= 15 {
            updateItem(id: "os", status: .pass(displayValue: "iOS \(systemVersion), sudah memenuhi (min. iOS 15)"), displayValue: "iOS \(systemVersion), sudah memenuhi (min. iOS 15)")
        } else {
            updateItem(id: "os", status: .fail(displayValue: "iOS versi lama (min. iOS 15)"), displayValue: "iOS versi lama (min. iOS 15)")
        }
    }
    
    private func checkSecurity() {
        // Safe check without false positives on testing devices
        let isJailbroken = checkJailbreak()
        if !isJailbroken {
            updateItem(id: "security", status: .pass(displayValue: "Aman untuk tes"), displayValue: "Aman untuk tes")
        } else {
            updateItem(id: "security", status: .fail(displayValue: "Terdeteksi jailbreak atau modifikasi"), displayValue: "Terdeteksi jailbreak atau modifikasi")
        }
    }
    
    private func checkJailbreak() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
        #endif
    }
    
    private func checkActiveCall() {
        // Standard iOS check for active audio calls
        let isAudioPlaying = AVAudioSession.sharedInstance().isOtherAudioPlaying
        let category = AVAudioSession.sharedInstance().category
        let mode = AVAudioSession.sharedInstance().mode
        
        let isCallActive = category == .playAndRecord && mode == .voiceChat
        if !isCallActive {
            updateItem(id: "call", status: .pass(displayValue: "Tidak ada panggilan aktif"), displayValue: "Tidak ada panggilan aktif")
        } else {
            updateItem(id: "call", status: .fail(displayValue: "Panggilan telepon sedang aktif"), displayValue: "Panggilan telepon sedang aktif")
        }
    }
    
    private func checkNetwork() {
        guard let url = URL(string: "https://delivery-mobile.bppp.kemendikdasmen.go.id") else {
            updateItem(id: "network", status: .fail(displayValue: "Koneksi terputus atau timeout"), displayValue: "Koneksi terputus atau timeout")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3.5
        
        let start = Date()
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
            
            if let httpResp = response as? HTTPURLResponse, (200...403).contains(httpResp.statusCode) {
                if elapsedMs > 2500 {
                    self?.updateItem(id: "network", status: .pass(displayValue: "Koneksi lambat (\(elapsedMs) ms)"), displayValue: "Koneksi lambat (\(elapsedMs) ms)")
                } else {
                    self?.updateItem(id: "network", status: .pass(displayValue: "Koneksi stabil"), displayValue: "Koneksi stabil")
                }
            } else if error != nil {
                // Secondary fallback attempt: check general internet via Apple captive portal
                self?.verifyFallbackInternet()
            } else {
                self?.updateItem(id: "network", status: .pass(displayValue: "Koneksi stabil"), displayValue: "Koneksi stabil")
            }
        }.resume()
    }
    
    private func verifyFallbackInternet() {
        guard let url = URL(string: "https://captive.apple.com/hotspot-detect.html") else {
            updateItem(id: "network", status: .fail(displayValue: "Koneksi terputus atau timeout"), displayValue: "Koneksi terputus atau timeout")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 2.0
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            if error == nil, let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 {
                self?.updateItem(id: "network", status: .pass(displayValue: "Koneksi stabil"), displayValue: "Koneksi stabil")
            } else {
                self?.updateItem(id: "network", status: .fail(displayValue: "Koneksi terputus atau timeout"), displayValue: "Koneksi terputus atau timeout")
            }
        }.resume()
    }
    
    private func checkCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            updateItem(id: "camera", status: .pass(displayValue: "Kamera siap digunakan"), displayValue: "Kamera siap digunakan")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.updateItem(id: "camera", status: .pass(displayValue: "Kamera siap digunakan"), displayValue: "Kamera siap digunakan")
                    } else {
                        self?.updateItem(id: "camera", status: .fail(displayValue: "Kamera tidak bisa dipakai"), displayValue: "Kamera tidak bisa dipakai")
                        self?.showCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            updateItem(id: "camera", status: .fail(displayValue: "Kamera tidak bisa dipakai"), displayValue: "Kamera tidak bisa dipakai")
            showCameraPermissionAlert = true
        @unknown default:
            updateItem(id: "camera", status: .fail(displayValue: "Kamera tidak bisa dipakai"), displayValue: "Kamera tidak bisa dipakai")
        }
    }
}
