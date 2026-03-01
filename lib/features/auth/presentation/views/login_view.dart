import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/constants/app_colors.dart';
import 'signup_view.dart';

/// LoginView — Clean Architecture View layer for authentication.
/// Zero business logic: only reads AuthViewModel state & calls methods.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // ── Gradient background ───────────────────────────────────
                Container(
                    decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient)),
                ..._buildDecorations(context),

                // ── Content ───────────────────────────────────────────────
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          _heroSection()
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: -0.2, curve: Curves.easeOut),
                          const SizedBox(height: 36),
                          _loginCard(context, vm)
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 150.ms)
                              .slideY(begin: 0.15, curve: Curves.easeOut),
                          const SizedBox(height: 24),
                          _signupNudge(context)
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 300.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────
  Widget _heroSection() => Column(
        children: [
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.travel_explore,
                color: Colors.white, size: 42),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(end: 1.05, duration: 2000.ms, curve: Curves.easeInOut),

          const SizedBox(height: 16),
          Text('RoamGenie',
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 32,
                  fontWeight: FontWeight.w800, letterSpacing: -0.8)),
          const SizedBox(height: 6),
          Text('Your AI-powered travel companion ✈️',
              style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          const SizedBox(height: 20),

          // Feature pills
          Wrap(
            spacing: 8,
            children: [
              _pill(Icons.flight_rounded, 'Flights'),
              _pill(Icons.hotel_rounded, 'Hotels'),
              _pill(Icons.map_rounded, 'Itinerary'),
            ],
          ),
        ],
      );

  Widget _pill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  // ── Login card ──────────────────────────────────────────────────────────────
  Widget _loginCard(BuildContext context, AuthViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back',
              style: GoogleFonts.outfit(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Sign in to plan your next adventure',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          // Error banner
          if (vm.errorMessage != null) ...[
            _errorBanner(vm.errorMessage!),
            const SizedBox(height: 16),
          ],

          // Email
          _fieldLabel('Email address'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => vm.clearError(),
            style: GoogleFonts.outfit(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppColors.textSecondary, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          _fieldLabel('Password'),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordCtrl,
            obscureText: vm.obscurePassword,
            onChanged: (_) => vm.clearError(),
            style: GoogleFonts.outfit(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.textSecondary, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary, size: 18,
                ),
                onPressed: vm.togglePasswordVisibility,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () => _showForgotPassword(context),
              child: Text('Forgot password?',
                  style: GoogleFonts.outfit(
                      color: AppColors.primary, fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),

          // Sign-in button
          _gradientButton(
            loading: vm.isLoading,
            label: 'Sign In',
            icon: Icons.login_rounded,
            colors: const [Color(0xFF0057FF), Color(0xFF0099CC)],
            onPressed: () => vm.login(
              email:    _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable sub-widgets ───────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(text,
      style: GoogleFonts.outfit(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));

  Widget _errorBanner(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(msg,
                    style: GoogleFonts.outfit(
                        color: AppColors.error, fontSize: 12))),
          ],
        ),
      ).animate().shake(duration: 400.ms, hz: 3);

  Widget _gradientButton({
    required bool loading,
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity, height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: loading
                ? null
                : LinearGradient(
                    colors: colors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight),
            color: loading ? AppColors.surfaceGrey : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: loading ? null : onPressed,
            child: loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.primary))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(label,
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      );

  Widget _signupNudge(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('New to RoamGenie?  ',
              style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SignupScreen()),
            ),
            child: Text('Create account →',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      );

  List<Widget> _buildDecorations(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return [
      Positioned(
        top: -size.height * 0.12, right: -size.width * 0.2,
        child: Container(
          width: size.width * 0.7, height: size.width * 0.7,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      Positioned(
        bottom: -size.height * 0.1, left: -size.width * 0.15,
        child: Container(
          width: size.width * 0.6, height: size.width * 0.6,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
    ];
  }

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Password',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter your email and we'll send a reset link.",
                style: GoogleFonts.outfit(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                try {
                  await AuthRepositoryImpl()
                      .sendPasswordReset(email: ctrl.text.trim());
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reset link sent! Check your email.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not send reset link.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: Text('Send Link',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
