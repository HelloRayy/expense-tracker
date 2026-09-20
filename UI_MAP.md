# UI Map: AI Screenshot & Visual Component Navigation Guide

This document is the **visual index and component directory** for the Expense Tracker application.
When the user provides a **screenshot**, **mockup**, or describes a **visual element** to modify, find the corresponding visual pattern in the lookup tables and wireframes below to identify the exact file, widget, and state controller.

---

## 1. Screenshot Quick Lookup Table

| Visual Signature in Screenshot | Screenshot Artifact Name | Screen / Widget Class | File Path | State Controller / Store |
| :--- | :--- | :--- | :--- | :--- |
| Main view with large balance card, daily allowance, recent transactions, bottom floating bar | `actual_pirsch_dashboard_dark.png`<br/>`actual_pirsch_dashboard_light.png` | `DashboardScreen` | [`lib/features/dashboard/dashboard_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/dashboard_screen.dart) | `BudgetRepository`<br/>`ThemeController` |
| Hero card showing single wallet row with pencil icon | `actual_pirsch_dashboard_dark.png` | `HeroBalanceCard` (Single) | [`lib/features/dashboard/widgets/hero_balance_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/hero_balance_card.dart) | `BudgetRepository` |
| Hero card showing accordion expanded with E-Wallet & Cash rows | `actual_pirsch_dashboard_expanded.png` | `HeroBalanceCard` (Multi) | [`lib/features/dashboard/widgets/hero_balance_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/hero_balance_card.dart) | `BudgetRepository` |
| Calculator dialog with numeric keypad, expression display, category pills, wallet toggle | `actual_pirsch_quick_log.png`<br/>`actual_pirsch_quick_log_warning.png` | `QuickLogDialog` | [`lib/features/quick_log/quick_log_dialog.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/quick_log/quick_log_dialog.dart) | `BudgetRepository` |
| Modal sheet with tabs: "Top Up Saldo" and "Sesuaikan Saldo Riil", wallet radio chips | Balance Adjustment | `BalanceAdjustmentSheet` | [`lib/features/dashboard/widgets/balance_adjustment_sheet.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/balance_adjustment_sheet.dart) | `BudgetRepository` |
| Settings list with Dark Mode switch, Multi-Wallet toggle, Shopee Watcher, Reset | `actual_settings_screen.png`<br/>`actual_settings_screen_light.png` | `SettingsScreen` | [`lib/features/settings/screens/settings_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/settings/screens/settings_screen.dart) | `ThemeController`<br/>`BudgetRepository` |
| Budget calculation settings: weekly allowance, start day, reset rollover | `actual_budget_settings_detail.png`<br/>`actual_budget_settings_detail_light.png` | `BudgetSettingsScreen` | [`lib/features/settings/screens/budget_settings_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/settings/screens/budget_settings_screen.dart) | `BudgetRepository` |
| 2-column grid cards of quick expenses ("Kopi Kenangan 18k", "+ Buat Kartu") | `actual_expense_catalog_dark.png`<br/>`actual_expense_catalog_light.png` | `ExpenseCatalogScreen` | [`lib/features/expense_catalog/screens/expense_catalog_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/expense_catalog/screens/expense_catalog_screen.dart) | `BudgetRepository` |
| Horizontal tabs (Makanan, Transport, Belanja) with checkboxes per transaction | `actual_category_assignment_dark.png`<br/>`actual_category_assignment_light.png` | `CategoryAssignmentScreen` | [`lib/features/categories/screens/category_assignment_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/categories/screens/category_assignment_screen.dart) | `BudgetRepository` |
| Expense recap with bottom floating capsule dock (Minggu Ini, Bulan Ini, Semua), native horizontal PageView slide, category breakdown bar, wallet distribution, and top expenses | Rekap Pengeluaran | `RekapScreen` | [`lib/features/rekap/screens/rekap_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/rekap/screens/rekap_screen.dart) | `BudgetRepository` |
| 4x2 Android Home Screen Widget showing daily jajan allowance & weekly income/expense | `actual_widget_4x2_dark.png`<br/>`actual_widget_4x2_light.png` | `HomeWidget4x2Card` | [`lib/features/widgets/home_widget_4x2_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/widgets/home_widget_4x2_card.dart) | Native Android Widget Data |

---

## 2. Visual Wireframes & Component Trees

### 2.1 Dashboard Screen (`DashboardScreen`)
File: [`lib/features/dashboard/dashboard_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/dashboard_screen.dart)
Scaffold Key: `UIKeys.dashboardScaffold`

```
+-----------------------------------------------------------+
| [UIKeys.dashboardHeader]                                  |
| "Halo, Raditya"                          (Settings Icon)  |
| "Siap hemat minggu ini?"                                  |
+-----------------------------------------------------------+
| [UIKeys.dashboardRolloverBanner] (Conditional Warning)    |
| ! Kemarin over budget Rp 25.000 (diserap jatah hari ini)  |
+-----------------------------------------------------------+
| [UIKeys.dashboardHeroCard]                                |
|  +-----------------------------------------------------+  |
|  | [UIKeys.heroGreeting] [Period Dropdown]  [...] Menu |  |
|  | SISA SALDO JAJAN HARI INI                           |  |
|  | [UIKeys.heroRemainingAmount] Rp 85.000 /hari        |  |
|  | [UIKeys.heroTomorrowAllowance] Besok max: Rp 85.000 |  |
|  | --------------------------------------------------- |  |
|  | [UIKeys.heroSingleWalletRow] Saldo: Rp 350.000 [Pen]|  |
|  |  OR (if multi-wallet enabled)                       |  |
|  | [UIKeys.heroAccordionToggle] [UIKeys.heroSpentMetric]|  |
|  |  v [UIKeys.heroEwalletBreakdown] E-Wallet: 300k     |  |
|  |    [UIKeys.heroCashBreakdown]    Cash: 50k          |  |
|  +-----------------------------------------------------+  |
+-----------------------------------------------------------+
| [UIKeys.dashboardActionBar]                               |
| [ + Catat Cepat ]      [ Rekap ]       [ Kategori ]       |
+-----------------------------------------------------------+
| [UIKeys.dashboardRecentActivityHeader]                    |
| Riwayat Transaksi                                         |
| [UIKeys.dashboardRecentActivityToggle] [Hari Ini | Semua] |
| --------------------------------------------------------- |
| [TransactionTile] Kopi Kenangan              -Rp 18.000   |
| [TransactionTile] Makan Siang Padang         -Rp 25.000   |
+-----------------------------------------------------------+
| [UIKeys.dashboardFloatingNavbar] (Floating Glass Pill)    |
| [Home Icon]             [Plus Quick Log]       [Settings] |
+-----------------------------------------------------------+
```

### 2.2 Quick Log Calculator Dialog (`QuickLogDialog`)
File: [`lib/features/quick_log/quick_log_dialog.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/quick_log/quick_log_dialog.dart)
Keypad Component: [`lib/features/quick_log/widgets/quick_log_keypad.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/quick_log/widgets/quick_log_keypad.dart)
Dialog Key: `UIKeys.quickLogDialog`

```
+-----------------------------------------------------------+
| [UIKeys.quickLogTitle] "Catat Pengeluaran"          [ X ] |
| [UIKeys.quickLogTodayLimit] Sisa Hari Ini: Rp 85.000      |
+-----------------------------------------------------------+
| [UIKeys.quickLogExpressionDisplay]                        |
|   15000 + 12000                                           |
| [UIKeys.quickLogTotalPreview]                             |
|   = Rp 27.000                                             |
+-----------------------------------------------------------+
| [UIKeys.quickLogWalletSelector] (Conditional if multi-wal)|
|   (o) [UIKeys.quickLogWalletEwallet] E-Wallet             |
|   ( ) [UIKeys.quickLogWalletCash] Cash                    |
+-----------------------------------------------------------+
| [UIKeys.quickLogCategorySelector]                         |
|   [Makanan] [Kopi/Minum] [Transport] [Belanja] [Lainnya]  |
+-----------------------------------------------------------+
| [UIKeys.quickLogKeypad]                                   |
|   [ 7 ]    [ 8 ]    [ 9 ]    [ / ]                        |
|   [ 4 ]    [ 5 ]    [ 6 ]    [ * ]                        |
|   [ 1 ]    [ 2 ]    [ 3 ]    [ - ]                        |
|   [ C ]    [ 0 ]    [ . ]    [ + ]                        |
|   [             SIMPAN (✓)               ]                |
+-----------------------------------------------------------+
```

### 2.3 Balance Adjustment Sheet (`BalanceAdjustmentSheet`)
File: [`lib/features/dashboard/widgets/balance_adjustment_sheet.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/balance_adjustment_sheet.dart)
Sheet Key: `UIKeys.balanceSheet`

```
+-----------------------------------------------------------+
| (Drag Handle)                                             |
| Sesuaikan Saldo Dompet                              [ X ] |
|                                                           |
| [UIKeys.balanceSheetWalletSelector]                       |
|   (o) [UIKeys.balanceSheetWalletEwallet] E-Wallet         |
|   ( ) [UIKeys.balanceSheetWalletCash] Cash (Tunai)        |
|                                                           |
| [UIKeys.balanceSheetTabs]                                 |
|   [ Top Up Saldo ]       |     [ Sesuaikan Saldo Riil ]   |
| --------------------------------------------------------- |
| (If Top Up tab active):                                   |
|  Nominal Top Up:                                          |
|  [UIKeys.balanceSheetTopUpInput] [ Rp 50.000            ] |
|  [UIKeys.balanceSheetSubmitTopUp] [ Tambah Saldo       ]  |
|                                                           |
| (If Real Balance tab active):                             |
|  Saldo Riil Saat Ini:                                     |
|  [UIKeys.balanceSheetRealBalanceInput] [ Rp 350.000     ] |
|  * Selisih akan otomatis dicatat sebagai penyesuaian      |
|  [UIKeys.balanceSheetSubmitAdjustment] [ Simpan Saldo  ]  |
+-----------------------------------------------------------+
```

### 2.4 Settings Screen (`SettingsScreen`)
File: [`lib/features/settings/screens/settings_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/settings/screens/settings_screen.dart)
Screen Key: `UIKeys.settingsScreen`

```
+-----------------------------------------------------------+
| [< Back]                                                  |
| Settings                                                  |
|                                                           |
| GENERAL                                                   |
| [UIKeys.settingsDarkModeTile]   Mode Gelap         [Toggle]|
| [UIKeys.settingsAutoKiloTile]   Auto-Kilo (k/rb)   [Toggle]|
| [UIKeys.settingsCashWalletTile] Multi-Wallet Tunai [Toggle]|
| [UIKeys.settingsBudgetTile]     Pengaturan Budget       > |
| [UIKeys.settingsShopeeTile]     Shopee Watcher & Bubble > |
|                                                           |
| SUPPORT & DATA                                            |
| [UIKeys.settingsResetTile]      Hapus Riwayat Pengeluaran |
| [UIKeys.settingsAboutTile]      Tentang Aplikasi        > |
+-----------------------------------------------------------+
```

### 2.5 Expense Catalog ("Masukin Kartu") (`ExpenseCatalogScreen`)
File: [`lib/features/expense_catalog/screens/expense_catalog_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/expense_catalog/screens/expense_catalog_screen.dart)
Screen Key: `UIKeys.catalogScreen`

```
+-----------------------------------------------------------+
| [< Back]  [UIKeys.catalogLiveHeader]                      |
|           Sisa Hari Ini: Rp 85.000                        |
+-----------------------------------------------------------+
| [Semua] [Makanan] [Transportasi] [Lainnya]  [UIKeys.addBtn]|
+-----------------------------------------------------------+
| [UIKeys.catalogPresetGrid] (2-Column Grid)                |
|  +--------------------+    +--------------------+         |
|  | Kopi Kenangan      |    | Nasi Padang        |         |
|  | Rp 18.000          |    | Rp 25.000          |         |
|  | [ + Tap to Log ]   |    | [ + Tap to Log ]   |         |
|  +--------------------+    +--------------------+         |
|  +--------------------+    +--------------------+         |
|  | Chatime            |    | Bensin Motor       |         |
|  | Rp 24.000          |    | Rp 20.000          |         |
|  | [ + Tap to Log ]   |    | [ + Tap to Log ]   |         |
|  +--------------------+    +--------------------+         |
+-----------------------------------------------------------+
```

### 2.6 Category Assignment Screen (`CategoryAssignmentScreen`)
File: [`lib/features/categories/screens/category_assignment_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/categories/screens/category_assignment_screen.dart)
Screen Key: `UIKeys.categoryAssignScreen`

```
+-----------------------------------------------------------+
| [< Back]                                                  |
| Makanan & Minuman                          Total: Rp 145k |
| Centang transaksi untuk memasukkan ke kategori ini.       |
|                                                           |
| [UIKeys.categoryAssignTabBar]                             |
| [ Makanan ]   [ Kopi & Minum ]   [ Transport ]  [ Belanja]|
+-----------------------------------------------------------+
| [UIKeys.categoryAssignList]                               |
| [x] Nasi Padang Siang              Rp 25.000   14:20      |
| [ ] Bensin Pertalite               Rp 20.000   11:00      |
| [x] Ayam Geprek                    Rp 18.000   Kemarin    |
+-----------------------------------------------------------+
| [UIKeys.categoryAssignSaveBar] (Slides up when dirty)     |
| [            Simpan (2 Perubahan)                       ] |
+-----------------------------------------------------------+
```

---

## 3. Fast Modification Recipes (Where to Edit)

| User Modification Request | Target File to Edit | Key Class or Method |
| :--- | :--- | :--- |
| **Change Daily Remaining calculation or rollover math** | [`lib/features/budget/repository/budget_repository.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/budget/repository/budget_repository.dart) | `remainingToday`, `dailyAllowance`, `calculateRollover` |
| **Change Hero Card styling, font size, or wallet layout** | [`lib/features/dashboard/widgets/hero_balance_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/hero_balance_card.dart) | `HeroBalanceCard.build` |
| **Change Calculator keypad layout, button shapes, or math ops** | [`lib/features/quick_log/widgets/quick_log_keypad.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/quick_log/widgets/quick_log_keypad.dart) | `_buildKeyButton`, `onKeyPressed` |
| **Change Quick Log dialog header, limits, or category icons** | [`lib/features/quick_log/quick_log_dialog.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/quick_log/quick_log_dialog.dart) | `QuickLogDialog._buildCategoryPill` |
| **Change Balance Top-up or Adjustment sheet fields** | [`lib/features/dashboard/widgets/balance_adjustment_sheet.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/widgets/balance_adjustment_sheet.dart) | `_buildTopUpTab`, `_buildAdjustmentTab` |
| **Change Floating Navigation Bar items or actions** | [`lib/features/dashboard/dashboard_screen.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/dashboard/dashboard_screen.dart) | `_FloatingGlassNavBar` |
| **Change Preset Catalog default cards** | [`lib/features/expense_catalog/models/expense_preset_model.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/expense_catalog/models/expense_preset_model.dart) | `ExpensePresetModel.defaultPresets` |
| **Change Color Scheme, Dark/Light Mode palette** | [`lib/core/constants/app_colors.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/core/constants/app_colors.dart) | `PirschColors` |
| **Change Android Home Screen Widget design** | [`lib/features/widgets/home_widget_4x2_card.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/widgets/home_widget_4x2_card.dart) | `HomeWidget4x2Card.build` |
| **Add or remove a Category** | [`lib/features/categories/models/expense_category.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/features/categories/models/expense_category.dart) | `ExpenseCategory.all` |

---

## 4. UIKeys Index

All semantic keys are defined in [`lib/core/constants/ui_keys.dart`](file:///home/rayhan/Windows-D/project/expense-tracker/lib/core/constants/ui_keys.dart):

```dart
// Dashboard
UIKeys.dashboardScaffold
UIKeys.dashboardHeader
UIKeys.dashboardRolloverBanner
UIKeys.dashboardHeroCard
UIKeys.dashboardActionBar
UIKeys.dashboardRecentActivityHeader
UIKeys.dashboardRecentActivityToggle
UIKeys.dashboardFloatingNavbar

// Hero Card
UIKeys.heroGreeting
UIKeys.heroPeriodDropdown
UIKeys.heroPeriodDates
UIKeys.heroMenuButton
UIKeys.heroRemainingAmount
UIKeys.heroTomorrowAllowance
UIKeys.heroSingleWalletRow
UIKeys.heroAccordionToggle
UIKeys.heroSpentMetric
UIKeys.heroEwalletBreakdown
UIKeys.heroCashBreakdown

// Quick Log Dialog
UIKeys.quickLogDialog
UIKeys.quickLogTitle
UIKeys.quickLogTodayLimit
UIKeys.quickLogExpressionDisplay
UIKeys.quickLogTotalPreview
UIKeys.quickLogWalletSelector
UIKeys.quickLogWalletEwallet
UIKeys.quickLogWalletCash
UIKeys.quickLogCategorySelector
UIKeys.quickLogKeypad

// Balance Adjustment Sheet
UIKeys.balanceSheet
UIKeys.balanceSheetWalletSelector
UIKeys.balanceSheetWalletEwallet
UIKeys.balanceSheetWalletCash
UIKeys.balanceSheetTabs
UIKeys.balanceSheetTopUpInput
UIKeys.balanceSheetSubmitTopUp
UIKeys.balanceSheetRealBalanceInput
UIKeys.balanceSheetSubmitAdjustment

// Settings Screen
UIKeys.settingsScreen
UIKeys.settingsDarkModeTile
UIKeys.settingsAutoKiloTile
UIKeys.settingsCashWalletTile
UIKeys.settingsBudgetTile
UIKeys.settingsShopeeTile
UIKeys.settingsResetTile
UIKeys.settingsAboutTile

// Expense Catalog
UIKeys.catalogScreen
UIKeys.catalogLiveHeader
UIKeys.catalogAddPresetBtn
UIKeys.catalogPresetGrid

// Category Assignment
UIKeys.categoryAssignScreen
UIKeys.categoryAssignTabBar
UIKeys.categoryAssignList
UIKeys.categoryAssignSaveBar

// Home Widget
UIKeys.homeWidget4x2Card

// Rekap
UIKeys.rekapScreen
UIKeys.rekapPeriodTabBar
UIKeys.rekapSummaryCard
UIKeys.rekapCategoryBreakdown
UIKeys.rekapWalletBreakdown
UIKeys.rekapTopExpensesList
```
