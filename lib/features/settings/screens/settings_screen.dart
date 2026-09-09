import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../budget/repository/budget_repository.dart';
import '../shopee_settings_screen.dart';
import 'budget_settings_detail_screen.dart';

class SettingsScreen extends StatefulWidget {
  final BudgetRepository repository;

  const SettingsScreen({super.key, required this.repository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _confirmResetData() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PirschColors.card(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Semua Riwayat?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text(
          'Seluruh data transaksi pengeluaran akan dihapus bersih. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal', style: TextStyle(color: PirschColors.textSecondary(isDark))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.repository.resetAllExpenses();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua catatan pengeluaran telah dibersihkan!'),
                    backgroundColor: PirschColors.mintGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PirschColors.red(isDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Bersih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: PirschColors.card(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PirschColors.textSecondary(isDark).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PirschColors.green(isDark).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.wallet_rounded, color: PirschColors.green(isDark), size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jajan Tracker',
                      style: TextStyle(
                        color: PirschColors.textPrimary(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Versi 1.0.0 (Production Release)',
                      style: TextStyle(
                        color: PirschColors.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Sistem budgeting mingguan adaptif yang otomatis mendistribusikan batas jajan harian secara self-correcting tanpa shock nominal, sehingga target tabungan selalu tercapai.',
              style: TextStyle(
                color: PirschColors.textSecondary(isDark),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PirschColors.pill(isDark),
                  foregroundColor: PirschColors.pillText(isDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                ),
                child: Text('Tutup', style: TextStyle(color: PirschColors.pillText(isDark), fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = PirschColors.bg(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Large Title (Reference: "Settings")
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Section 1: General (Unboxed, direct on background with dividers)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildSettingTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Atur Budget Mingguan',
                      subtitle: 'Uang mingguan, target tabungan & kuota',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BudgetSettingsDetailScreen(
                              repository: widget.repository,
                            ),
                          ),
                        );
                      },
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      showDivider: true,
                    ),
                    _buildSettingTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi & Shopee Watcher',
                      subtitle: 'Deteksi checkout, floating bubble & tile',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShopeeSettingsScreen(
                              repository: widget.repository,
                            ),
                          ),
                        );
                      },
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      showDivider: true,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Section 2: Data & Support (Unboxed, direct on background with dividers)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support & Data',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildSettingTile(
                      icon: Icons.delete_outline_rounded,
                      iconColor: PirschColors.red(isDark),
                      title: 'Hapus Riwayat Pengeluaran',
                      subtitle: 'Bersihkan seluruh catatan jajan minggu ini',
                      onTap: _confirmResetData,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      showDivider: true,
                    ),
                    _buildSettingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi 1.0.0 • Info sistem adaptive jajan',
                      onTap: _showAboutDialog,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      showDivider: true,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required bool showDivider,
  }) {
    final dividerColor = PirschColors.divider(isDark);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: iconColor ?? textPrimary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textSecondary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: dividerColor,
          ),
      ],
    );
  }
}
