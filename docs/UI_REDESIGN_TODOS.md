# UI Redesign TODOs & Enhancement Roadmap

Dokumen ini merangkum daftar rencana kerja (*actionable TODOs*) untuk mendesain ulang dan memoles komponen visual utama pada aplikasi **Expense Tracker**.

---

## 1. Redesign: UI "Besok Max Jajan" (Tomorrow's Allowance Indicator)

### Latar Belakang & Masalah Saat Ini
- Indikator proyeksi jatah jajan besok (`tomorrowDailyAllowance`) saat ini dirender sebagai pill kecil di bawah nominal sisa jajan hari ini.
- Tampilannya masih cenderung kaku dan kurang kontras atau informatif saat kondisi:
  1. Pengguna sedang *overbudget* hari ini (besok jatah otomatis terserap).
  2. Pengguna masih sangat hemat hari ini (besok jatah bisa bertambah).
- Hirarki visual perlu diperjelas agar pengguna langsung memahami bahwa ini adalah **proyeksi adaptif**, bukan sisa saldo riil saat ini.

### Wireframe Konsep
```
+-------------------------------------------------------------+
| SISA SALDO JAJAN HARI INI                                   |
| Rp 45.000 / hari                                            |
|                                                             |
| (•) Besok max jajan: Rp 38.000  (i)                         |
|     ^ Pill dinamis: Hijau (Hemat) / Coral (Overbudget)      |
+-------------------------------------------------------------+
```

### Daftar Tugas (TODOs)
- [ ] **Badge / Capsule Polish**:
  - Desain ulang chip proyeksi dengan bentuk kapsul modern, border halus (*subtle glass/card border*), dan padding seimbang.
  - Gunakan typography yang lebih kontras: label *"Besok max jajan:"* dengan warna sekunder, nominal tebal (*semibold/bold*).
- [ ] **Adaptive State Styling**:
  - **Normal / Surplus**: Aksen biru halus (`PirschColors.primaryBlue`) atau abu-abu netral dengan icon kalender minimalis.
  - **Hemat Ekstra**: Berikan indikator hijau lembut jika penghematan hari ini menaikkan jatah hari esok.
  - **Overbudget / Warning**: Tampilan warna coral/rose lembut (`PirschColors.roseRed` dengan background transparan 12%) dengan icon peringatan rounded (`Icons.info_outline_rounded`).
- [ ] **Interactive Tooltip / Bottom Sheet Info**:
  - Berikan micro-interaction (tap target) yang memunculkan tooltip atau bottom sheet penjelasan singkat:
    *"Dihitung dari sisa budget mingguan dibagi sisa hari minggu ini."*
- [ ] **Animasi Perubahan Nilai**:
  - Tambahkan animasi transisi halus (`AnimatedSwitcher` / count animation) ketika jatah besok berubah setelah pengguna mencatat pengeluaran baru.

---

## 2. Redesign: Alert / Banner "Periode Baru Dimulai"

### Latar Belakang & Masalah Saat Ini
- Banner `WeeklyRolloverBanner` saat ini muncul di atas Hero Card saat hari Senin tiba (sebelum konfirmasi budget mingguan).
- Desain saat ini berupa kartu statis persegi dengan tombol *"Input"* kecil.
- Perlu dirombak agar:
  1. Tampilannya lebih elegan, ramah, dan tidak terasa seperti *error message*.
  2. Menampilkan nominal sisa riil secara transparan dan jelas.
  3. Memiliki visual hierarchy yang menuntun pengguna untuk segera menetapkan budget minggu baru tanpa rasa cemas.

### Wireframe Konsep
```
+-------------------------------------------------------------+
|  (🗓️) Periode Baru Dimulai                                  |
|      Ada sisa Rp 27.000 dari minggu lalu di dompetmu.       |
|      Yuk tentukan budget untuk minggu ini!                  |
|                                                             |
|      [ Atur Budget Minggu Ini -> ]          [ Nanti / x ]   |
+-------------------------------------------------------------+
```

### Daftar Tugas (TODOs)
- [ ] **Card Layout & Visual Hierarchy**:
  - Terapkan kontainer rounded modern (border radius 20–24px) dengan ambient accent glow atau aksen warna biru Pirsch (`0xFF16192B` di dark mode / `0xFFEFF2FC` di light mode).
  - Pisahkan area icon, teks ringkasan, dan tombol aksi (*CTA Button*) dengan spacing 16px.
- [ ] **Pemberitahuan Saldo Riil yang Jelas**:
  - Teks utama: *"Periode Baru Dimulai"* dengan badge kalender/refresh.
  - Subteks: *"Ada sisa Rp xx.xxx dari minggu lalu di dompetmu. Yuk tentukan budget minggu ini!"*.
  - Tambahkan label saldo riil per dompet jika fitur Multi-Wallet aktif (misal: E-Wallet: Rp xx.xxx | Tunai: Rp xx.xxx).
- [ ] **Tombol Aksi (CTA Button) Lebih Menonjol**:
  - Ubah tombol *"Input"* menjadi tombol pill dengan teks lebih actionable: *"Atur Budget"* atau *"Set Budget"*.
  - Tambahkan efek haptic feedback saat ditekan dan hover/pressed state yang responsif.
- [ ] **Opsi Minimize / Snooze (Non-Intrusive)**:
  - Berikan tombol dismiss/minimize kecil (*chevron* atau *close*) agar pengguna yang sedang terburu-buru mencatat jajan cepat tetap bisa menggunakan aplikasi tanpa terhalang banner besar.
  - Banner yang di-minimize berubah menjadi chip kompak di header: *"Atur budget minggu ini >"*.
- [ ] **Animasi Masuk (Slide-in Entry)**:
  - Berikan animasi *fade & slide down* yang mulus ketika banner pertama kali muncul di hari Senin pagi.

---

## 3. Redesign: Layar Rekap Pengeluaran & Visualisasi Chart

### Latar Belakang & Masalah Saat Ini
- Layar Rekap saat ini menyajikan breakdown kategori dalam bentuk *multi-segmented horizontal line bar*.
- Pengguna membutuhkan representasi grafik visual (*chart*) yang lebih intuitif untuk:
  1. Mengetahui **tren pengeluaran harian** (hari apa saja yang paling boros).
  2. Membandingkan pengeluaran harian terhadap batas budget harian rata-rata (*benchmark line*).
  3. Melihat proporsi kategori dalam grafik donat (*donut chart*) atau grafik batang vertikal modern.

### Wireframe Konsep Layar Rekap dengan Chart
```
+-------------------------------------------------------------+
| [<]                  Rekap Pengeluaran                  [↻] |
| 15 - 21 Sep 2026                                            |
+-------------------------------------------------------------+
| [ TOTAL PENGELUARAN ]                         [ 8 Transaksi]|
| Rp 145.000                                                  |
| Rata-rata: Rp 20.700/hari    | Budget: Rp 200.000           |
+-------------------------------------------------------------+
| TREN HARIAN (7-Day Bar Chart)                               |
|   50k |             [■]                                     |
|   25k |   [■]       [■]       [■]                           |
|       - - - - - - - - - - - - - - - (Batas: Rp 20.700/hari) |
|    0  +----+----+----+----+----+----+----+                  |
|       Sen  Sel  Rab  Kam  Jum  Sab  Min                     |
+-------------------------------------------------------------+
| PROPORSI KATEGORI (Interactive Donut / Bar)                 |
|   ( O )  45% Makanan & Minuman   (Rp 65.000)                |
|          30% Transportasi        (Rp 43.500)                |
|          25% Belanja & Lainnya   (Rp 36.500)                |
+-------------------------------------------------------------+
| TOP 5 PENGELUARAN TERBESAR                                  |
| 1. Nasi Padang Spesial                    Rp 35.000         |
| 2. Kopi Kenangan Mantan                   Rp 22.000         |
+-------------------------------------------------------------+
|             ( Minggu Ini | Bulan Ini | Semua )              |
+-------------------------------------------------------------+
```

### Daftar Tugas (TODOs)
- [ ] **Chart Tren Harian (Weekly 7-Day Bar Chart)**:
  - Implementasi grafik batang 7 hari (Senin s.d. Minggu) dengan Flutter CustomPainter atau widget bar chart modular tanpa dependensi berat yang membengkakkan APK.
  - Tampilkan garis batas putus-putus (*dashed benchmark line*) penanda batas jajan rata-rata harian.
  - Batang yang melebihi batas rata-rata diwarnai dengan aksen coral/rose (`PirschColors.roseRed`), sedangkan yang aman diwarnai biru/mint.
  - Micro-interaction: Tap pada batang hari memunculkan tooltip nominal pengeluaran hari tersebut.
- [ ] **Chart Distribusi Kategori (Donut / Pie Chart)**:
  - Tampilkan visualisasi cincin (*donut ring*) dengan warna identik per kategori sesuai `ExpenseCategory.color`.
  - Di tengah cincin donat, tampilkan nominal kategori terbesar atau total pengeluaran.
- [ ] **Perbandingan Antar Periode (*Delta Comparison*)**:
  - Tampilkan badge perbandingan terhadap periode sebelumnya (contoh: *"-14% lebih hemat dibanding minggu lalu"*).
- [ ] **Filter & Interaksi Chart Tanpa Lag**:
  - Pastikan chart di-*render* secara efisien pada `PageView` 3 tab (*Minggu Ini*, *Bulan Ini*, *Semua*) dengan framerate stabil 60/120 FPS.

---

## 4. Matriks Prioritas Pengerjaan

| Prioritas | Komponen | Target File | Estimasi Waktu |
| :--- | :--- | :--- | :--- |
| **P1** | Redesign Alert *"Periode Baru Dimulai"* | `lib/features/dashboard/widgets/weekly_rollover_banner.dart` | ~45 menit |
| **P1** | Redesign Pill *"Besok Max Jajan"* | `lib/features/dashboard/widgets/hero_balance_card.dart` | ~30 menit |
| **P1** | Chart Tren Pengeluaran Harian Rekap | `lib/features/rekap/widgets/rekap_daily_bar_chart.dart` | ~60 menit |
| **P2** | Chart Donut Kategori Rekap | `lib/features/rekap/widgets/rekap_category_donut_chart.dart` | ~45 menit |
| **P2** | Micro-interaction Tooltip Penjelasan Proyeksi | `lib/features/dashboard/widgets/hero_balance_card.dart` | ~20 menit |
| **P2** | State Minimize / Chip Compact Periode Baru | `lib/features/dashboard/dashboard_screen.dart` | ~30 menit |
