import '../entities/travel_plan_entity.dart';

/// ITravelPlanRepository — domain-layer contract.
abstract class ITravelPlanRepository {
  Future<TravelPlanEntity> generatePlan({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
  });
}
