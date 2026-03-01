import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../view_models/emergency_view_model.dart';

/// EmergencyView — Premium Emergency Alerts screen with dramatic UI.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmergencyViewModel(),
      child: const _EmergencyBody(),
    );
  }
}

class _EmergencyBody extends StatelessWidget {
  const _EmergencyBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Dramatic hero AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFCC0000),
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HeroHeader(),
            ),
            title: Row(
              children: [
                const Icon(Icons.emergency_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Emergency Alerts',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _WarningBanner()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  _AlertCard(
                    type: AlertType.flightCancellation,
                    headerGradient: const LinearGradient(
                      colors: [Color(0xFFCC0000), Color(0xFFE53935),
                          Color(0xFFFF6F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    accentColor: const Color(0xFFE53935),
                    icon: Icons.airplane_ticket_rounded,
                    title: 'Flight Cancellation Alert',
                    subtitle:
                        'Send an emergency WhatsApp message to notify a passenger.',
                    buttonLabel: 'Send Cancellation Alert',
                    successMessage:
                        '🚨 Emergency alert delivered via WhatsApp!',
                  ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.08),

                  const SizedBox(height: 16),

                  _AlertCard(
                    type: AlertType.offlineFallback,
                    headerGradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593),
                          Color(0xFF37474F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    accentColor: const Color(0xFF283593),
                    icon: Icons.wifi_off_rounded,
                    title: 'Offline Fallback Message',
                    subtitle:
                        'Notify passengers that systems are temporarily offline.',
                    buttonLabel: 'Send Fallback Message',
                    successMessage: '📴 Fallback message sent via WhatsApp!',
                  ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(begin: 0.08),

                  const SizedBox(height: 20),
                  _InfoNote()
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B0000), Color(0xFFCC0000), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -25, right: -25,
            child: Container(width: 130, height: 130,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06))),
          ),
          Positioned(
            bottom: -20, right: 100,
            child: Container(width: 80, height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05))),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PulsingAlertIcon(),
                  const SizedBox(height: 12),
                  Text('Emergency Alerts',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2),
                  const SizedBox(height: 4),
                  Text('Real-time WhatsApp alerts via Twilio',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12))
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingAlertIcon extends StatefulWidget {
  @override
  State<_PulsingAlertIcon> createState() => _PulsingAlertIconState();
}

class _PulsingAlertIconState extends State<_PulsingAlertIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2),
          ],
        ),
        child: const Icon(Icons.emergency_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }
}

// ─── Warning Banner ───────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These actions send REAL WhatsApp messages via Twilio. Use only for genuine emergencies.',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF92400E),
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatefulWidget {
  final AlertType type;
  final LinearGradient headerGradient;
  final Color accentColor;
  final IconData icon;
  final String title, subtitle, buttonLabel, successMessage;

  const _AlertCard({
    required this.type,
    required this.headerGradient,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.successMessage,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _toE164(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    if (digits.length == 10) return '+91$digits';
    return '+$digits';
  }

  void _submit(EmergencyViewModel vm) {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();
    final number = _toE164(_ctrl.text.trim());
    if (widget.type == AlertType.flightCancellation) {
      vm.sendFlightCancellation(number);
    } else {
      vm.sendOfflineFallback(number);
    }
  }

  void _reset(EmergencyViewModel vm) {
    if (widget.type == AlertType.flightCancellation) {
      vm.resetCancellation();
    } else {
      vm.resetFallback();
    }
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmergencyViewModel>();
    final alert = widget.type == AlertType.flightCancellation
        ? vm.cancellation
        : vm.fallback;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Gradient header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: widget.headerGradient),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(widget.subtitle,
                            style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(18),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero)
                            .animate(anim),
                        child: child)),
                child: alert.state == EmergencyState.success
                    ? KeyedSubtree(
                        key: const ValueKey('success'),
                        child: _SuccessBody(
                            alert: alert,
                            successMessage: widget.successMessage,
                            accentColor: widget.accentColor,
                            onReset: () => _reset(vm)),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('form'),
                        child: _FormBody(
                            ctrl: _ctrl,
                            formKey: _formKey,
                            alert: alert,
                            buttonLabel: widget.buttonLabel,
                            accentColor: widget.accentColor,
                            onSubmit: () => _submit(vm)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form Body ────────────────────────────────────────────────────────────────

class _FormBody extends StatelessWidget {
  final TextEditingController ctrl;
  final GlobalKey<FormState> formKey;
  final EmergencyAlert alert;
  final String buttonLabel;
  final Color accentColor;
  final VoidCallback onSubmit;

  const _FormBody({
    required this.ctrl,
    required this.formKey,
    required this.alert,
    required this.buttonLabel,
    required this.accentColor,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = alert.state == EmergencyState.loading;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (alert.state == EmergencyState.error) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(alert.message,
                        style: GoogleFonts.outfit(
                            color: AppColors.error,
                            fontSize: 12,
                            height: 1.3)),
                  ),
                ],
              ),
            ).animate().shake(hz: 3, duration: 400.ms),
          ],

          // WhatsApp phone field
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.phone,
            maxLength: 13,
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.textPrimary),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'WhatsApp number',
              hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  letterSpacing: 0,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
              prefixIcon: Container(
                margin: const EdgeInsets.fromLTRB(12, 9, 8, 9),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_rounded,
                        color: Color(0xFF25D366), size: 13),
                    SizedBox(width: 3),
                    Text('+91',
                        style: TextStyle(
                            color: Color(0xFF25D366),
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F8FF),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDE5F5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: accentColor, width: 2)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.error)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter WhatsApp number';
              final d = v.replaceAll(RegExp(r'\D'), '');
              if (d.length < 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isLoading
                    ? null
                    : LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.85),
                          accentColor
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                color: isLoading ? AppColors.divider : null,
                borderRadius: BorderRadius.circular(13),
                boxShadow: isLoading
                    ? null
                    : [
                        BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
                onPressed: isLoading ? null : onSubmit,
                icon: isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 16),
                label: Text(
                  isLoading ? 'Sending…' : buttonLabel,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Success Body ─────────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final EmergencyAlert alert;
  final String successMessage;
  final Color accentColor;
  final VoidCallback onReset;

  const _SuccessBody({
    required this.alert,
    required this.successMessage,
    required this.accentColor,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 24),
            )
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut,
                    duration: 700.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alert Sent!',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  Text(successMessage,
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ],
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: 0.1),
            ),
          ],
        ),
        if (alert.sid != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.tag_rounded,
                    color: AppColors.textMuted, size: 13),
                const SizedBox(width: 6),
                Text('SID: ${alert.sid}',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: accentColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
            onPressed: onReset,
            icon: Icon(Icons.refresh_rounded, color: accentColor, size: 16),
            label: Text('Send Another',
                style: GoogleFonts.outfit(
                    color: accentColor, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ─── Info Note ────────────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const bullets = [
      'Messages are sent via Twilio WhatsApp Business API',
      'Recipient must have WhatsApp installed',
      'Indian mobile numbers only (+91)',
      'Powered by RoamGenie emergency backend',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 15),
              ),
              const SizedBox(width: 10),
              Text('About Emergency Alerts',
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          for (final b in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5, height: 5,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Text(b,
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
