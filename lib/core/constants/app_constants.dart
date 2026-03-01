/// Popular IATA airport codes → city display names.
/// Used in TravelForm autocomplete.
const Map<String, String> kIataMap = {
  // 🇮🇳 India
  'DEL': 'New Delhi',
  'BOM': 'Mumbai',
  'BLR': 'Bengaluru',
  'MAA': 'Chennai',
  'CCU': 'Kolkata',
  'HYD': 'Hyderabad',
  'COK': 'Kochi',
  'AMD': 'Ahmedabad',
  'PNQ': 'Pune',
  'GOI': 'Goa',
  'JAI': 'Jaipur',
  'LKO': 'Lucknow',
  'VNS': 'Varanasi',
  'IXC': 'Chandigarh',

  // 🌍 International
  'DXB': 'Dubai, UAE',
  'AUH': 'Abu Dhabi, UAE',
  'DOH': 'Doha, Qatar',
  'SIN': 'Singapore',
  'BKK': 'Bangkok',
  'KUL': 'Kuala Lumpur',
  'NRT': 'Tokyo',
  'ICN': 'Seoul',
  'HKG': 'Hong Kong',
  'PEK': 'Beijing',
  'PVG': 'Shanghai',
  'SYD': 'Sydney',
  'LHR': 'London (Heathrow)',
  'CDG': 'Paris',
  'FRA': 'Frankfurt',
  'AMS': 'Amsterdam',
  'BCN': 'Barcelona',
  'FCO': 'Rome',
  'IST': 'Istanbul',
  'ZRH': 'Zurich',
  'JFK': 'New York (JFK)',
  'LAX': 'Los Angeles',
  'ORD': 'Chicago',
  'MIA': 'Miami',
  'SFO': 'San Francisco',
  'DFW': 'Dallas',
  'YYZ': 'Toronto',
  'GRU': 'São Paulo',
  'CAI': 'Cairo',
  'NBO': 'Nairobi',
  'CPT': 'Cape Town',
  'MLE': 'Malé, Maldives',
  'CMB': 'Colombo',
  'KTM': 'Kathmandu',
  'DAC': 'Dhaka',
  'MNL': 'Manila',
  'CGK': 'Jakarta',
};

/// Returns city display name for a code, falls back to the raw code.
String iataToCity(String code) =>
    kIataMap[code.toUpperCase()] ?? code.toUpperCase();

const List<String> kFlightClasses = [
  'Economy',
  'Premium Economy',
  'Business',
  'First Class',
];
