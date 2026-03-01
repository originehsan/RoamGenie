import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/travel_api.dart'; // FlightModel, HotelModel, RestaurantModel
import '../../../core/constants/app_colors.dart';

/// HotelView — StatelessWidget.
/// Displays hotel cards and nearby restaurant cards.
class HotelView extends StatelessWidget {
  final List<HotelModel> hotels;
  final List<RestaurantModel> restaurants;

  const HotelView({
    super.key,
    required this.hotels,
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hotels ──────────────────────────────────────────────────────────
        ...hotels.map((h) => _HotelCard(hotel: h)),

        const SizedBox(height: 8),

        // ── Restaurants header ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Row(
            children: [
              const Icon(Icons.restaurant_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text('Nearby Restaurants',
                  style: AppTextStyles.titleMedium),
            ],
          ),
        ),

        // ── Restaurants ──────────────────────────────────────────────────────
        ...restaurants.map((r) => _RestaurantCard(restaurant: r)),
      ],
    );
  }
}

// ── Hotel Card ────────────────────────────────────────────────────────────────

class _HotelCard extends StatelessWidget {
  final HotelModel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0057FF), Color(0xFF0099CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.hotel_rounded,
                      size: 52, color: Colors.white54),
                ),
                // Price badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      hotel.pricePerNight,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hotel.name,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              )),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 12,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(hotel.location,
                                    style: AppTextStyles.bodySmall,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rating badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.success),
                          const SizedBox(width: 2),
                          Text(
                            hotel.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(hotel.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),

                const SizedBox(height: 10),

                // Amenities chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: hotel.amenities
                      .map((a) => _AmenityChip(label: a))
                      .toList(),
                ),

                const SizedBox(height: 10),

                // Reviews row
                Text(
                  '${hotel.reviewCount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')} reviews',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Restaurant Card ───────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          // Icon block
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                const SizedBox(height: 2),
                Text(
                  '${restaurant.cuisine} · ${restaurant.priceRange}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Rating column
          Column(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.star, size: 16),
              Text(
                restaurant.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.star,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Amenity Chip ──────────────────────────────────────────────────────────────

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}
