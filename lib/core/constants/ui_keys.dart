import 'package:flutter/material.dart';

/// Centralized UI Keys for semantic widget lookup, automated testing,
/// and AI agent screenshot-to-code navigation.
///
/// See UI_MAP.md in the project root for visual mappings to each key.
abstract final class UIKeys {
  // --- Dashboard Screen ---
  static const dashboardScaffold = ValueKey('dashboard_scaffold');
  static const dashboardHeader = ValueKey('dashboard_header');
  static const dashboardRolloverBanner = ValueKey('dashboard_rollover_banner');
  static const dashboardHeroCard = ValueKey('dashboard_hero_card');
  static const dashboardActionBar = ValueKey('dashboard_action_bar');
  static const dashboardRecentActivityHeader = ValueKey('dashboard_recent_activity_header');
  static const dashboardRecentActivityToggle = ValueKey('dashboard_recent_activity_toggle');
  static const dashboardExpensesList = ValueKey('dashboard_expenses_list');
  static const dashboardFloatingNavbar = ValueKey('dashboard_floating_navbar');

  // --- Hero Balance Card Sub-Elements ---
  static const heroGreeting = ValueKey('hero_greeting');
  static const heroPeriodDropdown = ValueKey('hero_period_dropdown');
  static const heroPeriodDates = ValueKey('hero_period_dates');
  static const heroMenuButton = ValueKey('hero_menu_button');
  static const heroRemainingAmount = ValueKey('hero_remaining_amount');
  static const heroSingleWalletRow = ValueKey('hero_single_wallet_row');
  static const heroAccordionToggle = ValueKey('hero_accordion_toggle');
  static const heroEwalletBreakdown = ValueKey('hero_ewallet_breakdown');
  static const heroCashBreakdown = ValueKey('hero_cash_breakdown');
  static const heroSpentMetric = ValueKey('hero_spent_metric');

  // --- Quick Log Dialog Elements ---
  static const quickLogDialog = ValueKey('quick_log_dialog');
  static const quickLogTitle = ValueKey('quick_log_title');
  static const quickLogTodayLimit = ValueKey('quick_log_today_limit');
  static const quickLogExpressionDisplay = ValueKey('quick_log_expression_display');
  static const quickLogTotalPreview = ValueKey('quick_log_total_preview');
  static const quickLogWalletSelector = ValueKey('quick_log_wallet_selector');
  static const quickLogWalletEwallet = ValueKey('quick_log_wallet_ewallet');
  static const quickLogWalletCash = ValueKey('quick_log_wallet_cash');
  static const quickLogCategorySelector = ValueKey('quick_log_category_selector');
  static const quickLogKeypad = ValueKey('quick_log_keypad');

  // --- Balance Adjustment Sheet Elements ---
  static const balanceSheet = ValueKey('balance_sheet');
  static const balanceSheetWalletSelector = ValueKey('balance_sheet_wallet_selector');
  static const balanceSheetWalletEwallet = ValueKey('balance_sheet_wallet_ewallet');
  static const balanceSheetWalletCash = ValueKey('balance_sheet_wallet_cash');
  static const balanceSheetTabs = ValueKey('balance_sheet_tabs');
  static const balanceSheetTopUpInput = ValueKey('balance_sheet_top_up_input');
  static const balanceSheetRealBalanceInput = ValueKey('balance_sheet_real_balance_input');
  static const balanceSheetSubmitTopUp = ValueKey('balance_sheet_submit_top_up');
  static const balanceSheetSubmitAdjustment = ValueKey('balance_sheet_submit_adjustment');

  // --- Settings Screen Elements ---
  static const settingsScreen = ValueKey('settings_screen');
  static const settingsDarkModeTile = ValueKey('settings_dark_mode_tile');
  static const settingsAutoKiloTile = ValueKey('settings_auto_kilo_tile');
  static const settingsCashWalletTile = ValueKey('settings_cash_wallet_tile');
  static const settingsBudgetTile = ValueKey('settings_budget_tile');
  static const settingsShopeeTile = ValueKey('settings_shopee_tile');
  static const settingsResetTile = ValueKey('settings_reset_tile');
  static const settingsAboutTile = ValueKey('settings_about_tile');

  // --- Expense Catalog Elements ---
  static const catalogScreen = ValueKey('catalog_screen');
  static const catalogLiveHeader = ValueKey('catalog_live_header');
  static const catalogCategoryFilter = ValueKey('catalog_category_filter');
  static const catalogAddPresetBtn = ValueKey('catalog_add_preset_btn');
  static const catalogPresetGrid = ValueKey('catalog_preset_grid');

  // --- Category Assignment Elements ---
  static const categoryAssignScreen = ValueKey('category_assign_screen');
  static const categoryAssignTabBar = ValueKey('category_assign_tab_bar');
  static const categoryAssignList = ValueKey('category_assign_list');
  static const categoryAssignSaveBar = ValueKey('category_assign_save_bar');

  // --- Home Widget 4x2 ---
  static const homeWidget4x2Card = ValueKey('home_widget_4x2_card');

  // --- Rekap Elements ---
  static const rekapScreen = ValueKey('rekap_screen');
  static const rekapPeriodTabBar = ValueKey('rekap_period_tab_bar');
  static const rekapSummaryCard = ValueKey('rekap_summary_card');
  static const rekapCategoryBreakdown = ValueKey('rekap_category_breakdown');
  static const rekapWalletBreakdown = ValueKey('rekap_wallet_breakdown');
  static const rekapTopExpensesList = ValueKey('rekap_top_expenses_list');
}
