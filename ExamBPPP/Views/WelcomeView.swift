import SwiftUI

struct WelcomeView: View {
    @StateObject private var checkManager = DeviceCheckManager()
    @State private var navigateToExam: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Card
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                            .padding(.top, 16)
                        
                        Text("ExamBPPP Mobile")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Pemeriksaan Kesiapan Perangkat Ujian")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    
                    // Device Checks List
                    List {
                        Section(header: Text("Status Pemeriksaan").font(.caption)) {
                            ForEach(checkManager.items) { item in
                                DeviceCheckRow(item: item)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    // Action Button Container
                    VStack(spacing: 12) {
                        if checkManager.isAllPassed {
                            Button(action: {
                                navigateToExam = true
                            }) {
                                HStack {
                                    Text("Buka Portal Ujian")
                                        .font(.headline)
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        } else {
                            Button(action: {
                                checkManager.runAllChecks()
                            }) {
                                HStack {
                                    if checkManager.isChecking {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 8)
                                    }
                                    Text(checkManager.isChecking ? "Sedang Memeriksa..." : "Periksa Ulang")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(checkManager.isChecking ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(checkManager.isChecking)
                        }
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                }
                
                // Fullscreen Cover to Exam Screen
                NavigationLink(
                    destination: ExamContainerView(),
                    isActive: $navigateToExam
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
            .onAppear {
                checkManager.runAllChecks()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DeviceCheckRow: View {
    let item: DeviceCheckItem
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            iconForId(item.id)
                .frame(width: 32, height: 32)
                .foregroundColor(.blue)
            
            // Texts
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                
                switch item.status {
                case .pending:
                    Text(item.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                case .checking:
                    Text("Memeriksa...")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                case .success(let detail):
                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                case .warning(let detail):
                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                case .failed(let detail):
                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            // Status Indicator
            switch item.status {
            case .pending, .checking:
                ProgressView()
                    .scaleEffect(0.8)
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 20))
            case .warning:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))
            case .failed:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func iconForId(_ id: String) -> some View {
        switch id {
        case "camera":
            Image(systemName: "camera.fill")
        case "network":
            Image(systemName: "wifi")
        case "os":
            Image(systemName: "applelogo")
        case "security":
            Image(systemName: "lock.shield.fill")
        case "call":
            Image(systemName: "phone.down.fill")
        default:
            Image(systemName: "gear")
        }
    }
}
