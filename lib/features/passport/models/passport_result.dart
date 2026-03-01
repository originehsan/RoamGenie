// PassportResult model — pure data class for the Passport / Visa feature.
//
// MVVM Rule: Model = data only.
// No UI, no ChangeNotifier, no business logic.

// ── State enum used by PassportViewModel ─────────────────────────────────────
enum PassportState {
  idle,
  loadingCountries,
  loading,
  success,
  error,
}

class PassportResult {
  final String country;
  final double confidence; // OCR scan confidence (0–1); 0 for manual lookup
  final List<String> visaFreeCountries;
  final Map<String, int> regionBreakdown; // { "Asia": 12, "Europe": 30, ... }
  final Map<String, String> flags;        // { "Thailand": "🇹🇭", ... }
  final List<String> availablePassports;  // from /api/passport/countries

  const PassportResult({
    required this.country,
    this.confidence = 0.0,
    required this.visaFreeCountries,
    required this.regionBreakdown,
    required this.flags,
    required this.availablePassports,
  });

  /// Parses the flat backend response (no outer 'data' wrapper on passport endpoints).
  factory PassportResult.fromJson(Map<String, dynamic> data) {
    final raw = data['visaFreeCountries'];
    final List<String> vfc =
        raw is List ? raw.map((e) => e.toString()).toList() : [];

    final rawReg = data['regionBreakdown'] as Map<String, dynamic>? ?? {};
    final region = rawReg.map((k, v) => MapEntry(k, (v as num).toInt()));

    final rawFlags = data['flags'] as Map<String, dynamic>? ?? {};
    final flags = rawFlags.map((k, v) => MapEntry(k, v.toString()));

    final rawPassports = data['availablePassports'];
    final List<String> passports = rawPassports is List
        ? rawPassports.map((e) => e.toString()).toList()
        : [];

    return PassportResult(
      country:            data['country']    as String? ?? '',
      confidence:         (data['confidence'] as num? ?? 0.0).toDouble(),
      visaFreeCountries:  vfc,
      regionBreakdown:    region,
      flags:              flags,
      availablePassports: passports,
    );
  }

  Map<String, dynamic> toJson() => {
        'country':            country,
        'confidence':         confidence,
        'visaFreeCountries':  visaFreeCountries,
        'regionBreakdown':    regionBreakdown,
        'flags':              flags,
        'availablePassports': availablePassports,
      };
}
