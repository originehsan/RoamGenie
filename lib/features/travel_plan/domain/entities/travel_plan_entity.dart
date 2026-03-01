/// TravelPlanEntity — domain-layer travel plan result.
///
/// Clean Architecture Rule: Entity = pure business object.
class FlightEntity {
  final String airline, airlineLogo, price;
  final String departureTime, arrivalTime, totalDuration, bookingLink;
  const FlightEntity({
    required this.airline, required this.airlineLogo, required this.price,
    required this.departureTime, required this.arrivalTime,
    required this.totalDuration, required this.bookingLink,
  });
}

class HotelEntity {
  final String name, location, pricePerNight, description;
  final double rating;
  final int    reviewCount;
  final List<String> amenities;
  const HotelEntity({
    required this.name, required this.location, required this.pricePerNight,
    required this.description, required this.rating,
    required this.reviewCount, required this.amenities,
  });
}

class RestaurantEntity {
  final String name, cuisine, priceRange, description;
  final double rating;
  const RestaurantEntity({
    required this.name, required this.cuisine, required this.priceRange,
    required this.description, required this.rating,
  });
}

class TravelPlanEntity {
  final List<FlightEntity>     flights;
  final List<HotelEntity>      hotels;
  final List<RestaurantEntity> restaurants;
  final String itinerary, visaStatus, destinationCountry;

  const TravelPlanEntity({
    required this.flights, required this.hotels, required this.restaurants,
    required this.itinerary,
    this.visaStatus = '', this.destinationCountry = '',
  });
}
