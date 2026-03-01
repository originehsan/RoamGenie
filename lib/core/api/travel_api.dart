import 'package:dio/dio.dart';
import 'api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS — keys match backend POST /api/travel/plan response exactly.
// Backend path: POST /api/travel/plan
// Response envelope: { "success": true, "message": "...", "data": { ... } }
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
    airline: j['airline']?.toString() ?? 'Unknown Airline',
    airlineLogo: j['airlineLogo']?.toString() ?? '',
    price: j['price']?.toString() ?? 'N/A',
    departureTime: j['departureTime']?.toString() ?? '--:--',
    arrivalTime: j['arrivalTime']?.toString() ?? '--:--',
    totalDuration: j['totalDuration']?.toString() ?? 'N/A',
    bookingLink: j['bookingLink']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'airline': airline,
    'airlineLogo': airlineLogo,
    'price': price,
    'departureTime': departureTime,
    'arrivalTime': arrivalTime,
    'totalDuration': totalDuration,
    'bookingLink': bookingLink,
  };
}

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
    name: j['name']?.toString() ?? '',
    location: j['location']?.toString() ?? '',
    pricePerNight: j['price_per_night']?.toString() ?? 'N/A',
    rating: (j['rating'] as num? ?? 0.0).toDouble(),
    reviewCount: (j['review_count'] as num? ?? 0).toInt(),
    description: j['description']?.toString() ?? '',
    amenities: List<String>.from(j['amenities'] as List<dynamic>? ?? []),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'price_per_night': pricePerNight,
    'rating': rating,
    'review_count': reviewCount,
    'description': description,
    'amenities': amenities,
  };
}

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
    name: j['name']?.toString() ?? '',
    cuisine: j['cuisine']?.toString() ?? '',
    priceRange: j['price_range']?.toString() ?? '',
    rating: (j['rating'] as num? ?? 0.0).toDouble(),
    description: j['description']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'cuisine': cuisine,
    'price_range': priceRange,
    'rating': rating,
    'description': description,
  };
}

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

  /// Parses the full backend envelope:
  /// {
  ///   "success": true,
  ///   "message": "Travel plan generated successfully",
  ///   "data": {
  ///     "flights": [...],
  ///     "hotels": [...],
  ///     "restaurants": [...],
  ///     "itinerary": "## Day 1 ...",
  ///     "visaStatus": "...",
  ///     "destinationCountry": "Thailand"
  ///   }
  /// }
  factory TravelPlanResult.fromEnvelope(Map<String, dynamic> envelope) {
    final data = (envelope['data'] as Map<String, dynamic>?) ?? {};
    return TravelPlanResult._fromData(data);
  }

  factory TravelPlanResult._fromData(Map<String, dynamic> data) {
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
      itinerary: data['itinerary']?.toString() ?? '',
      visaStatus: data['visaStatus']?.toString() ?? '',
      destinationCountry: data['destinationCountry']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRAVEL API SERVICE — uses Dio directly for the travel plan endpoint.
// Backend endpoint: POST /api/travel/plan
// ─────────────────────────────────────────────────────────────────────────────

class TravelApiService {
  static final Dio _dio = _buildDio();

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        // AI calls (Gemini + SerpAPI) can take 20–40 s; generous timeout
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
  }

  /// Calls POST /api/travel/plan and returns a structured [TravelPlanResult].
  ///
  /// URL is built from [ApiConfig.baseUrl] — never hardcoded here.
  /// Throws an [Exception] on failure so [TravelPlanViewModel] can surface
  /// a proper error state and retry button in the UI.
  ///
  /// Body keys (per backend docs):
  ///   source, destination, departureDate, returnDate — required
  ///   budget, flightClass, preferences — optional
  static Future<TravelPlanResult> generateTravelPlan({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/travel/plan',
        data: {
          'source': source,
          'destination': destination,
          'departureDate': departureDate,
          'returnDate': returnDate,
          'budget': budget,
          'flightClass': flightClass,
          'preferences': preferences,
        },
        options: Options(
          // AI calls can be slow — use 90-second receive timeout
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      final envelope = response.data;
      if (envelope == null) {
        throw Exception('Empty response from server.');
      }

      if (envelope['success'] != true) {
        final msg =
            envelope['message'] as String? ??
            envelope['error'] as String? ??
            'Server error.';
        throw Exception(msg);
      }

      return TravelPlanResult.fromEnvelope(envelope);
    } on DioException catch (e) {
      throw Exception(_friendlyDioError(e));
    }
  }

  static String _friendlyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please check your internet.';

      case DioExceptionType.receiveTimeout:
        return 'The AI is taking too long. Please try again in a moment.';

      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        if (statusCode == 400) {
          if (data is Map) {
            return data['message'] as String? ??
                data['error'] as String? ??
                'Missing required fields.';
          }
          return 'Missing required fields.';
        }
        if (statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        }
        return 'Server error (HTTP $statusCode). Please try again.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      default:
        return 'Network error: ${e.message}';
    }
  }
}
