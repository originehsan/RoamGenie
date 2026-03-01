import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THREE-DOT ANIMATED LOADER
// Soft bounce animation — dots pulse in sequence like a typing indicator.
// This is the ONLY loading widget used app-wide. No CircularProgressIndicator.
// ─────────────────────────────────────────────────────────────────────────────

class ThreeDotLoader extends StatefulWidget {
  final String? message;
  final String? subMessage;
  final Color color;
  final double dotSize;

  const ThreeDotLoader({
    super.key,
    this.message,
    this.subMessage,
    this.color = AppColors.primary,
    this.dotSize = 9,
  });

  @override
  State<ThreeDotLoader> createState() => _ThreeDotLoaderState();
}

class _ThreeDotLoaderState extends State<ThreeDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Each dot jumps at intervals of 200ms within a 1200ms cycle
  static const _delay = [0.0, 0.2, 0.4];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _dotScale(int i) {
    // Each dot bounces from scale 0.55 → 1.0 → 0.55 with an offset phase
    final offset = _delay[i];
    final t = ((_ctrl.value - offset) % 1.0 + 1.0) % 1.0;
    // Bell-curve using sin: 0→1→0 over half the cycle, rest is resting
    if (t < 0.5) {
      return 0.55 + 0.45 * (1 - (2 * t - 1) * (2 * t - 1));
    }
    return 0.55;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Three bouncing dots ───────────────────────────────────────────────
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final scale = _dotScale(i);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.5),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.3 + 0.7 * (scale - 0.55) / 0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),

        // ── Optional label
        if (widget.message != null) ...[
          const SizedBox(height: 18),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, height: 1.4,
            ),
          ),
        ],
        if (widget.subMessage != null) ...[
          const SizedBox(height: 5),
          Text(
            widget.subMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary, height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Centred full-screen loading overlay — used for screen-level loads.
class ThreeDotLoaderOverlay extends StatelessWidget {
  final String? message;
  final String? subMessage;
  const ThreeDotLoaderOverlay({super.key, this.message, this.subMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
        child: ThreeDotLoader(message: message, subMessage: subMessage),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER SKELETON  — uses the shimmer package for GPU-accelerated animation
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      const Color(0xFFECEFF1),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 12),
          SizedBox(height: 10),
          ShimmerBox(height: 16),
          SizedBox(height: 8),
          ShimmerBox(width: 200, height: 12),
          SizedBox(height: 14),
          Row(children: [
            Expanded(child: ShimmerBox(height: 32, radius: 10)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 32, radius: 10)),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE BUTTON DOTS  — tiny 3-dot inside a button
// ─────────────────────────────────────────────────────────────────────────────

class ButtonDotLoader extends StatelessWidget {
  final Color color;
  const ButtonDotLoader({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ThreeDotLoader(color: color, dotSize: 7);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING TYPE ENUM — single source of truth for all loading states
// ─────────────────────────────────────────────────────────────────────────────

/// Controls WHICH loader is visible. Only ONE should be active at a time.
///
///   screen → Full-screen center loader (+ skeletons)
///   button → Loader inside the submit button, screen is normal
///   none   → No loader, show regular UI
enum LoadingType { none, button, screen }
