import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'core/themes/app_theme.dart';
import 'features/auth/presentation/views/login_view.dart';

import 'features/travel_plan/view_models/travel_plan_view_model.dart';
import 'features/passport/view_models/passport_view_model.dart';
import 'features/emergency/view_models/emergency_view_model.dart';
import 'features/ivr/view_models/ivr_view_model.dart';
import 'features/contact/view_models/contact_view_model.dart';
import 'homepage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.light,
    systemNavigationBarColor: Colors.white,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const RoamGenieApp());
}

class RoamGenieApp extends StatelessWidget {
  const RoamGenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Presentation ViewModels — provided globally for IndexedStack ──
        ChangeNotifierProvider(create: (_) => TravelPlanViewModel()),
        ChangeNotifierProvider(create: (_) => PassportViewModel()),
        ChangeNotifierProvider(create: (_) => EmergencyViewModel()),
        ChangeNotifierProvider(create: (_) => IvrViewModel()),
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
      ],
      child: MaterialApp(
        title:                  'RoamGenie',
        debugShowCheckedModeBanner: false,
        theme:                  AppTheme.light,
        // ── Auth Gate with guaranteed 2.5s splash ─────────────────────────
        home: const _SplashGate(),
      ),
    );
  }
}

// ── Splash Gate: guarantees 2.5s minimum splash + waits for auth ─────────────
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _timerDone = false;
  bool _authChecked = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Minimum 2.5 seconds guaranteed splash
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _timerDone = true);
    });
    // Listen once for auth state
    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (mounted) setState(() { _user = user; _authChecked = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash until BOTH timer elapsed AND auth resolved
    if (!_timerDone || !_authChecked) {
      return const _SplashScreen();
    }
    if (_user != null) return const HomeScreen();
    return const LoginScreen();
  }
}

// ── Premium Animated Splash Screen ──────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002171),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001A5E), // deep navy top-left
              Color(0xFF0D47A1), // ocean blue centre
              Color(0xFF1565C0), // medium blue
              Color(0xFF006064), // teal-night bottom-right
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative background orbs ─────────────────────────────
            Positioned(
              top: -80, right: -60,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -100, left: -80,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              top: 180, right: -20,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: 220, left: -10,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.10),
                ),
              ),
            ),

            // ── Main centered content ───────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ─── LOGO BADGE with SpinKitRipple behind it ────────────
                  SizedBox(
                    width: 180, height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // SpinKitRipple from flutter_spinkit
                        const SpinKitRipple(
                          color: Color(0xFF64B5F6), // sky-blue ripple
                          size: 180,
                          duration: Duration(milliseconds: 2000),
                        ),

                        // Frosted glass logo container
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x33FFFFFF), // white 20%
                                Color(0x1AFFFFFF), // white 10%
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D47A1).withValues(alpha: 0.6),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── APP NAME badge pill ────────────────────────────
                  // Small "TRAVEL APP" label above big name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '✈️  AI-POWERED TRAVEL APP',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF80DEEA),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.4, curve: Curves.easeOutCubic),

                  const SizedBox(height: 14),

                  // ─── Big app name ──────────────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFF80DEEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'RoamGenie',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                  )
                  .animate(delay: 450.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutCubic),

                  const SizedBox(height: 12),

                  // ─── Typewriter subtitle (animated_text_kit) ────────────
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Your smart travel companion 🌍',
                        textStyle: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                        speed: const Duration(milliseconds: 60),
                        cursor: '│',
                      ),
                      TypewriterAnimatedText(
                        'Flights  ·  Hotels  ·  Itineraries 🚀',
                        textStyle: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                        speed: const Duration(milliseconds: 60),
                        cursor: '│',
                      ),
                      TypewriterAnimatedText(
                        'Visa info  ·  Emergency alerts  ·  AI calls 📞',
                        textStyle: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                        speed: const Duration(milliseconds: 60),
                        cursor: '│',
                      ),
                    ],
                    repeatForever: true,
                    pause: const Duration(milliseconds: 1600),
                    displayFullTextOnTap: true,
                  )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 500.ms),

                  const SizedBox(height: 60),

                  // ─── SpinKitThreeInOut loading indicator (flutter_spinkit) ──
                  const SpinKitThreeInOut(
                    color: Colors.white,
                    size: 28,
                    duration: Duration(milliseconds: 1200),
                  )
                  .animate(delay: 900.ms)
                  .fadeIn(duration: 400.ms),

                  const SizedBox(height: 14),

                  // Loading status text
                  Text(
                    'Getting things ready...',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  )
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 500.ms),

                ],
              ),
            ),

            // ── Bottom version tag ──────────────────────────────────────
            Positioned(
              bottom: 32,
              left: 0, right: 0,
              child: Text(
                'v1.0.0  •  Powered by AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              )
              .animate(delay: 1200.ms)
              .fadeIn(duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}