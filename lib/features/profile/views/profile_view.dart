import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main_shell.dart';
import '../view_models/profile_view_model.dart';

/// ProfileView — MVVM View for the Profile feature.
///
/// MVVM Rule: View reads state from ProfileViewModel via Provider.
/// No business logic here — all state lives in ProfileViewModel.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // Helpers
  static const _comfortLabels = [
    'Budget', 'Economy', 'Premium', 'Business', 'First'
  ];
  static const _comfortIcons = [
    Icons.savings_rounded,
    Icons.airline_seat_recline_normal_rounded,
    Icons.airline_seat_recline_extra_rounded,
    Icons.business_center_rounded,
    Icons.workspace_premium_rounded,
  ];

  static String _fmt(double d) {
    if (d >= 100000) return '₹${(d / 100000).toStringAsFixed(1)}L';
    if (d >= 1000) return '₹${(d / 1000).toStringAsFixed(0)}K';
    return '₹${d.toStringAsFixed(0)}';
  }

  static Color _comfortColor(int level) {
    const colors = [
      Color(0xFF64748B),
      AppColors.primary,
      AppColors.accent,
      Color(0xFFF59E0B),
      Color(0xFFE53935),
    ];
    return colors[level.clamp(0, 4)];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final classLabel = ProfileView._comfortLabels[vm.comfortLevel.round()];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero AppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _ProfileHero(
                initial: vm.initial,
                name: vm.displayName,
                email: vm.email,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Account details card ──────────────────────────────────────
                _SectionCard(
                  title: 'Account Details',
                  icon: Icons.person_rounded,
                  child: Column(
                    children: [
                      _InfoTile(
                          icon: Icons.badge_rounded,
                          label: 'Name',
                          value: vm.displayName),
                      _InfoTile(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: vm.email),
                      _InfoTile(
                          icon: Icons.travel_explore_rounded,
                          label: 'Travel Class',
                          value: classLabel),
                      _InfoTile(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Budget Range',
                          value: '${ProfileView._fmt(vm.budget)} per trip',
                          isLast: true),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 16),

                // ── Travel preferences card (sliders) ──────────────────────
                _SectionCard(
                  title: 'Travel Preferences',
                  icon: Icons.tune_rounded,
                  child: Builder(builder: (context) {
                    final vm2 = context.watch<ProfileViewModel>();
                    final label =
                        ProfileView._comfortLabels[vm2.comfortLevel.round()];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Budget slider
                        _LabelRow(
                          label: 'Budget per Trip',
                          value: ProfileView._fmt(vm2.budget),
                          valueColor: AppColors.primary,
                        ),
                        const SizedBox(height: 4),
                        _AppSlider(
                          value: vm2.budget,
                          min: 5000,
                          max: 500000,
                          divisions: 99,
                          color: AppColors.primary,
                          onChanged: vm2.setBudget,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹5K',
                                style: GoogleFonts.outfit(
                                    fontSize: 10, color: AppColors.textMuted)),
                            Text('₹5L',
                                style: GoogleFonts.outfit(
                                    fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Comfort slider
                        _LabelRow(
                          label: 'Travel Comfort Level',
                          value: label,
                          valueColor: ProfileView._comfortColor(
                              vm2.comfortLevel.round()),
                        ),
                        const SizedBox(height: 4),
                        _AppSlider(
                          value: vm2.comfortLevel,
                          min: 0,
                          max: 4,
                          divisions: 4,
                          color: ProfileView._comfortColor(
                              vm2.comfortLevel.round()),
                          onChanged: vm2.setComfortLevel,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Budget',
                                style: GoogleFonts.outfit(
                                    fontSize: 10, color: AppColors.textMuted)),
                            Text('First Class',
                                style: GoogleFonts.outfit(
                                    fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),

                        const SizedBox(height: 12),
                        _ComfortIndicator(
                          level: vm2.comfortLevel.round(),
                          labels: ProfileView._comfortLabels,
                          icons: ProfileView._comfortIcons,
                        ),
                      ],
                    );
                  }),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 16),

                // ── App Settings card ───────────────────────────────────────
                _SectionCard(
                  title: 'App Settings',
                  icon: Icons.settings_rounded,
                  child: _ToggleTile(
                    icon: Icons.notifications_rounded,
                    label: 'Push Notifications',
                    subtitle: 'Alerts for deals & travel reminders',
                    value: vm.notifications,
                    onChanged: vm.setNotifications,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 24),

                // ── Logout button ───────────────────────────────────────────
                _LogoutButton(
                  onPressed: () => showLogoutDialog(context),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'RoamGenie v1.0.0 · Made with ✈️ & ❤️',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero header ─────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final String initial;
  final String name;
  final String email;

  const _ProfileHero({
    required this.initial,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    'RoamGenie Traveler',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section card wrapper ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                   title,
                   style: GoogleFonts.outfit(
                     fontSize: 14,
                     fontWeight: FontWeight.w700,
                     color: AppColors.textPrimary,
                   ),
                 ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Info tile ────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppColors.textSecondary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ─── Label row (slider header) ────────────────────────────────────────────────

class _LabelRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _LabelRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: valueColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ),
      ],
    );
  }
}

// ─── Custom slider ────────────────────────────────────────────────────────────

class _AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  const _AppSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: color,
        inactiveTrackColor: color.withValues(alpha: 0.15),
        thumbColor: color,
        overlayColor: color.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        trackHeight: 4,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Comfort level indicator ──────────────────────────────────────────────────

class _ComfortIndicator extends StatelessWidget {
  final int level;
  final List<String> labels;
  final List<IconData> icons;

  const _ComfortIndicator({
    required this.level,
    required this.labels,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icons[level], size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('${labels[level]} class selected',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

// ─── Logout button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.logout_rounded,
              color: AppColors.error, size: 20),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
