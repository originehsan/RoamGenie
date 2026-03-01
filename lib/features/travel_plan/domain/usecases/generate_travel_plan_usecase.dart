import '../entities/travel_plan_entity.dart';
import '../repositories/i_travel_plan_repository.dart';

/// GenerateTravelPlanUseCase — single-responsibility: plan a trip.
class GenerateTravelPlanUseCase {
  final ITravelPlanRepository _repository;
  const GenerateTravelPlanUseCase(this._repository);

  Future<TravelPlanEntity> call({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
  }) =>
      _repository.generatePlan(
        source:        source,
        destination:   destination,
        departureDate: departureDate,
        returnDate:    returnDate,
        budget:        budget,
        flightClass:   flightClass,
        preferences:   preferences,
      );
}
