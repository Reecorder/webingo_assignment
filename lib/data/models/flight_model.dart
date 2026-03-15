class FlightModel {
  final int id;
  final String airlineName;
  final String airlineLogo;
  final String flightNumber;
  final AirportInfo departure;
  final AirportInfo arrival;
  final String duration;
  final Price price;
  final String aircraftType;
  final int stops;
  final String createdAt;
  final String updatedAt;

  FlightModel({
    required this.id,
    required this.airlineName,
    required this.airlineLogo,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.price,
    required this.aircraftType,
    required this.stops,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json["id"],
      airlineName: json["airline_name"],
      airlineLogo: json["airline_logo"],
      flightNumber: json["flight_number"],
      departure: AirportInfo.fromJson(json["departure"]),
      arrival: AirportInfo.fromJson(json["arrival"]),
      duration: json["duration"],
      price: Price.fromJson(json["price"]),
      aircraftType: json["aircraft_type"],
      stops: json["stops"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "airline_name": airlineName,
      "airline_logo": airlineLogo,
      "flight_number": flightNumber,
      "departure": departure.toJson(),
      "arrival": arrival.toJson(),
      "duration": duration,
      "price": price.toJson(),
      "aircraft_type": aircraftType,
      "stops": stops,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

class AirportInfo {
  final String time;
  final String airportCode;
  final String city;

  AirportInfo({
    required this.time,
    required this.airportCode,
    required this.city,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      time: json["time"],
      airportCode: json["airport_code"],
      city: json["city"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"time": time, "airport_code": airportCode, "city": city};
  }
}

class Price {
  final int amount;
  final String currency;

  Price({required this.amount, required this.currency});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(amount: json["amount"], currency: json["currency"]);
  }

  Map<String, dynamic> toJson() {
    return {"amount": amount, "currency": currency};
  }
}
