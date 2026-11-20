# ExamBPPP iOS (SwiftUI Clean-Room Port)

Porting resmi dan bersih dari arsitektur aplikasi ujian **ExamBPPP Kemendikdasmen v9.0.0** untuk perangkat Apple **iPhone / iPad (iOS 15.0+)**.

---

## 1. Spesifikasi Teknis & Replikasi Inti

* **Target URL Portal**: `https://delivery-mobile.bppp.kemendikdasmen.go.id`
* **Custom User-Agent Injection**:
  Setiap HTTP request dari `WKWebView` disisipkan token rahasia resmi:
  ```text
  Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1 JSB8123BKDSB9239BJBJDS89JNSDKK17
  ```
* **JavaScript Bridge Shim (`window.AndroidBridge`)**:
  Diinjeksi otomatis pada fase `atDocumentStart` sebelum skrip web berjalan:
  * `getAppVersion()` -> `"9.0.0"`
  * `isSecureEnvironment()` -> `true`
  * `notifyExamStarted()` -> Kunci mode ujian
  * `notifyExamFinished()` -> Buka mode ujian
  * `notifyRouteChanged(route)` -> Navigasi rute
  * `requestNativeExit()` -> Dialog konfirmasi native
* **Whitelist Domain (`decidePolicyFor navigationAction`)**:
  * `delivery-mobile.bppp.kemendikdasmen.go.id`
  * `delivery-abm.bppp.kemendikdasmen.go.id`
  * `pengawas-ujian.bppp.kemendikdasmen.go.id`
  * `storage.googleapis.com`
  * `fcm.googleapis.com`
  * `firebaseinstallations.googleapis.com`
* **Pre-flight Checks (Pemeriksaan Kesiapan)**:
  1. Izin & sensor kamera (AVCaptureDevice)
  2. Latensi koneksi ke server BPPP (URLSession)
  3. Kompatibilitas versi iOS (15.0+)
  4. Integritas keamanan perangkat
  5. Status jalur panggilan suara

---

## 2. Cara Compile & Dapatkan File `.ipa` (Untuk Pengguna Windows)

Karena kita bekerja di Windows 11 tanpa Xcode/Mac lokal, projek ini telah dilengkapi workflow **GitHub Actions** yang memanfaatkan server Mac resmi GitHub secara gratis.

### Langkah-langkah:
1. Buat repository baru di akun GitHub Anda (misal: `ExamBPPP-iOS`).
2. Masuk ke folder projek ini via terminal:
   ```bash
   cd "C:\Daffa Dhiya Ulhaq X RPL 1\Project\ExamBPPP-iOS"
   git init
   git add .
   git commit -m "feat: initial ExamBPPP iOS port"
   git branch -M main
   git remote add origin https://github.com/<username-anda>/ExamBPPP-iOS.git
   git push -u origin main
   ```
3. Buka tab **Actions** di repo GitHub Anda.
4. Tunggu job **Build iOS IPA (ExamBPPP)** selesai (~2-3 menit).
5. Download artifact **`ExamBPPP-iOS-IPA`** yang berisi file **`ExamBPPP.ipa`**.

---

## 3. Cara Install File `.ipa` ke iPhone via Windows

Setelah mendapatkan file `ExamBPPP.ipa`:

### Menggunakan Sideloadly (Paling Direkomendasikan & Cepat):
1. Download dan buka [Sideloadly](https://sideloadly.io/) di laptop Windows.
2. Colok iPhone ke laptop via kabel data (pilih "Trust this computer" di iPhone jika muncul).
3. Drag & drop file `ExamBPPP.ipa` ke Sideloadly.
4. Masukkan Apple ID gratis Anda di kolom akun, lalu klik **Start**.
5. Setelah selesai (status `Done`), buka iPhone:
   * Masuk ke **Settings > General > VPN & Device Management** (Pengaturan > Umum > Manajemen VPN & Perangkat).
   * Klik profil Apple ID Anda dan pilih **Trust / Percayai**.
6. Buka aplikasi **ExamBPPP** di home screen iPhone Anda.

*(Jika iPhone Anda sudah terpasang TrollStore, Anda cukup kirim file `ExamBPPP.ipa` via AirDrop/Telegram dan install langsung tanpa revoke).*

---

## 4. Tips Ujian Aman di iPhone (Lockdown Mode)
Untuk mencegah notifikasi pop-up atau layar berpindah saat ujian:
* Aktifkan fitur bawaan iOS **Guided Access (Akses Terpandu)**:
  * Buka **Settings > Accessibility > Guided Access** dan aktifkan.
  * Saat aplikasi ExamBPPP terbuka, tekan tombol Power 3 kali untuk mengunci aplikasi.
