# ⚡ Jajan Tracker (Pencatat Keuangan 0-Friction)

Aplikasi pencatat keuangan mobile ultra-cepat dan minim friksi yang didesain khusus untuk memisahkan **Uang Pokok** dari **Uang Jajan** (*Mental Accounting*). 

Dibuat dengan filosofi **0 friction**: nyatet pengeluaran jajan harus semudah dan secepat mungkin (tanpa mikir kategori, tanpa form panjang, cukup 1-2 aksi), plus pengingat otomatis saat membuka e-wallet (**ShopeePay**) agar kamu sadar sisa saldo sebelum transaksi terjadi.

---

## 🌟 Fitur Utama (MVP)

1. **⚡ Quick-Log Instant Popup (< 2 detik)**
   - Numpad custom ultra-cepat dengan tombol preset jajan (`+5rb`, `+10rb`, `+20rb`, `+50rb`, `000`).
   - Tidak ada dropdown kategori berbelit, cukup nominal dan catatan ringkas opsional (cth: "Es kopi", "Cilok").

2. **📱 Home Screen Widget Interaktif**
   - Menampilkan **Sisa Uang Jajan** secara real-time langsung di layar utama HP.
   - Menampilkan batas aman pengeluaran harian (misal: *"Aman jajan Rp 42.500 / hari"*).
   - **1-Tap Log**: Sentuh widget untuk langsung membuka Quick-Log tanpa harus membuka menu utama dashboard.

3. **🛍️ ShopeePay Pre-Transaction Nudge (Pengingat Otomatis)**
   - Menggunakan layanan *Android Accessibility Service* & *Floating Overlay*.
   - Saat aplikasi **Shopee** dibuka di HP, sebuah *floating chip* halus akan muncul di layar selama 6 detik:
     > `🛍️ Ingat Sisa Uang Jajan! Rp 125.000 (✕)`
   - Membuat kamu sadar sisa budget sebelum checkout / transaksi terjadi, bukan cuma menyesal setelah uang hilang.
   - Dilengkapi menu pengaturan dan tombol **"Tes Pengingat Mengambang"** untuk mencoba tampilan tanpa perlu keluar aplikasi.

4. **📊 Dashboard & Evaluasi Ringkas**
   - Kartu saldo hero dengan indikator progres visual (Hijau ➡️ Kuning ➡️ Merah jika overbudget).
   - Riwayat pengeluaran jajan periode gajian dengan fitur geser untuk hapus (*swipe to delete*) jika salah catat.
   - Pengaturan nominal budget bulanan dan tanggal gajian (misal setiap tanggal 25).

---

## 🛠️ Tech Stack & Arsitektur

- **Framework**: Flutter 3.47+ (Dart 3.13)
- **Local Storage**: SQLite (`sqflite`), `shared_preferences` (Offline-first, 100% lokal di perangkat)
- **Native Android Integration**:
  - `JajanWidgetProvider.kt`: AppWidgetProvider dengan RemoteViews dan PendingIntent untuk instant launch.
  - `ShopeeAccessibilityService.kt`: Layanan aksesibilitas mendengarkan peluncuran paket `com.shopee.id`.
  - `WindowManager`: Overlay UI (*SYSTEM_ALERT_WINDOW*) untuk floating notification chip.
  - `MethodChannel`: Sinkronisasi data real-time antara Flutter engine dan Native Android.

---

## 🚀 Cara Menjalankan & Memasang di HP Android

### 1. Prasyarat
- Flutter SDK 3.27+
- Android SDK & Java 17

### 2. Menjalankan di Mode Debug
Hubungkan HP Android ke PC via USB debugging, lalu jalankan:
```bash
flutter run
```

### 3. Build APK
Untuk menghasilkan file APK mandiri yang bisa di-install langsung di HP:
```bash
flutter build apk --release
```
File APK akan berada di folder `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📲 Panduan Menambahkan Widget & Izin ShopeePay Nudge

### Memasang Widget di Home Screen:
1. Tekan dan tahan area kosong di layar utama (Home Screen) HP Android kamu.
2. Pilih menu **Widget**.
3. Cari **Jajan Tracker**, lalu drag widget ke layar.
4. Saldo jajanmu akan langsung tampil. Tekan widget kapan saja untuk quick-log instan!

### Mengaktifkan Fitur Pengingat Shopee:
1. Buka aplikasi **Jajan Tracker**.
2. Tap ikon tas belanja `🛍️` di pojok kanan atas.
3. Berikan dua izin:
   - **Tampilkan di Atas Aplikasi Lain** (*Display over other apps*)
   - **Layanan Aksesibilitas** (*Accessibility Services* -> aktifkan **Jajan Tracker**)
4. Tekan tombol *"Simulasi Buka Shopee"* untuk memastikan chip pengingat muncul dengan baik.
