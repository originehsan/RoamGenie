import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/travel_api.dart'; // FlightModel
import '../../../core/constants/app_colors.dart';


/// FlightCard — StatelessWidget.
/// Displays a single flight option with airline, timing, price, and book link.
class FlightCard extends StatelessWidget {
  final FlightModel flight;

  const FlightCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // ── Top stripe ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: AppColors.cardAccentGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                // ── Row 1: Airline + Class badge + Price ──
                Row(
                  children: [
                    // Airline icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0057FF), Color(0xFF00AAFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(Icons.flight_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),

                    // Airline name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.airline,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _Chip(
                            label: 'Direct',
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.price,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text('per person',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            )),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 14),

                // ── Row 2: Departure ── Duration ── Arrival ──
                Row(
                  children: [
                    // Departure
                    Expanded(
                      child: _TimeBlock(
                        time: flight.departureTime,
                        label: 'Departure',
                        alignment: CrossAxisAlignment.start,
                      ),
                    ),

                    // Duration visual
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(flight.totalDuration,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              )),
                          const SizedBox(height: 6),
                          _FlightTimeline(),
                        ],
                      ),
                    ),

                    // Arrival
                    Expanded(
                      child: _TimeBlock(
                        time: flight.arrivalTime,
                        label: 'Arrival',
                        alignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Row 3: Book button ──
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0032CC), Color(0xFF0057FF)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded,
                          size: 15, color: Colors.white),
                      label: Text(
                        'View Flight',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Opening ${flight.airline} booking...'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String time;
  final String label;
  final CrossAxisAlignment alignment;
  const _TimeBlock(
      {required this.time,
      required this.label,
      required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(time,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.textMuted,
            )),
      ],
    );
  }
}

class _FlightTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: AppColors.divider,
          ),
        ),
        const Icon(Icons.flight_rounded,
            color: AppColors.primary, size: 16),
        Expanded(
          child: Container(
            height: 1.5,
            color: AppColors.divider,
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
              color: AppColors.accent, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
