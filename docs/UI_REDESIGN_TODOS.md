# Area Fokus & Panduan Ide Redesign UI

Dokumen ini berfungsi sebagai **peta fokus dan catatan pengingat** mengenai komponen mana saja di codebase yang ditargetkan untuk *redesign UI*, apa masalah user experience saat ini, serta ide arah improvisasinya. 

> [!NOTE]
> Poin-poin di bawah ini adalah **inspirasi arah perbaikan & pengingat fokus**, bukan aturan kaku yang membatasi. AI agent dan developer memiliki kebebasan berkreasi untuk menentukan detail visual, animasi, dan estetika terbaik saat eksekusi.

---

## 1. Alert: "Periode Baru Dimulai"

### Lokasi Codebase
- **Widget**: `WeeklyRolloverBanner`
- **File**: [`lib/features/dashboard/widgets/weekly_rollover_banner.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/weekly_rollover_banner.dart)
- **Parent**: Dipanggil di [`lib/features/dashboard/dashboard_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/dashboard_screen.dart) di atas Hero Card saat `!repository.isPeriodConfirmed`.

### Masalah UX Saat Ini
- Tampilannya berupa kartu statis dengan tombol kecil *"Input"* yang terkesan kaku seperti kotak peringatan sistem (*warning/alert*).
- Informasi sisa saldo riil dari minggu lalu perlu disampaikan dengan lebih ramah, transparan, dan meyakinkan.

### Poin Pengingat & Ide Arah Redesign
- **Visual Lebih Bersahabat**: Eksplorasi bentuk kartu modern yang lebih menyatu dengan tema Pirsch (bisa dengan aksen rounded lembut, ambient glow, atau card container yang elegan).
- **Kejelasan Sisa Saldo**: Buat angka sisa uang dari minggu lalu menjadi fokus positif (misal: merayakan sisa uang jajan yang berhasil dihemat).
- **Tombol Aksi (CTA) Mengundang**: Tombol aksi yang jelas mengajak pengguna menentukan jatah mingguan baru (misal: *"Atur Budget Minggu Ini"*, *"Mulai Periode Baru"*).
- **Non-Intrusive**: Pertimbangkan kenyamanan pengguna jika sedang buru-buru ingin mencatat jajan cepat (opsi minimize atau banner kompak).

---

## 2. Indikator: "Besok Max Jajan"

### Lokasi Codebase
- **Widget**: `HeroBalanceCard` (bagian bawah nominal sisa jajan)
- **File**: [`lib/features/dashboard/widgets/hero_balance_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/hero_balance_card.dart)
- **Data**: `repository.tomorrowDailyAllowance` (proyeksi jatah esok hari).

### Masalah UX Saat Ini
- Pill teks proyeksi besok masih terlihat biasa dan kurang membedakan secara visual kondisi saat pengguna sedang sangat hemat vs saat kuota hari ini sedang boncos (*overbudget*).

### Poin Pengingat & Ide Arah Redesign
- **Kapsul / Pill Terintegrasi**: Letakkan di bawah nominal utama dengan hirarki visual yang jelas bahwa ini adalah proyeksi pintar (*smart forecast*).
- **Sentuhan Nuansa Adaptif**: Eksplorasi aksen warna yang berbicara dengan kondisi keuangan pengguna:
  - Nuansa segar/hemat saat pengguna menahan jajan hari ini (jatah besok membesar).
  - Nuansa perhatian/warning saat pengguna sudah overbudget hari ini (jatah besok mengecil/terserap).
- **Konteks Perhitungan**: Mudah dipahami mengapa angka besok bisa bertambah atau berkurang (bisa dengan tap popover/tooltip atau micro-copy yang bersahabat).

---

## 3. Rekap Pengeluaran & Integrasi Chart

### Lokasi Codebase
- **Layar**: `RekapScreen`
- **File**: [`lib/features/rekap/screens/rekap_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/rekap/screens/rekap_screen.dart)
- **Komponen Pendukung**: Dapat dibuatkan widget chart modular di `lib/features/rekap/widgets/`.

### Masalah UX Saat Ini
- Rekap saat ini baru menampilkan total nominal dan segmented line bar horizontal.
- Pengguna belum memiliki gambaran visual mengenai **tren hari-ke-hari** (hari apa yang paling boros) dan perbandingan terhadap batas jajan ideal harian.

### Poin Pengingat & Ide Arah Redesign
- **Grafik Batang Harian (Daily Spending Bar Chart)**:
  - Visualisasi pengeluaran 7 hari (Senin s.d. Minggu).
  - Garis benchmark/patokan batas rata-rata harian agar pengguna langsung sadar hari mana yang overbudget dan hari mana yang hemat.
  - Batang chart bisa di-tap untuk melihat ringkasan nominal hari tersebut.
- **Grafik Distribusi Kategori (Donut / Pie Chart)**:
  - Visualisasi proporsi pengeluaran dalam bentuk grafik cincin (donut chart) atau visual card interaktif yang menarik dan modern.
- **Performa & Animasi**:
  - Pastikan chart di-render ringan (60/120 FPS) dan tidak memberatkan saat pengguna melakukan swipe horizontal antar tab (*Minggu Ini*, *Bulan Ini*, *Semua*).

---

## Ringkasan Catatan untuk Tim / Agen AI

Saat memulai pengerjaan salah satu item di atas:
1. Gunakan dokumen ini sebagai pengingat area mana yang ingin disentuh dan masalah apa yang ingin diselesaikan.
2. Bebas berinovasi pada pemilihan widget, layout detail, curve animasi, dan estetika selama tetap selaras dengan *Pirsch design system* (minimalis, elegan, fokus data, zero clutter).
3. Selalu verifikasi bahwa perubahan UI tidak merusak fungsionalitas dan test suite yang ada.
