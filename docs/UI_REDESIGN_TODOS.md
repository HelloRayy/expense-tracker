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

## 3. Komponen Pendukung Terkait

### Hero Balance Card & Header
- [ ] **Date & Period Selector**: Rapikan dropdown periode jajan (`hari ini` vs `mingguan`) agar lebih mudah di-tap dengan jempol satu tangan.
- [ ] **Accordion Wallet Card**: Poles kartu accordion E-Wallet vs Tunai agar transisi expand/collapse lebih fluid menggunakan curve `Curves.easeOutCubic`.

### Rekap Screen & Navigation
- [ ] **Rekap Floating Dock**: Jaga konsistensi bayangan dan warna aktif antara bottom floating dock di Rekap dengan Home navbar.
- [ ] **Page Transition Performance**: Pastikan rendering grafik proporsi kategori di `PageView` tetap 60/120 FPS di perangkat Android & iOS.

---

## 4. Matriks Prioritas Pengerjaan

| Prioritas | Komponen | Target File | Estimasi Waktu |
| :--- | :--- | :--- | :--- |
| **P1** | Redesign Alert *"Periode Baru Dimulai"* | `lib/features/dashboard/widgets/weekly_rollover_banner.dart` | ~45 menit |
| **P1** | Redesign Pill *"Besok Max Jajan"* | `lib/features/dashboard/widgets/hero_balance_card.dart` | ~30 menit |
| **P2** | Micro-interaction Tooltip Penjelasan Proyeksi | `lib/features/dashboard/widgets/hero_balance_card.dart` | ~20 menit |
| **P2** | State Minimize / Chip Compact Periode Baru | `lib/features/dashboard/dashboard_screen.dart` | ~30 menit |
