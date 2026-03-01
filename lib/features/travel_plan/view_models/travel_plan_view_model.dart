import 'package:flutter/foundation.dart';
import '../../../core/api/travel_api.dart'; // TravelPlanResult, FlightModel, HotelModel, RestaurantModel
import '../data/datasources/travel_plan_remote_datasource.dart';
import '../../../core/widgets/app_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TravelPlanViewModel
//
// SINGLE LOADING SOURCE:
//   loadingType == LoadingType.screen → full-page shimmer + 3-dot loader
//   loadingType == LoadingType.button → button shows dots, page stays visible
//   loadingType == LoadingType.none   → normal UI
//
// The UI MUST check loadingType (not a raw bool) so only ONE loader
// is ever shown at a time.
// ─────────────────────────────────────────────────────────────────────────────

class TravelPlanViewModel extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────────
  LoadingType _loadingType = LoadingType.none;
  String? _error;
  TravelPlanResult? _result;

  String _lastSource = '';
  String _lastDestination = '';

  // ── Getters ──────────────────────────────────────────────────────────────

  /// Single loading type — UI must react to THIS, not separate booleans.
  LoadingType get loadingType => _loadingType;

  /// Convenience: any loading is in progress
  bool get loading => _loadingType != LoadingType.none;

  /// True only when a screen-level load is happening
  bool get screenLoading => _loadingType == LoadingType.screen;

  /// True only when a button-level load is happening
  bool get buttonLoading => _loadingType == LoadingType.button;

  String? get error => _error;
  TravelPlanResult? get result => _result;
  bool get hasResult => _result != null;

  List<FlightModel> get flights => _result?.flights ?? [];
  List<HotelModel> get hotels => _result?.hotels ?? [];
  List<RestaurantModel> get restaurants => _result?.restaurants ?? [];
  String get itinerary => _result?.itinerary ?? '';

  String get lastSource => _lastSource;
  String get lastDestination => _lastDestination;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Call the backend and store the result.
  ///
  /// If [isFirstLoad] is true, shows the screen-level loader (first plan).
  /// On subsequent loads (retry, plan another), shows ONLY the button loader.
  Future<void> generateTravelPlan({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
    bool isFirstLoad = true,
  }) async {
    // RULE: pick ONE loader type
    _loadingType = isFirstLoad ? LoadingType.screen : LoadingType.button;
    _error = null;
    _result = null;
    _lastSource = source;
    _lastDestination = destination;
    notifyListeners();

    try {
      final ds = TravelPlanRemoteDatasource();
      final result = await ds.generatePlan(
        source: source,
        destination: destination,
        departureDate: departureDate,
        returnDate: returnDate,
        budget: budget,
        flightClass: flightClass,
        preferences: preferences,
      );
      _result = result;
    } catch (e) {
      _error =
          'Could not load travel plan. Please try again.\n${e.toString()}';
    } finally {
      _loadingType = LoadingType.none;
      notifyListeners();
    }
  }

  /// Reset all state — useful for "Plan Another Trip" button.
  void reset() {
    _result = null;
    _error = null;
    _loadingType = LoadingType.none;
    _lastSource = '';
    _lastDestination = '';
    notifyListeners();
  }
}
