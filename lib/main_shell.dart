import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/constants/app_colors.dart';
import 'features/travel_plan/views/travel_plan_view.dart';
import 'features/passport/views/passport_view.dart';
import 'features/ivr/views/ivr_view.dart';
import 'features/contact/views/contact_view.dart';
import 'features/emergency/views/emergency_view.dart';
import 'features/auth/presentation/views/login_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MainShell — Root navigation shell.
//
// Architecture (CORRECT Flutter pattern):
//   • IndexedStack keeps all pages alive — state is 100% preserved.
//   • Index changes via setState() — NO Navigator.push, NO route stacking.
//   • PopScope: back on non-home tab → home tab; on home tab → allow exit.
//   • Custom premium BottomNav: floating pill, spring icon scale, fade labels.
// ─────────────────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // ── Tab definitions ─────────────────────────────────────────────────────────
  static const _tabs = [
    _TabItem(
      label: 'Plan',
      icon: Icons.travel_explore_outlined,
      activeIcon: Icons.travel_explore_rounded,
    ),
    _TabItem(
      label: 'Visa',
      icon: Icons.book_outlined,
      activeIcon: Icons.book_rounded,
    ),
    _TabItem(
      label: 'AI Call',
      icon: Icons.phone_outlined,
      activeIcon: Icons.phone_rounded,
    ),
    _TabItem(
      label: 'Support',
      icon: Icons.headset_mic_outlined,
      activeIcon: Icons.headset_mic_rounded,
    ),
    _TabItem(
      label: 'SOS',
      icon: Icons.emergency_outlined,
      activeIcon: Icons.emergency_rounded,
    ),
  ];

  // ── Pages — created once, IndexedStack keeps them alive  ───────────────────
  static const _pages = [
    TravelPlanScreen(),
    PassportScreen(),
    IvrScreen(),
    ContactScreen(),
    EmergencyScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android back: non-home tab → go home; home tab → allow system exit
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // ── IndexedStack — correct Flutter tab pattern ──────────────────────
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        // ── Premium bottom nav ──────────────────────────────────────────────
        bottomNavigationBar: _PremiumBottomNav(
          currentIndex: _currentIndex,
          tabs: _tabs,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}

// ─── Tab item model ───────────────────────────────────────────────────────────

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Bottom Navigation Bar
//
// Design: floating card with soft shadow + rounded top corners.
// Active state: sliding pill indicator + filled icon + bold label.
// Animation: spring scale on icon, animated pill position.
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumBottomNav extends StatefulWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  State<_PremiumBottomNav> createState() => _PremiumBottomNavState();
}

class _PremiumBottomNavState extends State<_PremiumBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _pillCtrl;
  late Animation<double> _pillPos;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _pillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pillPos = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _pillCtrl, curve: Curves.easeOutCubic),
    );
    _prevIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(_PremiumBottomNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      final from = _prevIndex.toDouble();
      final to = widget.currentIndex.toDouble();
      _pillPos = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _pillCtrl, curve: Curves.easeOutCubic),
      );
      _pillCtrl.forward(from: 0);
      _prevIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    _pillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.tabs.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tileW = constraints.maxWidth / n;
              final pillW = tileW * 0.58;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Sliding pill indicator ──────────────────────────────────
                  AnimatedBuilder(
                    animation: _pillPos,
                    builder: (_, __) {
                      final x = _pillPos.value * tileW +
                          tileW / 2 -
                          pillW / 2;
                      return Positioned(
                        top: 8,
                        left: x,
                        child: Container(
                          width: pillW,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Tab tiles ───────────────────────────────────────────────
                  Row(
                    children: [
                      for (var i = 0; i < n; i++)
                        Expanded(
                          child: _TabTile(
                            tab: widget.tabs[i],
                            isActive: i == widget.currentIndex,
                            onTap: () => widget.onTap(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Individual tab tile ──────────────────────────────────────────────────────

class _TabTile extends StatefulWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _TabTile({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabTile> createState() => _TabTileState();
}

class _TabTileState extends State<_TabTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    if (widget.isActive) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_TabTile old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward(from: 0);
    } else if (!widget.isActive && old.isActive) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon ──────────────────────────────────────────────────────
              Transform.scale(
                scale: _scale.value,
                child: Icon(
                  active ? widget.tab.activeIcon : widget.tab.icon,
                  size: 22,
                  color: active ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              // ── Label ─────────────────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.primary : AppColors.textMuted,
                  letterSpacing: 0.1,
                ),
                child: Text(widget.tab.label),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared logout dialog — called from ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showLogoutDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
          SizedBox(width: 10),
          Text('Sign Out',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
      content: const Text(
        'Are you sure you want to sign out of RoamGenie?',
        style:
            TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style:
                    TextStyle(color: AppColors.textSecondary)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    // Add haptic feedback on logout
    HapticFeedback.mediumImpact();
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }
}
