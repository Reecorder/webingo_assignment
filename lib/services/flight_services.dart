import "package:booking_app/app/constants/endpoints.dart";
import "package:booking_app/data/models/airport_model.dart";
import "package:booking_app/data/models/flight_details.dart";
import "package:booking_app/data/models/flight_model.dart";
import "package:booking_app/data/providers/api_provider.dart";
import "package:dio/dio.dart";

class FlightServices {
  // Search departure airports
  Future<Map<String, dynamic>> searchAirports({
    required String type,
    required Map<String, dynamic> requestData,
  }) async {
    final endpoint =
        type == "from" ? Endpoints.fromAirport : Endpoints.toAirport;
    try {
      final Response response = await ApiProvider().post(
        endpoint,
        data: requestData,
      );

      final data = response.data;

      if (data["status"] != "success") {
        throw Exception(data["message"] ?? "Failed to fetch airports");
      }

      final List airports = data["data"]["airports"];
      final pagination = data["data"]["pagination"] as Map<String, dynamic>?;

      return {
        "airports":
            airports.map((airport) => AirportModel.fromJson(airport)).toList(),
        "pagination": pagination ?? {},
      };
    } catch (e) {
      rethrow;
    }
  }

  // Search airlines for the filters list
  Future<Map<String, dynamic>> searchAirlines({
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final Response response = await ApiProvider().post(
        Endpoints.airlines,
        data: requestData,
      );

      final data = response.data;

      if (data["status"] != "success") {
        throw Exception(data["message"] ?? "Failed to fetch airlines");
      }

      final List airlines = data["data"]["airlines"];
      final pagination = data["data"]["pagination"] as Map<String, dynamic>?;

      return {
        "airlines": airlines.map((item) => item["airline"].toString()).toList(),
        "pagination": pagination ?? {},
      };
    } catch (e) {
      rethrow;
    }
  }

  // Search aircraft types for the filters list
  Future<Map<String, dynamic>> searchAircraftTypes({
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final Response response = await ApiProvider().post(
        Endpoints.aircraftTypes,
        data: requestData,
      );

      final data = response.data;

      if (data["status"] != "success") {
        throw Exception(data["message"] ?? "Failed to fetch aircraft types");
      }

      final List types = data["data"]["aircraft_types"];
      final pagination = data["data"]["pagination"] as Map<String, dynamic>?;

      return {
        "aircraftTypes":
            types.map((item) => item["aircraft"].toString()).toList(),
        "pagination": pagination ?? {},
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Search for flights using the API endpoint.
  Future<Map<String, dynamic>> searchFlights({
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final Response response = await ApiProvider().post(
        Endpoints.searchFlights,
        data: requestData,
      );

      final data = response.data;

      if (data["status"] != "success") {
        throw Exception(data["message"] ?? "Failed to fetch flights");
      }

      final flights = data["data"]["flights"] as List;
      final searchParams =
          data["data"]["search_params"] as Map<String, dynamic>?;
      final pagination = data["data"]["pagination"] as Map<String, dynamic>?;

      return {
        "flights":
            flights.map((flight) => FlightModel.fromJson(flight)).toList(),
        "searchParams": searchParams ?? {},
        "pagination": pagination ?? {},
      };
    } catch (e) {
      rethrow;
    }
  }

  // Fetch detailed information for a specific flight
  Future<FlightDetailsModel> fetchFlightDetails({required int flightId}) async {
    try {
      final Response response = await ApiProvider().post(
        Endpoints.flightDetails,
        data: {"id": flightId},
      );

      final data = response.data;

      if (data["status"] != "success") {
        throw Exception(data["message"] ?? "Failed to fetch flight details");
      }

      final details = data["data"] as Map<String, dynamic>?;

      // Parse and return the model
      return FlightDetailsModel.fromJson(details);
    } catch (e) {
      rethrow;
    }
  }
}
