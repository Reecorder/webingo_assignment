class AirportModel {
  final String airportCode;
  final String city;
  final int flightCount;

  AirportModel({
    required this.airportCode,
    required this.city,
    required this.flightCount,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    return AirportModel(
      airportCode: json['airport_code'],
      city: json['city'],
      flightCount: json['flight_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airport_code': airportCode,
      'city': city,
      'flight_count': flightCount,
    };
  }
}