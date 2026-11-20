import SwiftUI

struct AppColors {
    static let primary = Color(red: 0x42/255.0, green: 0x69/255.0, blue: 0x66/255.0) // #426966
    static let primaryDisabled = Color(red: 0xD3/255.0, green: 0xDF/255.0, blue: 0xDD/255.0) // #D3DFDD
    static let textPrimary = Color(red: 0x1F/255.0, green: 0x23/255.0, blue: 0x23/255.0) // #1F2323
    static let textSecondary = Color(red: 0x5F/255.0, green: 0x6B/255.0, blue: 0x69/255.0) // #5F6B69
    static let border = Color(red: 0xDC/255.0, green: 0xE3/255.0, blue: 0xE2/255.0) // #DCE3E2
    static let iconTileBg = Color(red: 0xE6/255.0, green: 0xF0/255.0, blue: 0xEF/255.0) // #E6F0EF
    static let bannerLoadingBg = Color(red: 0xF3/255.0, green: 0xF6/255.0, blue: 0xF6/255.0) // #F3F6F6
    static let bannerPassBg = Color(red: 0xEB/255.0, green: 0xF1/255.0, blue: 0xF1/255.0) // #EBF1F1
    static let bannerFailBg = Color(red: 0xFD/255.0, green: 0xEC/255.0, blue: 0xEA/255.0) // #FDECEA
    static let pillPassBg = Color(red: 0xE5/255.0, green: 0xEF/255.0, blue: 0xE8/255.0) // #E5EFE8
    static let pillPassText = Color(red: 0x3E/255.0, green: 0x6B/255.0, blue: 0x52/255.0) // #3E6B52
    static let pillFailBg = Color(red: 0xFD/255.0, green: 0xEC/255.0, blue: 0xEA/255.0) // #FDECEA
    static let failText = Color(red: 0xB3/255.0, green: 0x26/255.0, blue: 0x1E/255.0) // #B3261E
    static let textHint = Color(red: 0xAA/255.0, green: 0xBF/255.0, blue: 0xBF/255.0) // #AABFBF
}

struct WelcomeView: View {
    var onStartExam: () -> Void
    
    @StateObject private var checkManager = DeviceCheckManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    // App Round Logo
                    if let imagePath = Bundle.main.path(forResource: "exambppp_round", ofType: "png"),
                       let uiImage = UIImage(contentsOfFile: imagePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        // Fallback App Icon
                        ZStack {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 40, height: 40)
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ExamBPPP")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("SAFE EXAM BROWSER")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                    .background(AppColors.border)
            }
            .background(Color.white)
            
            // MARK: - Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Graphic Illustration
                    HeroIllustrationView()
                        .frame(width: 220, height: 115)
                        .padding(.top, 16)
                    
                    // Section Title & Subtitle
                    Text("Cek perangkat dulu, ya")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                    
                    Text("Biar tes lancar sampai selesai. Cuma beberapa detik.")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                    
                    // Summary Banner
                    summaryBannerView
                        .padding(.top, 20)
                        .padding(.bottom, 14)
                    
                    // Device Checks Card List
                    VStack(spacing: 10) {
                        ForEach(checkManager.items) { item in
                            DeviceCheckCard(item: item)
                        }
                    }
                    
                    // Footer
                    Text("© 2025 BPPP. Versi 9.0.0")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textHint)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.white)
            
            // MARK: - Bottom Buttons Bar
            VStack(spacing: 0) {
                Divider()
                    .background(AppColors.border)
                
                HStack(spacing: 12) {
                    // Outlined Button "Cek ulang"
                    Button(action: {
                        checkManager.runAllChecks()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .bold))
                            Text("Cek ulang")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.primary, lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                    }
                    
                    // Filled Button "Lanjut"
                    Button(action: {
                        if checkManager.summaryState == .allPass {
                            onStartExam()
                        }
                    }) {
                        Text("Lanjut")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                checkManager.summaryState == .allPass
                                    ? AppColors.primary
                                    : AppColors.primaryDisabled
                            )
                            .cornerRadius(14)
                    }
                    .disabled(checkManager.summaryState != .allPass)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.white)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            checkManager.runAllChecks()
        }
        .alert(isPresented: $checkManager.showCameraPermissionAlert) {
            Alert(
                title: Text("Izin Kamera Diperlukan"),
                message: Text("Kamera diperlukan untuk verifikasi identitas peserta ujian. Buka Pengaturan untuk mengaktifkan izin kamera secara manual."),
                primaryButton: .default(Text("Buka Pengaturan"), action: {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }),
                secondaryButton: .cancel(Text("Batal"))
            )
        }
    }
    
    // MARK: - Summary Banner View
    private var summaryBannerView: some View {
        HStack(spacing: 12) {
            ZStack {
                switch checkManager.summaryState {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .scaleEffect(0.9)
                case .allPass:
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppColors.primary)
                case .someFail:
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppColors.failText)
                }
            }
            .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 1) {
                switch checkManager.summaryState {
                case .loading:
                    Text("Memeriksa perangkat…")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Tunggu sebentar ya.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textPrimary)
                case .allPass:
                    Text("Perangkat siap")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Semua aman. Kamu bisa lanjut ke tes.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textPrimary)
                case .someFail:
                    Text("Perangkat belum siap")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Perbaiki yang bermasalah, lalu cek ulang.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(bannerBgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
    }
    
    private var bannerBgColor: Color {
        switch checkManager.summaryState {
        case .loading:
            return AppColors.bannerLoadingBg
        case .allPass:
            return AppColors.bannerPassBg
        case .someFail:
            return AppColors.bannerFailBg
        }
    }
}

// MARK: - Device Check Card Item
struct DeviceCheckCard: View {
    let item: DeviceCheckItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon Tile
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.iconTileBg)
                    .frame(width: 44, height: 44)
                
                iconView(for: item.id)
            }
            
            // Labels
            VStack(alignment: .leading, spacing: 2) {
                Text(item.label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(item.displayValue)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Right Pill / Progress
            switch item.status {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                    .scaleEffect(0.8)
                    .frame(width: 44, height: 28)
            case .pass:
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Siap")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(AppColors.pillPassText)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.pillPassBg)
                .cornerRadius(12)
            case .fail:
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Gagal")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(AppColors.failText)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.pillFailBg)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func iconView(for id: String) -> some View {
        switch id {
        case "camera":
            // Face / Avatar identification icon
            ZStack {
                Circle()
                    .fill(Color(red: 0xEB/255.0, green: 0xC4/255.0, blue: 0xA0/255.0))
                    .frame(width: 14, height: 14)
                    .offset(y: -4)
                
                Circle()
                    .fill(Color(red: 0x6B/255.0, green: 0x54/255.0, blue: 0x44/255.0))
                    .frame(width: 14, height: 7)
                    .offset(y: -8)
                
                Capsule()
                    .fill(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
                    .frame(width: 22, height: 14)
                    .offset(y: 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 24, height: 24)
        case "network":
            Image(systemName: "wifi")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
        case "os":
            Image(systemName: "iphone")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
        case "security":
            Image(systemName: "checkmark.shield")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
        case "call":
            Image(systemName: "phone.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
        default:
            Image(systemName: "gear")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
        }
    }
}

// MARK: - Native Vector Hero Illustration (matching Android ic_hero_device_check)
struct HeroIllustrationView: View {
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 240.0, size.height / 125.0)
            
            // 1. Bottom shadow
            let shadowRect = CGRect(x: 69 * scale, y: (117 - 5.6) * scale, width: 104 * scale, height: 11.2 * scale)
            context.fill(Path(ellipseIn: shadowRect), with: .color(Color(red: 0xD5/255.0, green: 0xDF/255.0, blue: 0xDD/255.0)))
            
            // 2. Large background soft ellipse
            let bgRect = CGRect(x: 6.25 * scale, y: (59.5 - 49) * scale, width: 227.5 * scale, height: 98 * scale)
            context.fill(Path(ellipseIn: bgRect), with: .color(Color(red: 0xE9/255.0, green: 0xEE/255.0, blue: 0xEE/255.0)))
            
            // 3. Left badge: circle with wifi
            let leftCircleRect = CGRect(x: (50.7 - 19.6) * scale, y: (45.5 - 19.6) * scale, width: 39.2 * scale, height: 39.2 * scale)
            context.fill(Path(ellipseIn: leftCircleRect), with: .color(.white))
            context.stroke(Path(ellipseIn: leftCircleRect), with: .color(Color(red: 0xA9/255.0, green: 0xBF/255.0, blue: 0xBB/255.0)), lineWidth: 1.5 * scale)
            
            // Wifi waves
            var wifiArc1 = Path()
            wifiArc1.addArc(center: CGPoint(x: 50.7 * scale, y: 51 * scale), radius: 12 * scale, startAngle: .degrees(220), endAngle: .degrees(320), clockwise: false)
            context.stroke(wifiArc1, with: .color(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0)), style: StrokeStyle(lineWidth: 2.2 * scale, lineCap: .round))
            
            var wifiArc2 = Path()
            wifiArc2.addArc(center: CGPoint(x: 50.7 * scale, y: 51 * scale), radius: 8 * scale, startAngle: .degrees(220), endAngle: .degrees(320), clockwise: false)
            context.stroke(wifiArc2, with: .color(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0)), style: StrokeStyle(lineWidth: 2.2 * scale, lineCap: .round))
            
            var wifiArc3 = Path()
            wifiArc3.addArc(center: CGPoint(x: 50.7 * scale, y: 51 * scale), radius: 4 * scale, startAngle: .degrees(220), endAngle: .degrees(320), clockwise: false)
            context.stroke(wifiArc3, with: .color(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0)), style: StrokeStyle(lineWidth: 2.2 * scale, lineCap: .round))
            
            let wifiDotRect = CGRect(x: (50.7 - 2) * scale, y: (51 - 2) * scale, width: 4 * scale, height: 4 * scale)
            context.fill(Path(ellipseIn: wifiDotRect), with: .color(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0)))
            
            // 4. Center phone body
            let phoneBody = CGRect(x: 86 * scale, y: 3.5 * scale, width: 57 * scale, height: 105 * scale)
            context.fill(Path(roundedRect: phoneBody, cornerRadius: 8 * scale), with: .color(Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0)))
            
            // Phone screen
            let phoneScreen = CGRect(x: 92 * scale, y: 10 * scale, width: 45 * scale, height: 90 * scale)
            context.fill(Path(roundedRect: phoneScreen, cornerRadius: 3 * scale), with: .color(Color(red: 0xF1/255.0, green: 0xF5/255.0, blue: 0xF4/255.0)))
            
            // Phone speaker/home bar
            let phoneBar = CGRect(x: 106 * scale, y: 103.5 * scale, width: 17 * scale, height: 2.4 * scale)
            context.fill(Path(roundedRect: phoneBar, cornerRadius: 1.2 * scale), with: .color(Color(red: 0xB7/255.0, green: 0xC6/255.0, blue: 0xC3/255.0)))
            
            // Phone checklist items
            let rowY: [CGFloat] = [26.6, 42.7, 59.5, 77.0]
            for (idx, yVal) in rowY.enumerated() {
                let dotColor: Color = (idx == 3) ? Color(red: 0xD9/255.0, green: 0xAE/255.0, blue: 0x4B/255.0) : Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0)
                let dotRect = CGRect(x: (99.7 - 3.5) * scale, y: (yVal - 3.5) * scale, width: 7 * scale, height: 7 * scale)
                context.fill(Path(ellipseIn: dotRect), with: .color(dotColor))
                
                let lineBar = CGRect(x: 108 * scale, y: (yVal - 2) * scale, width: 24 * scale, height: 4 * scale)
                context.fill(Path(roundedRect: lineBar, cornerRadius: 2 * scale), with: .color(Color(red: 0xCF/255.0, green: 0xDA/255.0, blue: 0xD7/255.0)))
            }
            
            // 5. Right badge: Gold badge with checkmark
            let goldBadgeRect = CGRect(x: (178 - 17.5) * scale, y: (80.5 - 17.5) * scale, width: 35 * scale, height: 35 * scale)
            context.fill(Path(ellipseIn: goldBadgeRect), with: .color(Color(red: 0xD9/255.0, green: 0xAE/255.0, blue: 0x4B/255.0)))
            
            var checkmark = Path()
            checkmark.move(to: CGPoint(x: 171 * scale, y: 80.8 * scale))
            checkmark.addLine(to: CGPoint(x: 176 * scale, y: 85.8 * scale))
            checkmark.addLine(to: CGPoint(x: 184.5 * scale, y: 76.3 * scale))
            context.stroke(checkmark, with: .color(.white), style: StrokeStyle(lineWidth: 2.8 * scale, lineCap: .round, lineJoin: .round))
            
            // 6. Sparkle stars
            drawSparkle(context: context, center: CGPoint(x: 188.6 * scale, y: 24.5 * scale), size: 12 * scale, color: Color(red: 0xD9/255.0, green: 0xAE/255.0, blue: 0x4B/255.0))
            drawSparkle(context: context, center: CGPoint(x: 36.7 * scale, y: 94.5 * scale), size: 7 * scale, color: Color(red: 0x3F/255.0, green: 0x5E/255.0, blue: 0x5A/255.0))
        }
    }
    
    private func drawSparkle(context: GraphicsContext, center: CGPoint, size: CGFloat, color: Color) {
        var path = Path()
        let half = size / 2.0
        path.move(to: CGPoint(x: center.x, y: center.y - half))
        path.addQuadCurve(to: CGPoint(x: center.x + half, y: center.y), control: center)
        path.addQuadCurve(to: CGPoint(x: center.x, y: center.y + half), control: center)
        path.addQuadCurve(to: CGPoint(x: center.x - half, y: center.y), control: center)
        path.addQuadCurve(to: CGPoint(x: center.x, y: center.y - half), control: center)
        context.fill(path, with: .color(color))
    }
}
