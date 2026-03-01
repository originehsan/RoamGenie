import '../../../../core/api/travel_api.dart';
// TravelPlanResult, FlightModel, HotelModel, RestaurantModel are re-exported by travel_api.dart

/// TravelPlanRemoteDatasource — wraps TravelApiService.
///
/// Clean Architecture Rule: Datasource = raw API call only.
/// Returns data-layer models; throws Exceptions on failure.
class TravelPlanRemoteDatasource {
  Future<TravelPlanResult> generatePlan({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
  }) =>
      TravelApiService.generateTravelPlan(
        source:        source,
        destination:   destination,
        departureDate: departureDate,
        returnDate:    returnDate,
        budget:        budget,
        flightClass:   flightClass,
        preferences:   preferences,
      );
}
