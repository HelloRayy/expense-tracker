# Codebase Architecture & AI Agent Guidelines

Panduan arsitektur dan standar kualitas kode untuk AI Agent agar kode di proyek **Jajan Tracker (Expense Tracker)** selalu bersih, modular, konsisten, dan mudah dirawat.

---

## 1. Arsitektur Folder & Layering

Proyek menggunakan Feature-First Architecture:

- `lib/core/`:
  - `constants/`: Design tokens (`PirschColors`), typography, tema umum.
  - `database/`: `DbHelper` (SQLite singleton, skema database, migrasi versioning).
  - `services/`: `NativeBridge` (MethodChannel ke Android Home Widget & Services).
  - `theme/`: `ThemeController` (dark mode / light mode state manager).
  - `utils/`: Utility murni (`CurrencyFormatter`, helper tanggal).
- `lib/features/`:
  - `budget/`: Logika sentral perhitungan budget adaptif (`BudgetModel`, `BudgetRepository`).
  - `dashboard/`: Tampilan layar utama dan widget visual (`DashboardScreen`, `HeroBalanceCard`, dsb).
  - `categories/`: Manajemen kategori transaksi, normalizer, dan penugasan kategori massal.
  - `expense_catalog/`: Katalog preset jajan cepat.
  - `quick_log/`: Dialog input kalkulator pengeluaran cepat (`QuickLogDialog`, `CalculatorEvaluator`).
  - `settings/`: Layar pengaturan budget, dark mode, dan integrasi Shopee.
  - `widgets/`: Komponen preview native Android Widget.

---

## 2. Aturan Emas Maintainability (TNR Standards)

1. **Ukuran File Maksimal 500 Baris**:
   - Jika suatu file mendekati atau melebihi 500 baris, pecah komponen UI menjadi sub-widget terpisah di subfolder `widgets/` atau pisahkan business logic ke service evaluator di subfolder `services/`.
2. **Zero Spaghetti Conditionals**:
   - Jangan menyisipkan `if/else` ad-hoc di sembarang tempat. Tempatkan perhitungan logika bisnis di model domain atau service evaluator (misal: `calculateDailyAllowance`, `CalculatorEvaluator`).
3. **Layer Separation**:
   - UI Widget **dilarang** memanggil `DbHelper` secara langsung. Semua akses database dan kalkulasi harus melalui `BudgetRepository`.
4. **Single Source of Truth untuk Token Visual**:
   - Gunakan token `PirschColors` (misal `PirschColors.card(isDark)`, `PirschColors.mintGreen`, `PirschColors.textPrimary(isDark)`). Jangan melakukan hardcode warna hex acak di komponen UI.
5. **Atomic & Predictable State**:
   - Hindari manipulasi parsial. Jika memperbarui state budget, perbarui `BudgetModel` secara utuh via `repository.updateBudget()` atau `repository.confirmWeeklyBudget()`.

---

## 3. SQLite Database & Migration Rulebook

Setiap kali mengubah struktur tabel SQLite di `lib/core/database/db_helper.dart`:
1. Naikkan `version` pada `openDatabase`.
2. Tambahkan block migrasi di `onUpgrade` (`if (oldVersion < X)`).
3. **Wajib** tambahkan defensive check di `onOpen` (`_safeExecute(db, 'ALTER TABLE ...')`). Hal ini mencegah aplikasi crash jika database pengguna tertahan di versi lama atau partially updated.
4. Perbarui unit test migrasi di `test/database_migration_test.dart` agar test suite selalu memvalidasi skema baru.

---

## 4. Siklus Budget Mingguan & Akumulasi (Rollover)

- **Rentang Periode**:
  - Dimulai: Senin `00:00:00`
  - Berakhir: Minggu `23:59:59.999`
- **Rumus Budget**:
  - `totalBudget = weeklyIncome + carryoverBalance`
  - `spendableBudget = (weeklyIncome - weeklySavingsTarget) + carryoverBalance`
- **Rollover**:
  - Begitu waktu melewati Minggu 23:59:59, sistem menghitung surplus sisa belanja:
    `surplus = (spendableBudgetKemarin - totalSpentKemarin).clamp(0, spendableBudgetKemarin)`.
  - Periode baru ditandai `isPeriodConfirmed = false` sehingga memunculkan `WeeklyRolloverBanner` di Dashboard.

---

## 5. Sinkronisasi Native Android

- Setiap perubahan transaksi atau budget di Flutter memicu `_syncNative()` di `BudgetRepository`.
- `NativeBridge.instance.syncBalanceToNative()` mengirim key penting ke `SharedPreferences` Android:
  - `remaining_balance`
  - `total_budget`
  - `weekly_income`
  - `daily_safe`
  - `remaining_today`
  - `spent_today`
  - `total_spent`
- Native Widget provider di Android (`JajanWidgetProvider` dan `JajanWidget4x2Provider`) membaca data ini melalui `JajanWidgetStorage`.

---

## 6. Checklist Verifikasi AI Agent Sebelum Merge/Push

Setiap kali menyelesaikan task:
1. Jalankan `flutter analyze` dan pastikan **No issues found**.
2. Jalankan `flutter test` dan pastikan **All tests passed**.
3. Jalankan `git status` dan pastikan tidak ada file sampah/untracked temporer.
4. Lakukan auto-commit dan push:
   ```bash
   git add .
   git commit -m "<type>(<scope>): <pesan deskriptif>"
   git push
   ```
