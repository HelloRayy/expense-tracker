import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/native_bridge.dart';
import '../../core/utils/currency_formatter.dart';
import '../budget/repository/budget_repository.dart';

class ShopeeSettingsScreen extends StatefulWidget {
  final BudgetRepository repository;

  const ShopeeSettingsScreen({super.key, required this.repository});

  @override
  State<ShopeeSettingsScreen> createState() => _ShopeeSettingsScreenState();
}

class _ShopeeSettingsScreenState extends State<ShopeeSettingsScreen>
    with WidgetsBindingObserver {
  final NativeBridge _bridge = NativeBridge.instance;
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);
    final overlay = await _bridge.checkOverlayPermission();
    final access = await _bridge.checkAccessibilityPermission();
    if (mounted) {
      setState(() {
        _hasOverlayPermission = overlay;
        _hasAccessibilityPermission = access;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.repository.remainingBalance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'ShopeePay Nudge Reminder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info Banner Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('🛍️', style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pre-Transaction Nudge',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pengingat sadar sisa saldo sebelum belanja',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '1. Saat aplikasi Shopee dibuka, notifikasi atas & chip mengambang otomatis mengingatkan sisa saldo jajanmu.\n2. Saat kamu menekan tombol "Bayar QRIS" atau ShopeePay di kasir, pengingat langsung meluncur tepat di atas kamera scanner!\n3. Tersedia juga tombol pintasan di Control Center (tarik panel atas HP) untuk Quick-Log kapan saja.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'IZIN YANG DIBUTUHKAN',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                // Permission Item 1: Overlay
                _permissionTile(
                  title: 'Tampilkan di Atas Aplikasi Lain',
                  description:
                      'Dibutuhkan untuk menampilkan floating reminder di atas Shopee.',
                  isGranted: _hasOverlayPermission,
                  onAction: () async {
                    await _bridge.openOverlaySettings();
                  },
                ),
                const SizedBox(height: 12),

                // Permission Item 2: Accessibility
                _permissionTile(
                  title: 'Layanan Aksesibilitas (Jajan Watcher)',
                  description:
                      'Dibutuhkan agar Android memberi tahu saat aplikasi Shopee dibuka.',
                  isGranted: _hasAccessibilityPermission,
                  onAction: () async {
                    await _bridge.openAccessibilitySettings();
                  },
                ),
                const SizedBox(height: 24),

                // Test floating reminder button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Coba Tampilan Pengingat',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Uji coba tampilan floating chip dengan saldo saat ini (${CurrencyFormatter.format(balance)})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (!_hasOverlayPermission) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Harap izinkan "Tampilkan di Atas Aplikasi Lain" terlebih dahulu.',
                                  ),
                                ),
                              );
                              return;
                            }
                            await _bridge.showShopeeFloatingTest(balance);
                          },
                          icon: const Icon(Icons.touch_app, size: 18),
                          label: const Text('Simulasi Buka Shopee (Munculkan Chip)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _permissionTile({
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? AppColors.primary.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle : Icons.error_outline,
                color: isGranted ? AppColors.primary : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                backgroundColor: isGranted
                    ? AppColors.surfaceLight.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isGranted ? 'Cek Pengaturan' : 'Beri Izin Sekarang',
                style: TextStyle(
                  color: isGranted ? AppColors.textMuted : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
