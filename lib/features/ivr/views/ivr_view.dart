import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../view_models/ivr_view_model.dart';

/// IvrView — AI Voice Call screen. Premium redesign with fancy animations.
class IvrScreen extends StatefulWidget {
  const IvrScreen({super.key});

  @override
  State<IvrScreen> createState() => _IvrScreenState();
}

class _IvrScreenState extends State<IvrScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _toE164(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    if (digits.length == 10) return '+91$digits';
    return '+$digits';
  }

  void _submit(IvrViewModel vm) {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    vm.requestCall(_toE164(_phoneCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IvrViewModel(),
      child: Consumer<IvrViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Fancy hero SliverAppBar ────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF0057FF),
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _HeroHeader(),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('AI Voice Call',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero)
                                .animate(anim),
                            child: child,
                          ),
                        ),
                        child: _buildContent(context, vm),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, IvrViewModel vm) {
    switch (vm.state) {
      case IvrState.loading:
        return const KeyedSubtree(
          key: ValueKey('loading'),
          child: _LoadingCard(),
        );
      case IvrState.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: _SuccessCard(
            message: vm.message,
            sid: vm.callSid,
            onDone: () {
              vm.reset();
              _phoneCtrl.clear();
            },
          ),
        );
      case IvrState.error:
        return KeyedSubtree(
          key: const ValueKey('error'),
          child: _ErrorCard(
            message: vm.message,
            onRetry: () => vm.reset(),
          ),
        );
      case IvrState.idle:
        return KeyedSubtree(
          key: const ValueKey('idle'),
          child: Column(
            children: [
              _InputCard(
                formKey: _formKey,
                controller: _phoneCtrl,
                onSubmit: () => _submit(vm),
              ),
              const SizedBox(height: 20),
              _HowItWorksCard(),
            ],
          ),
        );
    }
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0032CC), Color(0xFF0057FF), Color(0xFF00AAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -30,
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
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pulsing phone icon
                  _PulsingPhoneIcon(),
                  const SizedBox(height: 14),
                  Text('AI Travel Assistant',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2),
                  const SizedBox(height: 4),
                  Text('Get personalised travel info on a real phone call',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13))
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingPhoneIcon extends StatefulWidget {
  @override
  State<_PulsingPhoneIcon> createState() => _PulsingPhoneIconState();
}

class _PulsingPhoneIconState extends State<_PulsingPhoneIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.35), width: 1.5),
        ),
        child: const Icon(Icons.phone_in_talk_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }
}

// ─── Input Card ───────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _InputCard({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0057FF), Color(0xFF00AAFF)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dialpad_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Mobile Number',
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('Indian numbers (+91) only',
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phone field with fancy prefix
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 13,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                hintText: '9876 543 210',
                hintStyle: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
                prefixIcon: Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0057FF), Color(0xFF00AAFF)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+91',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F8FF),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDE5F5))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.error)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.error, width: 2)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your phone number';
                final d = v.replaceAll(RegExp(r'\D'), '');
                if (d.length < 10) return 'Enter a valid 10-digit number';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Call button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0032CC), Color(0xFF0057FF), Color(0xFF00AAFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
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
                  onPressed: onSubmit,
                  icon: const Icon(Icons.phone_forwarded_rounded,
                      color: Colors.white, size: 20),
                  label: Text('Request AI Call',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

// ─── Loading Card ─────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _PulsingRings(),
          const SizedBox(height: 24),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Connecting to AI agent…',
                textStyle: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                speed: const Duration(milliseconds: 60),
              ),
              TypewriterAnimatedText(
                'Initiating Twilio call…',
                textStyle: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                speed: const Duration(milliseconds: 60),
              ),
              TypewriterAnimatedText(
                'Almost ready! ✈️',
                textStyle: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
                speed: const Duration(milliseconds: 60),
              ),
            ],
            repeatForever: true,
          ),
          const SizedBox(height: 8),
          Text('Your call will arrive shortly',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PulsingRings extends StatefulWidget {
  @override
  State<_PulsingRings> createState() => _PulsingRingsState();
}

class _PulsingRingsState extends State<_PulsingRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final progress = (_ctrl.value - i * 0.3).clamp(0.0, 1.0);
                final opacity = (1 - progress) * 0.4;
                final size = 40 + 60 * progress;
                return Container(
                  width: size, height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: opacity),
                        width: 2),
                  ),
                );
              },
            ),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0057FF), Color(0xFF00AAFF)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16)
              ],
            ),
            child: const Icon(Icons.phone_in_talk_rounded,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

// ─── Success Card ─────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  final String message;
  final String? sid;
  final VoidCallback onDone;

  const _SuccessCard(
      {required this.message, required this.sid, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.success.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Success icon with glow
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF00C853)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4)
              ],
            ),
            child: const Icon(Icons.phone_in_talk_rounded,
                color: Colors.white, size: 36),
          )
              .animate()
              .scale(
                  begin: const Offset(0.5, 0.5),
                  curve: Curves.elasticOut,
                  duration: 800.ms)
              .fadeIn(),
          const SizedBox(height: 18),

          Text('Call Initiated! 📞',
              style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary))
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 10),

          Text(message,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
              textAlign: TextAlign.center)
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms),

          if (sid != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag_rounded,
                      color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 6),
                  Text('SID: $sid',
                      style: GoogleFonts.sourceCodePro(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: onDone,
              child: Text('Done',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.error.withValues(alpha: 0.25), width: 1.5),
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
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_disabled_rounded,
                color: AppColors.error, size: 32),
          )
              .animate()
              .shake(hz: 3, duration: 600.ms)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          Text('Call Failed',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.error)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0032CC), Color(0xFF0057FF)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
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
    );
  }
}

// ─── How It Works ─────────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        icon: Icons.dialpad_rounded,
        title: 'Enter your number',
        body: 'Type your +91 Indian mobile number',
        color: Color(0xFF0057FF),
      ),
      (
        icon: Icons.hub_rounded,
        title: 'n8n triggers AI',
        body: 'Our workflow activates the voice agent',
        color: Color(0xFF7C3AED),
      ),
      (
        icon: Icons.phone_rounded,
        title: 'AI calls you',
        body: 'Get personalised travel assistance',
        color: Color(0xFF1DB954),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.auto_graph_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text('How it works',
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: steps[i].color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(steps[i].icon,
                          color: steps[i].color, size: 20),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2, height: 20,
                        color: AppColors.divider,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].title,
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(steps[i].body,
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ],
            )
                .animate(delay: (100 * i).ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1),
          ],
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}
