import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../homepage.dart';

/// SignupView — Clean Architecture View layer for user registration.
/// Reads AuthViewModel state — zero business logic in UI.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AuthViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = AuthViewModel();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // ── Gradient background ────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                ),
                // ── Decorative circles ─────────────────────────────────────
                ..._buildDecorations(context),

                // ── Content ────────────────────────────────────────────────
                SafeArea(
                  child: Column(
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'Back to Login',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                _heroSection()
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 100.ms)
                                    .slideY(begin: -0.2, curve: Curves.easeOut),
                                const SizedBox(height: 24),
                                _signupCard(context, vm)
                                    .animate()
                                    .fadeIn(duration: 450.ms, delay: 200.ms)
                                    .slideY(begin: 0.15, curve: Curves.easeOut),
                                const SizedBox(height: 20),
                                _loginNudge(context).animate().fadeIn(
                                  duration: 300.ms,
                                  delay: 350.ms,
                                ),
                              ],
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
        },
      ),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────
  Widget _heroSection() => Column(
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.flight_takeoff_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        'Join RoamGenie',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Start planning unforgettable trips 🌍',
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 13,
        ),
      ),
    ],
  );

  // ── Signup card ─────────────────────────────────────────────────────────────
  Widget _signupCard(BuildContext context, AuthViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create your account',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the details below to get started',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // Error banner
            if (vm.errorMessage != null) ...[
              _errorBanner(vm.errorMessage!),
              const SizedBox(height: 16),
            ],

            // Fields
            _fieldLabel('Full Name'),
            const SizedBox(height: 6),
            _inputField(
              controller: _nameCtrl,
              hint: 'Alex Johnson',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => vm.clearError(),
            ),
            const SizedBox(height: 14),

            _fieldLabel('Email Address'),
            const SizedBox(height: 6),
            _inputField(
              controller: _emailCtrl,
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => vm.clearError(),
            ),
            const SizedBox(height: 14),

            _fieldLabel('Password'),
            const SizedBox(height: 6),
            _inputField(
              controller: _passCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: vm.obscurePassword,
              onChanged: (_) => vm.clearError(),
              suffix: IconButton(
                icon: Icon(
                  vm.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: vm.togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 11,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Minimum 6 characters',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _fieldLabel('Confirm Password'),
            const SizedBox(height: 6),
            _inputField(
              controller: _confirmCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: vm.obscureConfirmPassword,
              onChanged: (_) => vm.clearError(),
              suffix: IconButton(
                icon: Icon(
                  vm.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: vm.toggleConfirmPasswordVisibility,
              ),
            ),

            const SizedBox(height: 26),

            // Create account button
            _gradientButton(
              loading: vm.isLoading,
              label: 'Start Exploring',
              icon: Icons.rocket_launch_rounded,
              colors: const [Color(0xFF0057FF), Color(0xFF00C9A7)],
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      vm.clearError();
                      await vm.signup(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text,
                        confirmPassword: _confirmCtrl.text,
                        displayName: _nameCtrl.text.trim(),
                      );
                      if (vm.isSuccess && context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          SlidePageRoute(page: const HomeScreen()),
                          (_) => false,
                        );
                      }
                    },
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                'By signing up you agree to our Terms & Privacy Policy',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable sub-widgets ───────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
    text,
    style: GoogleFonts.outfit(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffix,
    void Function(String)? onChanged,
  }) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    onChanged: onChanged,
    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      suffixIcon: suffix,
    ),
  );

  Widget _errorBanner(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.error,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            msg,
            style: GoogleFonts.outfit(color: AppColors.error, fontSize: 12),
          ),
        ),
      ],
    ),
  ).animate().shake(duration: 400.ms, hz: 3);

  Widget _gradientButton({
    required bool loading,
    required String label,
    required IconData icon,
    required List<Color> colors,
    required void Function()? onPressed,
  }) => SizedBox(
    width: double.infinity,
    height: 52,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: loading
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: loading ? AppColors.surfaceGrey : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );

  Widget _loginNudge(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Already have an account?  ',
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 13,
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Text(
          'Sign in →',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );

  List<Widget> _buildDecorations(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return [
      Positioned(
        top: -size.height * 0.1,
        right: -size.width * 0.2,
        child: Container(
          width: size.width * 0.65,
          height: size.width * 0.65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      Positioned(
        bottom: -size.height * 0.08,
        left: -size.width * 0.1,
        child: Container(
          width: size.width * 0.55,
          height: size.width * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
      ),
    ];
  }
}
