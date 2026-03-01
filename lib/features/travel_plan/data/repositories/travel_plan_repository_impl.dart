import '../datasources/travel_plan_remote_datasource.dart';
import '../../../../core/api/travel_api.dart'; // TravelPlanResult, FlightModel, HotelModel, RestaurantModel
import '../../domain/entities/travel_plan_entity.dart';
import '../../domain/repositories/i_travel_plan_repository.dart';

/// TravelPlanRepositoryImpl — maps data models → domain entities.
class TravelPlanRepositoryImpl implements ITravelPlanRepository {
  final TravelPlanRemoteDatasource _datasource;

  TravelPlanRepositoryImpl({TravelPlanRemoteDatasource? datasource})
      : _datasource = datasource ?? TravelPlanRemoteDatasource();

  @override
  Future<TravelPlanEntity> generatePlan({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
  }) async {
    final result = await _datasource.generatePlan(
      source:        source,
      destination:   destination,
      departureDate: departureDate,
      returnDate:    returnDate,
      budget:        budget,
      flightClass:   flightClass,
      preferences:   preferences,
    );
    return _toEntity(result);
  }

  // ── Mapper ────────────────────────────────────────────────────────────────────
  TravelPlanEntity _toEntity(TravelPlanResult m) => TravelPlanEntity(
        flights:            m.flights.map(_flightToEntity).toList(),
        hotels:             m.hotels.map(_hotelToEntity).toList(),
        restaurants:        m.restaurants.map(_restToEntity).toList(),
        itinerary:          m.itinerary,
        visaStatus:         m.visaStatus,
        destinationCountry: m.destinationCountry,
      );

  FlightEntity _flightToEntity(FlightModel m) => FlightEntity(
        airline:       m.airline,
        airlineLogo:   m.airlineLogo,
        price:         m.price,
        departureTime: m.departureTime,
        arrivalTime:   m.arrivalTime,
        totalDuration: m.totalDuration,
        bookingLink:   m.bookingLink,
      );

  HotelEntity _hotelToEntity(HotelModel m) => HotelEntity(
        name:         m.name,
        location:     m.location,
        pricePerNight: m.pricePerNight,
        description:  m.description,
        rating:       m.rating,
        reviewCount:  m.reviewCount,
        amenities:    m.amenities,
      );

  RestaurantEntity _restToEntity(RestaurantModel m) => RestaurantEntity(
        name:        m.name,
        cuisine:     m.cuisine,
        priceRange:  m.priceRange,
        description: m.description,
        rating:      m.rating,
      );
}
