class FlightDetailsModel {
  final FlightDetails flightDetails;
  final List<Passengers> passengers;
  final BookingInfo bookingInfo;

  FlightDetailsModel({
    required this.flightDetails,
    required this.passengers,
    required this.bookingInfo,
  });

  factory FlightDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FlightDetailsModel(
        flightDetails: FlightDetails.fromJson(null),
        passengers: [],
        bookingInfo: BookingInfo.fromJson(null),
      );
    }

    final flightData =
        json["flight_details"] is Map
            ? Map<String, dynamic>.from(json["flight_details"])
            : null;
    final bookingData =
        json["booking_info"] is Map
            ? Map<String, dynamic>.from(json["booking_info"])
            : null;

    List<Passengers> parsedPassengers = [];
    if (json["passengers"] is List) {
      parsedPassengers =
          (json["passengers"] as List).map((x) {
            return Passengers.fromJson(
              x is Map ? Map<String, dynamic>.from(x) : null,
            );
          }).toList();
    }

    return FlightDetailsModel(
      flightDetails: FlightDetails.fromJson(flightData),
      passengers: parsedPassengers,
      bookingInfo: BookingInfo.fromJson(bookingData),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "flight_details": flightDetails.toJson(),
      "passengers": List<dynamic>.from(passengers.map((x) => x.toJson())),
      "booking_info": bookingInfo.toJson(),
    };
  }
}

class FlightDetails {
  final int id;
  final String airlineName;
  final String airlineLogo;
  final String flightId;
  final String flightNumber;
  final Departure departure;
  final Departure arrival;
  final String duration;
  final String aircraftType;
  final int stops;
  final String terminal;
  final String gate;
  final String seatClass;

  FlightDetails({
    required this.id,
    required this.airlineName,
    required this.airlineLogo,
    required this.flightId,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.aircraftType,
    required this.stops,
    required this.terminal,
    required this.gate,
    required this.seatClass,
  });

  factory FlightDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FlightDetails(
        id: 0,
        airlineName: '',
        airlineLogo: '',
        flightId: '',
        flightNumber: '',
        departure: Departure.fromJson(null),
        arrival: Departure.fromJson(null),
        duration: '',
        aircraftType: '',
        stops: 0,
        terminal: '',
        gate: '',
        seatClass: '',
      );
    }

    final depData =
        json["departure"] is Map
            ? Map<String, dynamic>.from(json["departure"])
            : null;
    final arrData =
        json["arrival"] is Map
            ? Map<String, dynamic>.from(json["arrival"])
            : null;

    return FlightDetails(
      id: json["id"] ?? 0,
      airlineName: json["airline_name"] ?? '',
      airlineLogo: json["airline_logo"] ?? '',
      flightId: json["flight_id"] ?? '',
      flightNumber: json["flight_number"] ?? '',
      departure: Departure.fromJson(depData),
      arrival: Departure.fromJson(arrData),
      duration: json["duration"] ?? '',
      aircraftType: json["aircraft_type"] ?? '',
      stops: json["stops"] ?? 0,
      terminal: json["terminal"] ?? '',
      gate: json["gate"] ?? '',
      seatClass: json["class"] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "airline_name": airlineName,
      "airline_logo": airlineLogo,
      "flight_id": flightId,
      "flight_number": flightNumber,
      "departure": departure.toJson(),
      "arrival": arrival.toJson(),
      "duration": duration,
      "aircraft_type": aircraftType,
      "stops": stops,
      "terminal": terminal,
      "gate": gate,
      "class": seatClass,
    };
  }
}

class Departure {
  final String time;
  final String airportCode;
  final String city;

  Departure({
    required this.time,
    required this.airportCode,
    required this.city,
  });

  factory Departure.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return Departure(time: '', airportCode: '', city: '');
    }

    final map = json as Map<String, dynamic>;

    return Departure(
      time: map["time"] ?? '',
      airportCode: map["airport_code"] ?? '',
      city: map["city"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"time": time, "airport_code": airportCode, "city": city};
  }
}

class Passengers {
  final int passengerNumber;
  final String title;
  final String name;
  final String seat;
  final String profilePicture;

  Passengers({
    required this.passengerNumber,
    required this.title,
    required this.name,
    required this.seat,
    required this.profilePicture,
  });

  factory Passengers.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return Passengers(
        passengerNumber: 0,
        title: '',
        name: '',
        seat: '',
        profilePicture: '',
      );
    }

    final map = json as Map<String, dynamic>;

    return Passengers(
      passengerNumber: map["passenger_number"] ?? 0,
      title: map["title"] ?? '',
      name: map["name"] ?? '',
      seat: map["seat"] ?? '',
      profilePicture: map["profile_picture"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "passenger_number": passengerNumber,
      "title": title,
      "name": name,
      "seat": seat,
      "profile_picture": profilePicture,
    };
  }
}

class BookingInfo {
  final int totalPassengers;
  final String bookingReference;
  final String bookingDate;
  final String barcode;

  BookingInfo({
    required this.totalPassengers,
    required this.bookingReference,
    required this.bookingDate,
    required this.barcode,
  });

  factory BookingInfo.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return BookingInfo(
        totalPassengers: 0,
        bookingReference: '',
        bookingDate: '',
        barcode: '',
      );
    }

    final map = json as Map<String, dynamic>;

    return BookingInfo(
      totalPassengers: map["total_passengers"] ?? 0,
      bookingReference: map["booking_reference"] ?? '',
      bookingDate: map["booking_date"] ?? '',
      barcode: map["barcode"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total_passengers": totalPassengers,
      "booking_reference": bookingReference,
      "booking_date": bookingDate,
      "barcode": barcode,
    };
  }
}
