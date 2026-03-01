import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../view_models/passport_view_model.dart';


/// PassportView — Visa Explorer screen (View layer in MVVM).
/// Two tabs: SCAN (OCR) and MANUAL (country dropdown).
class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PassportViewModel()..loadCountries(),
      child: const _PassportBody(),
    );
  }
}

class _PassportBody extends StatefulWidget {
  const _PassportBody();

  @override
  State<_PassportBody> createState() => _PassportBodyState();
}

class _PassportBodyState extends State<_PassportBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _scrollCtrl = ScrollController();
  bool _isCollapsed = false;
  static const double _expandedHeight = 180;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final threshold = _expandedHeight - kToolbarHeight - 20;
    final collapsed =
        _scrollCtrl.hasClients && _scrollCtrl.offset > threshold;
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PassportViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── Hero SliverAppBar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _expandedHeight,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryDark,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            // Title visible only when collapsed
            title: AnimatedOpacity(
              opacity: _isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.book_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Visa Explorer',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            actions: [
              if (vm.state == PassportState.success)
                TextButton(
                  onPressed: () => vm.reset(),
                  child: Text('Reset',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              const SizedBox(width: 8),
            ],
            // Hero in background only — no FlexibleSpaceBar title
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF002171), Color(0xFF0D47A1), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20, right: -20,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30, left: -20,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.5),
                              ),
                              child: const Icon(Icons.public_rounded,
                                  color: Colors.white, size: 26),
                            ).animate().scale(
                                begin: const Offset(0.8, 0.8),
                                curve: Curves.elasticOut,
                                duration: 700.ms),
                            const SizedBox(height: 10),
                            Text('Visa Explorer 🌍',
                                style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800))
                                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
                            const SizedBox(height: 2),
                            Text('Check visa-free countries for your passport',
                                style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 12))
                                .animate(delay: 200.ms).fadeIn(duration: 400.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle:
                          GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: const [
                        Tab(text: '📷  Scan Passport'),
                        Tab(text: '🔍  Manual Lookup'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tab view content (fixed height)
                  SizedBox(
                    height: 900,
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _ScanTab(vm: vm),
                        _ManualTab(vm: vm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — OCR Passport Scan
// ═══════════════════════════════════════════════════════════════════════════════

class _ScanTab extends StatelessWidget {
  final PassportViewModel vm;
  const _ScanTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF0057FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.document_scanner_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Passport Scanner',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text(
                        'Take or upload a passport photo. Our OCR engine detects your country automatically.',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (vm.state == PassportState.success && vm.result != null) ...[
            _ScanResultBadge(result: vm.result!),
            const SizedBox(height: 16),
            _ResultsView(result: vm.result!),
          ] else ...[
            _ImagePickerCard(vm: vm),
            const SizedBox(height: 16),

            if (vm.scanError.isNotEmpty) ...[
              _ErrorBanner(message: vm.scanError),
              const SizedBox(height: 16),
            ],

            _ScanTips(),
          ],
        ],
      ),
    );
  }
}

class _ScanResultBadge extends StatelessWidget {
  final PassportResult result;
  const _ScanResultBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = (result.confidence * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detected: ${result.country}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              if (result.confidence > 0)
                Text('OCR Confidence: $pct%',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  final PassportViewModel vm;
  const _ImagePickerCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Passport Photo',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () => _showSourceSheet(context, vm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: vm.pickedImage != null
                      ? AppColors.primary
                      : AppColors.divider,
                  width: vm.pickedImage != null ? 2 : 1,
                ),
              ),
              child: vm.pickedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(
                        vm.pickedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(height: 10),
                        const Text('Tap to take or upload photo',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Text('Supports JPG, PNG, WEBP • Max 10MB',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted)),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => vm.pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => vm.pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),

          if (vm.pickedImage != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: vm.scanLoading
                      ? null
                      : const LinearGradient(
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF0057FF)
                          ]),
                  color: vm.scanLoading ? AppColors.divider : null,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                  ),
                  onPressed: vm.scanLoading
                      ? null
                      : () => vm.scanPassport(),
                  icon: vm.scanLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.document_scanner_rounded,
                          color: Colors.white, size: 18),
                  label: Text(
                    vm.scanLoading
                        ? 'Scanning with OCR...'
                        : 'Scan Passport',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSourceSheet(BuildContext context, PassportViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const Text('Choose Image Source',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ScanTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      'Place passport flat on a bright surface',
      'Ensure the text is clearly visible & in focus',
      'Avoid glare and shadows on the image',
      'The photo page works best for detection',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: AppColors.warning, size: 16),
              SizedBox(width: 8),
              Text('Tips for best results',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.success, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tip,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — Manual Country Selection
// ═══════════════════════════════════════════════════════════════════════════════

class _ManualTab extends StatelessWidget {
  final PassportViewModel vm;
  const _ManualTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(),
          const SizedBox(height: 20),

          if (vm.loadingCountries)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...[
            _CountrySelector(vm: vm),
            const SizedBox(height: 16),

            if (vm.state != PassportState.success)
              _LookupButton(vm: vm),

            if (vm.state == PassportState.error) ...[
              const SizedBox(height: 16),
              _ErrorBanner(message: vm.error),
            ],

            if (vm.state == PassportState.success && vm.result != null) ...[
              const SizedBox(height: 20),
              _ResultsView(result: vm.result!),
            ],
          ],
        ],
      ),
    );
  }
}

// ─── Hero ──────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF0057FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.public_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Passport Power Index',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text(
                  'Select your passport country to see how many destinations you can visit visa-free.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Country Selector ─────────────────────────────────────────────────────────

class _CountrySelector extends StatelessWidget {
  final PassportViewModel vm;
  const _CountrySelector({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Your Passport Country',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: vm.selectedCountry.isNotEmpty
                    ? vm.selectedCountry
                    : null,
                hint: const Text('Choose a country',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 14)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted),
                dropdownColor: Colors.white,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                onChanged: (v) {
                  if (v != null) vm.setSelectedCountry(v);
                },
                items: vm.availablePassports
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lookup Button ─────────────────────────────────────────────────────────────

class _LookupButton extends StatelessWidget {
  final PassportViewModel vm;
  const _LookupButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    final canLookup = vm.selectedCountry.isNotEmpty && !vm.loading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: canLookup
              ? const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF0057FF)])
              : null,
          color: canLookup ? null : AppColors.divider,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: canLookup ? () => vm.lookup() : null,
          icon: vm.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.search_rounded,
                  color: Colors.white, size: 20),
          label: Text(
            vm.loading
                ? 'Checking...'
                : vm.selectedCountry.isEmpty
                    ? 'Select a country first'
                    : 'Check Visa-Free Countries',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// ─── Shared: Error Banner ──────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 13, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Results View (premium fl_chart edition) ──────────────────────────

class _ResultsView extends StatelessWidget {
  final PassportResult result;
  const _ResultsView({required this.result});

  static const List<Color> _pieColors = [
    Color(0xFF0057FF), Color(0xFF7C3AED), Color(0xFF00C9A7),
    Color(0xFFFF6F00), Color(0xFFE91E63), Color(0xFF009688),
    Color(0xFF795548), Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Big count hero ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00875A), Color(0xFF1DB954), Color(0xFF00C9A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 7)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.public_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.visaFreeCountries.length}',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1),
                    ),
                    Text(
                      'Visa-Free Destinations',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${result.country} passport',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .scale(
                begin: const Offset(0.95, 0.95),
                curve: Curves.easeOut,
                duration: 500.ms)
            .fadeIn(duration: 400.ms),

        // ── fl_chart Pie Chart ────────────────────────────────────────────────
        if (result.regionBreakdown.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Breakdown by Region',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                // Pie chart
                SizedBox(
                  width: 130,
                  height: 130,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: result.regionBreakdown.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final color = _pieColors[i % _pieColors.length];
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          color: color,
                          radius: 32,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result.regionBreakdown.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      final color = _pieColors[i % _pieColors.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(e.key,
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text('${e.value}',
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: color)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
        ],

        // ── Country list ─────────────────────────────────────────────────────
        const SizedBox(height: 20),
        Text('Accessible Destinations',
            style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.visaFreeCountries.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (_, i) {
              final country = result.visaFreeCountries[i];
              final flag = result.flags[country] ?? '🌍';
              return ListTile(
                dense: true,
                leading: Text(flag,
                    style: const TextStyle(fontSize: 22)),
                title: Text(country,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                trailing: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 14),
                ),
              )
                  .animate(delay: (30 * i).ms)
                  .fadeIn(duration: 200.ms)
                  .slideX(begin: 0.05);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
