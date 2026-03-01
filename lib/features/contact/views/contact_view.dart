import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../view_models/contact_view_model.dart';

/// ContactView — Premium redesign with animations, glassmorphism & url_launcher.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit(ContactViewModel vm) {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    vm.submit(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
  }

  void _reset(ContactViewModel vm) {
    vm.reset();
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContactViewModel(),
      child: Consumer<ContactViewModel>(
        builder: (ctx, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Hero AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
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
                    const Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Contact & Support',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.08), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: vm.state == ContactState.success
                      ? KeyedSubtree(
                          key: const ValueKey('success'),
                          child: _SuccessView(onBack: () => _reset(vm)),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('form'),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 20, 20, 40),
                            child: Column(
                              children: [
                                _FormCard(
                                  formKey: _formKey,
                                  firstNameCtrl: _firstNameCtrl,
                                  lastNameCtrl: _lastNameCtrl,
                                  emailCtrl: _emailCtrl,
                                  phoneCtrl: _phoneCtrl,
                                  loading: vm.loading,
                                  errorMessage:
                                      vm.state == ContactState.error
                                          ? vm.message
                                          : null,
                                  onSubmit: () => _submit(vm),
                                ),
                                const SizedBox(height: 20),
                                _ContactInfoCards(),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
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
          colors: [Color(0xFF0032CC), Color(0xFF0057FF), Color(0xFF0099CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20, right: -30,
            child: Container(width: 130, height: 130,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06))),
          ),
          Positioned(
            bottom: -15, left: 10,
            child: Container(width: 90, height: 90,
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
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 26),
                  ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      curve: Curves.elasticOut,
                      duration: 700.ms),
                  const SizedBox(height: 12),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'We\'re here to help ✨',
                        textStyle: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                        speed: const Duration(milliseconds: 70),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 4),
                  Text('Fill out the form and our team will reach out',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12))
                      .animate(delay: 300.ms)
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

// ─── Form Card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl, phoneCtrl;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const _FormCard({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.loading,
    required this.errorMessage,
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
      padding: const EdgeInsets.all(22),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section heading
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0057FF), Color(0xFF0099CC)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Your Details',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 18),

            // Name row
            Row(
              children: [
                Expanded(
                    child: _fancyField(
                        firstNameCtrl, 'First Name', Icons.badge_outlined, (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  return null;
                })),
                const SizedBox(width: 12),
                Expanded(
                    child: _fancyField(
                        lastNameCtrl, 'Last Name', Icons.badge_outlined, (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  return null;
                })),
              ],
            ),
            const SizedBox(height: 12),

            _fancyField(
                emailCtrl, 'Email Address', Icons.alternate_email_rounded,
                (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                return 'Enter a valid email';
              }
              return null;
            }, type: TextInputType.emailAddress),
            const SizedBox(height: 12),

            _fancyField(
                phoneCtrl, 'Phone Number', Icons.phone_outlined, (v) {
              if (v == null || v.isEmpty) return 'Required';
              final d = v.replaceAll(RegExp(r'\D'), '');
              if (d.length < 10) return 'Enter a valid number';
              return null;
            }, type: TextInputType.phone),

            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(errorMessage!,
                          style: GoogleFonts.outfit(
                              color: AppColors.error,
                              fontSize: 13,
                              height: 1.3)),
                    ),
                  ],
                ),
              ).animate().shake(hz: 3, duration: 400.ms),
            ],

            const SizedBox(height: 22),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: loading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF003FCC), Color(0xFF0057FF),
                              Color(0xFF0099CC)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                  color: loading ? AppColors.divider : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: loading
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
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
                  onPressed: loading ? null : onSubmit,
                  icon: loading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                  label: Text(
                    loading ? 'Sending…' : 'Send Message',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .slideY(begin: 0.08, curve: Curves.easeOut);
  }

  Widget _fancyField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
            color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
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
                const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5)),
      ),
      validator: validator,
    );
  }
}

// ─── Contact Info Cards ───────────────────────────────────────────────────────

class _ContactInfoCards extends StatelessWidget {
  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'support@roamgenie.ai');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+919999999999');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 24/7 badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C9A7), Color(0xFF0099CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('24 / 7 Support',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  Text('Available round the clock',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11)),
                ],
              ),
            ],
          ),
        ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),

        const SizedBox(height: 12),

        // Email / Phone tiles
        Row(
          children: [
            Expanded(
              child: _ContactTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email Us',
                value: 'support@roamgenie.ai',
                color: const Color(0xFF0057FF),
                onTap: _launchEmail,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactTile(
                icon: Icons.phone_outlined,
                label: 'Call Helpline',
                value: '+91-9999-9999',
                color: const Color(0xFF1DB954),
                onTap: _launchPhone,
              ),
            ),
          ],
        ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final VoidCallback onBack;
  const _SuccessView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing success circle
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF00C853)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
          )
              .animate()
              .scale(
                  begin: const Offset(0.4, 0.4),
                  curve: Curves.elasticOut,
                  duration: 900.ms)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          Text('Message Sent! 🎉',
              style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary))
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Our team has received your message\nand will reach out within 24 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0032CC), Color(0xFF0057FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onBack,
                  child: Text('Send Another Message',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }
}
