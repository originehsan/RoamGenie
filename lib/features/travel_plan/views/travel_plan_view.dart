import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/app_loader.dart';
import '../view_models/travel_plan_view_model.dart';
import '../widgets/travel_form.dart';
import '../widgets/flight_card.dart';
import '../widgets/hotel_view.dart';
import '../widgets/itinerary_view.dart';
import '../../profile/views/profile_view.dart';

/// TravelPlanView — main travel planning screen (View layer in MVVM).
class TravelPlanScreen extends StatefulWidget {
  const TravelPlanScreen({super.key});

  @override
  State<TravelPlanScreen> createState() => _TravelPlanScreenState();
}

class _TravelPlanScreenState extends State<TravelPlanScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TravelPlanViewModel>().addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    if (mounted) {
      context.read<TravelPlanViewModel>().removeListener(_onViewModelChanged);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final vm = context.read<TravelPlanViewModel>();
    if (vm.hasResult && !vm.loading) {
      Future.delayed(const Duration(milliseconds: 350), _scrollToResults);
    }
  }

  void _scrollToResults() {
    if (!_scrollController.hasClients) return;
    final ctx = _resultsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    } else {
      _scrollController.animateTo(
        _scrollController.position.pixels + 420,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── SliverAppBar ───────────────────────────────────────────────────
          _AppBar(scrollController: _scrollController),

          // ── Body ───────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer<TravelPlanViewModel>(
              builder: (context, vm, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── 1. Travel Form ──
                    TravelForm(
                      loadingType: vm.loadingType,
                      onSubmit: ({
                        required source,
                        required destination,
                        required departureDate,
                        required returnDate,
                        required budget,
                        required flightClass,
                        required preferences,
                      }) =>
                          context
                              .read<TravelPlanViewModel>()
                              .generateTravelPlan(
                                source: source,
                                destination: destination,
                                departureDate: departureDate,
                                returnDate: returnDate,
                                budget: budget,
                                flightClass: flightClass,
                                preferences: preferences,
                              ),
                    ),

                    // ── AnimatedSwitcher for states ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _buildStateContent(context, vm),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, TravelPlanViewModel vm) {
    // SCREEN loader — only shown when loadingType == screen
    if (vm.screenLoading) {
      return KeyedSubtree(
        key: const ValueKey('loading'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 36),
              const ThreeDotLoader(
                message: 'Crafting your perfect trip…',
                subMessage: 'Searching flights · hotels · itinerary…',
              ),
              const SizedBox(height: 36),
              const SkeletonCard(),
              const SkeletonCard(),
            ],
          ),
        ),
      );
    }

    // Error
    if (vm.error != null) {
      return KeyedSubtree(
        key: const ValueKey('error'),
        child: _ErrorState(
          message: vm.error!,
          onRetry: () => context.read<TravelPlanViewModel>().reset(),
        ),
      );
    }

    // Results
    if (vm.hasResult) {
      return KeyedSubtree(
        key: const ValueKey('results'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(key: _resultsKey, height: 0),

            _ResultsBanner(
              src: vm.lastSource,
              dst: vm.lastDestination,
              flightCount: vm.flights.length,
            ),

            _SectionHeader(
              icon: Icons.flight_rounded,
              title: 'Available Flights',
              subtitle:
                  '${vm.flights.length} option${vm.flights.length == 1 ? '' : 's'} found',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < vm.flights.length; i++)
                    _AnimatedListItem(
                      index: i,
                      child: FlightCard(flight: vm.flights[i]),
                    ),
                ],
              ),
            ),

            _SectionHeader(
              icon: Icons.hotel_rounded,
              title: 'Stay & Dine',
              subtitle: 'Top hotels & restaurants',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HotelView(
                hotels: vm.hotels,
                restaurants: vm.restaurants,
              ),
            ),

            _SectionHeader(
              icon: Icons.map_rounded,
              title: 'Your Itinerary',
              subtitle: 'Day-by-day AI plan',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ItineraryView(itinerary: vm.itinerary),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _PlanAnotherButton(
                onTap: () {
                  context.read<TravelPlanViewModel>().reset();
                  _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                },
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    return const KeyedSubtree(
      key: ValueKey('empty'),
      child: Center(child: _EmptyState()),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────────
// APP BAR (scroll-aware: title fades in only when collapsed)
// ───────────────────────────────────────────────────────────────────────────────

class _AppBar extends StatefulWidget {
  final ScrollController scrollController;
  const _AppBar({required this.scrollController});

  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> {
  static const double _expandedHeight = 170;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final threshold = _expandedHeight - kToolbarHeight - 20;
    final collapsed = widget.scrollController.hasClients &&
        widget.scrollController.offset > threshold;
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      backgroundColor: AppColors.primaryDark,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      // Title fades in ONLY when collapsed
      title: AnimatedOpacity(
        opacity: _isCollapsed ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('RoamGenie',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      actions: const [_ProfileAvatarButton(), SizedBox(width: 12)],
      // Hero content in background — no FlexibleSpaceBar title
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildHero(userEmail),
      ),
    );
  }

  Widget _buildHero(String userEmail) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF002171), Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -20,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 72, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App name with icon badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.travel_explore,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'RoamGenie',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

                  const SizedBox(height: 6),

                  // Typewriter subtitle
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'AI-powered travel planning ✨',
                        textStyle: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                        speed: const Duration(milliseconds: 55),
                      ),
                      TypewriterAnimatedText(
                        'Flights · Hotels · Itinerary in seconds 🚀',
                        textStyle: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                        speed: const Duration(milliseconds: 55),
                      ),
                    ],
                    repeatForever: true,
                    pause: const Duration(seconds: 2),
                  ),

                  const SizedBox(height: 8),

                  // Email pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mail_outline_rounded,
                            color: Colors.white70, size: 11),
                        const SizedBox(width: 5),
                        Text(
                          userEmail,
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.0),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile avatar button — top-right, navigates to ProfileView

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final initial = (user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : user?.email ?? 'U')[0]
        .toUpperCase();

    return GestureDetector(
      onTap: () => AppRoutes.push(context, const ProfileView()),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withValues(alpha: 0.28),
          child: Text(
            initial,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: AppColors.error.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded,
                color: AppColors.error, size: 28),
          ).animate().shake(hz: 2, duration: 600.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          Text('Something went wrong',
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0032CC), Color(0xFF0057FF)]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 18),
                label: Text('Try Again',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _ResultsBanner extends StatelessWidget {
  final String src;
  final String dst;
  final int flightCount;
  const _ResultsBanner(
      {required this.src, required this.dst, required this.flightCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00875A), Color(0xFF1DB954), Color(0xFF00C9A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan Ready! 🎉',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  '${iataToCity(src)} → ${iataToCity(dst)} · $flightCount flights found',
                  style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0057FF), Color(0xFF00AAFF)]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanAnotherButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlanAnotherButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE65100), Color(0xFFFF6D00)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.sunset.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
          label: Text('Plan Another Trip',
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    const ideas = [
      ('🏖️', 'Beach'),
      ('🏔️', 'Mountains'),
      ('🏛️', 'Heritage'),
      ('🌆', 'City break'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big hero icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF002171), Color(0xFF0D47A1)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.flight_takeoff_rounded,
                    color: Colors.white, size: 38),
              ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  curve: Curves.elasticOut,
                  duration: 800.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 18),

              Text('Where to next?',
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary))
                  .animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 10),

              Text(
                'Fill in the form above.\nOur AI will plan the perfect trip for you.',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6),
                textAlign: TextAlign.center,
              ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: ideas
                    .asMap()
                    .entries
                    .map((e) => _TripIdea(emoji: e.value.$1, label: e.value.$2)
                        .animate(delay: (300 + e.key * 80).ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.2))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripIdea extends StatelessWidget {
  final String emoji;
  final String label;
  const _TripIdea({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10),
        ],
      ),
      child: Text('$emoji  $label',
          style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED LIST ITEM — staggered slide+fade entrance for result cards
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
