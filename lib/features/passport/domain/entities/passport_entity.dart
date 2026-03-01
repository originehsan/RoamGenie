/// PassportEntity — domain-layer visa lookup result.
///
/// Clean Architecture Rule: Entity = pure business object, no framework dependencies.
class PassportEntity {
  final String             country;
  final double             confidence;
  final List<String>       visaFreeCountries;
  final Map<String, int>   regionBreakdown;
  final Map<String, String> flags;
  final List<String>       availablePassports;

  const PassportEntity({
    required this.country,
    this.confidence = 0.0,
    required this.visaFreeCountries,
    required this.regionBreakdown,
    required this.flags,
    required this.availablePassports,
  });
}
