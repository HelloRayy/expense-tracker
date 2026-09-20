# Technical Directive: UI Redesign & Component Roadmap

Dokumen ini adalah **panduan instruksi teknis direktif** bagi AI agent dan developer untuk mengeksekusi *redesign UI* pada aplikasi **Expense Tracker**. Setiap bagian mencakup target file, kelas, semantic key, spesifikasi layout/widget, dan langkah eksekusi kode.

---

## 1. Komponen: Alert "Periode Baru Dimulai" (`WeeklyRolloverBanner`)

### Lokasi Kode & Arsitektur
- **File Target**: [`lib/features/dashboard/widgets/weekly_rollover_banner.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/weekly_rollover_banner.dart)
- **Parent Screen**: [`lib/features/dashboard/dashboard_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/dashboard_screen.dart#L218-L225)
- **Semantic Key**: `UIKeys.dashboardRolloverBanner`
- **State Source**: `BudgetRepository.carryoverBalance`, `BudgetRepository.isPeriodConfirmed`, `AppSettingsController.instance.cashWalletEnabled`

### Masalah Saat Ini
Bentuk kartu statis dengan kontras standar dan tombol kecil "Input" yang terlihat seperti *system error*, serta belum menampilkan rincian saldo fisik vs e-wallet ketika mode multi-wallet aktif.

### Spesifikasi Target Desain
```
+-------------------------------------------------------------------+
|  [Icon Kalender Bulat]  PERIODE BARU DIMULAI                      |
|                         Ada sisa Rp 27.000 dari minggu lalu.      |
|                         (E-Wallet: Rp 20.000 • Tunai: Rp 7.000)   |
|                                                                   |
|  [ Atur Budget Minggu Ini -> ]                    [ Nanti / v ]   |
+-------------------------------------------------------------------+
```

### Arahan Implementasi Teknis (Step-by-Step)
1. **Container & Elevasi**:
   - Ganti `BoxDecoration` kartu dengan `borderRadius: BorderRadius.circular(22)`.
   - Dark mode: `color: const Color(0xFF16192B)`, border: `Border.all(color: PirschColors.primaryBlue.withValues(alpha: 0.3))`.
   - Light mode: `color: const Color(0xFFEFF2FC)`, border: `Border.all(color: PirschColors.primaryBlue.withValues(alpha: 0.2))`.
2. **Typography & Info Saldo**:
   - Header badge: `Text('PERIODE BARU DIMULAI')` (size: 11, bold, letterSpacing: 0.8, color: `PirschColors.primaryBlue`).
   - Subtitle: `Text('Ada sisa ${CurrencyFormatter.format(carryoverBalance)} dari minggu lalu.')` (size: 13, weight: 600).
   - Multi-Wallet Sub-row (jika `cashWalletEnabled`): Tampilkan rincian chip kecil saldo E-Wallet vs Tunai.
3. **CTA Action Button**:
   - Ubah tombol menjadi full-pill: `ElevatedButton` dengan label `"Atur Budget Minggu Ini"`, height: 38, icon panah `Icons.arrow_forward_rounded`.
   - On tap: Panggil `WeeklyBudgetInputSheet.show(context, repository)`.
4. **State Minimize / Collapse**:
   - Sediakan tombol minimize `IconButton(Icons.keyboard_arrow_up_rounded)` untuk mengecilkan banner menjadi compact pill jika user ingin langsung mencatat transaksi tanpa terhalang.

---

## 2. Komponen: Pill Indikator "Besok Max Jajan" (`HeroTomorrowAllowancePill`)

### Lokasi Kode & Arsitektur
- **File Target**: [`lib/features/dashboard/widgets/hero_balance_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/hero_balance_card.dart#L307-L348)
- **Method Target**: Widget builder untuk pill proyeksi jatah besok di bawah nominal utama.
- **Semantic Key**: `UIKeys.heroTomorrowAllowance`
- **Data Source**: `widget.tomorrowDailyAllowance` (dihitung dari `BudgetRepository.tomorrowDailyAllowance`)

### Masalah Saat Ini
Pill berada tepat di bawah nominal utama tetapi styling warnanya monoton, kurang memiliki hirarki visual dengan angka sisa hari ini, dan belum menjelaskan formula perhitungan saat ditekan pengguna.

### Spesifikasi Target Desain
```
+-------------------------------------------------------------------+
| Rp 45.000 / hari                                                  |
|                                                                   |
| [ (🗓️) Besok max jajan: Rp 38.000 | info (i) ]                    |
| ^ Warna adaptif:                                                  |
|   - Hijau/Mint: Jika pengeluaran hari ini hemat (sisa > kuota)    |
|   - Biru Netral: Jika kondisi pengeluaran normal                  |
|   - Rose/Coral: Jika overbudget hari ini (besok jatah terserap)   |
+-------------------------------------------------------------------+
```

### Arahan Implementasi Teknis (Step-by-Step)
1. **Dynamic Color Resolver**:
   - Buat helper method internal:
     ```dart
     Color _getTomorrowBadgeColor(bool isDark, bool isOverBudget, int remainingToday, int dailyAllowance)
     ```
   - Jika `isOverBudget`: Background `PirschColors.roseRed.withValues(alpha: 0.12)`, border `PirschColors.roseRed.withValues(alpha: 0.3)`, text `PirschColors.roseRed`.
   - Jika `remainingToday >= dailyAllowance` (hemat): Background `PirschColors.mintGreen.withValues(alpha: 0.12)`, border `PirschColors.mintGreen.withValues(alpha: 0.3)`, text `PirschColors.mintGreen`.
   - Jika normal: Background `Colors.white10`, border `borderColor`, text `textSecondary`.
2. **Kapsul & Spacing**:
   - Gunakan `borderRadius: BorderRadius.circular(20)`.
   - Padding: `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`.
   - Spacing dari nominal utama: `SizedBox(height: 10)`.
3. **Micro-Interaction Info Sheet**:
   - Bungkus pill dengan `InkWell` / `GestureDetector`.
   - Saat di-tap, panggil modal dialog atau bottom sheet penjelasan singkat:
     *"Batas jajan esok hari dihitung dari sisa budget mingguan dibagi sisa hari minggu ini."*

---

## 3. Komponen: Visualisasi Chart Rekap Pengeluaran (`RekapScreen`)

### Lokasi Kode & Arsitektur
- **Layar Utama**: [`lib/features/rekap/screens/rekap_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/rekap/screens/rekap_screen.dart)
- **Widget Baru 1**: `lib/features/rekap/widgets/rekap_daily_bar_chart.dart` (Grafik Batang 7 Hari)
- **Widget Baru 2**: `lib/features/rekap/widgets/rekap_category_donut_chart.dart` (Grafik Donut Kategori)
- **Data Source**: `widget.repository.getExpensesForPeriod(start, end)`

### Masalah Saat Ini
Halaman Rekap hanya menampilkan proportional bar satu garis datar horizontal, tanpa visualisasi tren hari apa yang paling boros dan tanpa perbandingan terhadap batas jajan harian rata-rata.

### Spesifikasi Target Desain Wireframe
```
+-------------------------------------------------------------------+
| TREN PENGELUARAN 7 HARI                                           |
|                                                                   |
|   50k |            [■]                                            |
|   25k |   [■]      [■]       [■]                                  |
|   15k - - - - - - - - - - - - - - - (Batas Harian: Rp 15.000)     |
|    0  +----+----+----+----+----+----+----+                        |
|       Sen  Sel  Rab  Kam  Jum  Sab  Min                           |
+-------------------------------------------------------------------+
| PROPORSI KATEGORI (Donut Chart)                                   |
|   [ Donut ]  45% Makanan & Minuman   (Rp 65.000)                  |
|   [ Ring  ]  30% Transportasi        (Rp 43.500)                  |
|              25% Belanja & Lainnya   (Rp 36.500)                  |
+-------------------------------------------------------------------+
```

### Arahan Implementasi Teknis (Step-by-Step)
1. **Buat `RekapDailyBarChart`** ([NEW] `lib/features/rekap/widgets/rekap_daily_bar_chart.dart`):
   - Input props: `List<ExpenseModel> expenses`, `int dailyAllowanceBenchmark`, `bool isDark`.
   - Hitung total pengeluaran per hari (Senin s.d. Minggu).
   - Render menggunakan kolom batang vertikal `Container` dengan tinggi proporsional (`height = (dayTotal / maxDailySpent) * maxBarHeight`).
   - Terapkan garis benchmark putus-putus (*dashed line*) di posisi `dailyAllowanceBenchmark`.
   - Warna batang: Jika `dayTotal > dailyAllowanceBenchmark`, warnai dengan `PirschColors.roseRed`, jika aman warnai dengan `PirschColors.primaryBlue`.
   - Micro-interaction: Tap batang memunculkan tooltip nominal hari itu.
2. **Buat `RekapCategoryDonutChart`** ([NEW] `lib/features/rekap/widgets/rekap_category_donut_chart.dart`):
   - Gunakan `CustomPainter` menggambar busur (*arcs*) lingkaran donat dengan ketebalan stroke `14px`.
   - Warna busur sesuai `ExpenseCategory.color`.
   - Lubang tengah (*center hole*) menampilkan icon atau total pengeluaran.
3. **Integrasi ke `RekapScreen`**:
   - Di method `_buildPeriodPage()`, pasang `RekapDailyBarChart` tepat di bawah kartu `Total Summary Card`.
   - Pasang `RekapCategoryDonutChart` di dalam `Category Breakdown Card`.

---

## 4. Urutan Eksekusi Bounded Task

1. **Task 1**: Implementasi Redesign `WeeklyRolloverBanner` di `lib/features/dashboard/widgets/weekly_rollover_banner.dart`.
2. **Task 2**: Implementasi Redesign Pill `HeroTomorrowAllowance` di `lib/features/dashboard/widgets/hero_balance_card.dart`.
3. **Task 3**: Buat widget `RekapDailyBarChart` dan integrasikan ke `lib/features/rekap/screens/rekap_screen.dart`.
4. **Task 4**: Buat widget `RekapCategoryDonutChart` dan integrasikan ke `lib/features/rekap/screens/rekap_screen.dart`.
5. **Task 5**: Verifikasi seluruh test suite (`flutter test`) dan auto-commit & push ke GitHub.
