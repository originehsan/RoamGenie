// TravelPlanModels — pure data classes for the Travel Plan feature.
//
// MVVM Rule: Model = data only.
// No UI, no ChangeNotifier, no business logic.
// All fields are final (immutable). Serialisation via fromJson / toJson.

// ─────────────────────────────────────────────────────────────────────────────
// FlightModel
// ─────────────────────────────────────────────────────────────────────────────

class FlightModel {
  final String airline;
  final String airlineLogo;
  final String price;
  final String departureTime;
  final String arrivalTime;
  final String totalDuration;
  final String bookingLink;

  const FlightModel({
    required this.airline,
    required this.airlineLogo,
    required this.price,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalDuration,
    required this.bookingLink,
  });

  factory FlightModel.fromJson(Map<String, dynamic> j) => FlightModel(
        airline:       j['airline']?.toString()       ?? 'Unknown Airline',
        airlineLogo:   j['airlineLogo']?.toString()   ?? '',
        price:         j['price']?.toString()         ?? 'N/A',
        departureTime: j['departureTime']?.toString() ?? '--:--',
        arrivalTime:   j['arrivalTime']?.toString()   ?? '--:--',
        totalDuration: j['totalDuration']?.toString() ?? 'N/A',
        bookingLink:   j['bookingLink']?.toString()   ?? '',
      );

  Map<String, dynamic> toJson() => {
        'airline':       airline,
        'airlineLogo':   airlineLogo,
        'price':         price,
        'departureTime': departureTime,
        'arrivalTime':   arrivalTime,
        'totalDuration': totalDuration,
        'bookingLink':   bookingLink,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// HotelModel
// ─────────────────────────────────────────────────────────────────────────────

class HotelModel {
  final String name;
  final String location;
  final String pricePerNight;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> amenities;

  const HotelModel({
    required this.name,
    required this.location,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.amenities,
  });

  factory HotelModel.fromJson(Map<String, dynamic> j) => HotelModel(
        name:         j['name']?.toString()     ?? '',
        location:     j['location']?.toString() ?? '',
        pricePerNight: j['price_per_night']?.toString() ?? 'N/A',
        rating:       (j['rating']       as num? ?? 0.0).toDouble(),
        reviewCount:  (j['review_count'] as num? ?? 0).toInt(),
        description:  j['description']?.toString() ?? '',
        amenities:    List<String>.from(j['amenities'] as List<dynamic>? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'name':          name,
        'location':      location,
        'price_per_night': pricePerNight,
        'rating':        rating,
        'review_count':  reviewCount,
        'description':   description,
        'amenities':     amenities,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// RestaurantModel
// ─────────────────────────────────────────────────────────────────────────────

class RestaurantModel {
  final String name;
  final String cuisine;
  final String priceRange;
  final double rating;
  final String description;

  const RestaurantModel({
    required this.name,
    required this.cuisine,
    required this.priceRange,
    required this.rating,
    required this.description,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> j) => RestaurantModel(
        name:        j['name']?.toString()        ?? '',
        cuisine:     j['cuisine']?.toString()     ?? '',
        priceRange:  j['price_range']?.toString() ?? '',
        rating:      (j['rating'] as num? ?? 0.0).toDouble(),
        description: j['description']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name':        name,
        'cuisine':     cuisine,
        'price_range': priceRange,
        'rating':      rating,
        'description': description,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// TravelPlanResult
// Top-level result returned by the backend and stored in ViewModel.
// ─────────────────────────────────────────────────────────────────────────────

class TravelPlanResult {
  final List<FlightModel> flights;
  final List<HotelModel> hotels;
  final List<RestaurantModel> restaurants;
  final String itinerary;
  final String visaStatus;
  final String destinationCountry;

  const TravelPlanResult({
    required this.flights,
    required this.hotels,
    required this.restaurants,
    required this.itinerary,
    this.visaStatus = '',
    this.destinationCountry = '',
  });

  /// Parses the full backend response envelope:
  /// { "success": true, "data": { "flights": [...], "hotels": [...], ... } }
  factory TravelPlanResult.fromEnvelope(Map<String, dynamic> envelope) {
    final data = (envelope['data'] as Map<String, dynamic>?) ?? {};
    return TravelPlanResult(
      flights: (data['flights'] as List<dynamic>? ?? [])
          .map((f) => FlightModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      hotels: (data['hotels'] as List<dynamic>? ?? [])
          .map((h) => HotelModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      restaurants: (data['restaurants'] as List<dynamic>? ?? [])
          .map((r) => RestaurantModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      itinerary:          data['itinerary']?.toString()          ?? '',
      visaStatus:         data['visaStatus']?.toString()         ?? '',
      destinationCountry: data['destinationCountry']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'flights':            flights.map((f) => f.toJson()).toList(),
        'hotels':             hotels.map((h) => h.toJson()).toList(),
        'restaurants':        restaurants.map((r) => r.toJson()).toList(),
        'itinerary':          itinerary,
        'visaStatus':         visaStatus,
        'destinationCountry': destinationCountry,
      };
}
