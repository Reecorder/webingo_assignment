import "dart:async";

import "package:booking_app/app/routes/app_routes.dart";
import "package:booking_app/app/widgets/snackbar_helper.dart";
import "package:booking_app/data/models/airport_model.dart";
import "package:booking_app/data/models/flight_details.dart";
import "package:booking_app/data/models/flight_model.dart";
import "package:booking_app/services/flight_services.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";

class FlightController extends GetxController {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  Rxn<DateTime> selectedDate = Rxn<DateTime>();

  // Selected airports (set when user taps an item)
  Rxn<AirportModel> selectedFromAirport = Rxn<AirportModel>();
  Rxn<AirportModel> selectedToAirport = Rxn<AirportModel>();

  // UI state for which search list is active
  RxBool isFromFieldActive = false.obs;
  RxBool isToFieldActive = false.obs;

  // Debounce timers for search fields
  Timer? _fromSearchDebounce;
  Timer? _toSearchDebounce;

  // Selected person
  RxString people = "1 People".obs;

  List<String> peopleList = [
    "1 People",
    "2 People",
    "3 People",
    "4 People",
    "5 People",
  ];

  @override
  void onInit() {
    super.onInit();
    applyFilter('Lowest to Highest');

    fromScrollController.addListener(() => _onScroll(type: "from"));
    toScrollController.addListener(() => _onScroll(type: "to"));
  }

  @override
  void onClose() {
    _fromSearchDebounce?.cancel();
    _toSearchDebounce?.cancel();
    _airlineSearchDebounce?.cancel();
    _aircraftTypeSearchDebounce?.cancel();
    fromScrollController.dispose();
    toScrollController.dispose();
    super.onClose();
  }

  // Reactive state for the selected filter
  var selectedFilter = 'Lowest to Highest'.obs;
  final List<String> filters = [
    "Lowest to Highest",
    "Preferred airlines",
    "Flight duration",
  ];

  // Reactive mock flight list (so UI updates when sorted)
  var flightList = <Map<String, dynamic>>[].obs;

  // Toggle location
  void swapLocations() {
    String temp = fromController.text;
    fromController.text = toController.text;
    toController.text = temp;

    final tempSelected = selectedFromAirport.value;
    selectedFromAirport.value = selectedToAirport.value;
    selectedToAirport.value = tempSelected;
  }

  // Date picker dialog
  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    FocusScope.of(Get.context!).unfocus();

    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = formattedDate;
    }
  }

  // Formatting Date
  String get formattedDate {
    if (selectedDate.value == null) {
      return "Select date";
    }

    final date = selectedDate.value!;
    return "${DateFormat("EE").format(date)}, ${DateFormat("d").format(date)} ${DateFormat("MMM").format(date)}";
  }

  // Logic to handle filter taps
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    if (filter == 'Lowest to Highest') {
      flightList.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (filter == 'Flight duration') {
      flightList.sort((a, b) => a['duration'].compareTo(b['duration']));
    } else if (filter == 'Preferred airlines') {
      // Custom alphabetical sort for airlines
      flightList.sort((a, b) => a['airline'].compareTo(b['airline']));
    }
  }

  RxList<AirportModel> fromAirports = <AirportModel>[].obs;
  RxList<AirportModel> toAirports = <AirportModel>[].obs;

  // Filter dropdown data loaded from API
  RxList<String> airlineOptions = <String>[].obs;
  RxList<String> aircraftTypeOptions = <String>[].obs;

  RxBool isLoadingAirlines = false.obs;
  RxBool isLoadingAircraftTypes = false.obs;

  RxString airlineSearchQuery = ''.obs;
  RxString aircraftTypeSearchQuery = ''.obs;

  Timer? _airlineSearchDebounce;
  Timer? _aircraftTypeSearchDebounce;

  RxBool fromAirportSearching = false.obs;
  RxBool toAirportSearching = false.obs;
  RxBool fromAirportLoadingMore = false.obs;
  RxBool toAirportLoadingMore = false.obs;

  RxBool fromHasMore = true.obs;
  RxBool toHasMore = true.obs;

  static const int _pageSize = 10;
  int _fromPage = 1;
  int _toPage = 1;

  final ScrollController fromScrollController = ScrollController();
  final ScrollController toScrollController = ScrollController();

  void setActiveField(String type) {
    if (type == "from") {
      isFromFieldActive(fromController.text.trim().isNotEmpty);
    } else {
      isToFieldActive(toController.text.trim().isNotEmpty);
    }
  }

  void onFromTextChanged(String value) {
    // Clear any previous selection when user types
    selectedFromAirport.value = null;
    setActiveField("from");

    _fromSearchDebounce?.cancel();
    if (value.trim().isEmpty) {
      fromAirports.clear();
      fromHasMore(true);
      _fromPage = 1;
      return;
    }

    _fromSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      _fromPage = 1;
      fromHasMore(true);
      searchAirports(type: "from", page: _fromPage, append: false);
    });
  }

  void onToTextChanged(String value) {
    // Clear any previous selection when user types
    selectedToAirport.value = null;
    setActiveField("to");

    _toSearchDebounce?.cancel();
    if (value.trim().isEmpty) {
      toAirports.clear();
      toHasMore(true);
      _toPage = 1;
      return;
    }

    _toSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      _toPage = 1;
      toHasMore(true);
      searchAirports(type: "to", page: _toPage, append: false);
    });
  }

  void selectAirport({required String type, required AirportModel airport}) {
    if (type == "from") {
      selectedFromAirport.value = airport;
      fromController.text = "${airport.airportCode} - ${airport.city}";
      fromAirports.clear();
      isFromFieldActive(false);
    } else {
      selectedToAirport.value = airport;
      toController.text = "${airport.airportCode} - ${airport.city}";
      toAirports.clear();
      isToFieldActive(false);
    }

    // Unfocus keyboard after selection
    FocusScope.of(Get.context!).unfocus();
  }

  void _onScroll({required String type}) {
    final controller =
        type == "from" ? fromScrollController : toScrollController;
    final hasMore = type == "from" ? fromHasMore.value : toHasMore.value;
    final isLoading =
        type == "from"
            ? fromAirportLoadingMore.value
            : toAirportLoadingMore.value;

    if (!hasMore || isLoading) return;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 60) {
      _loadMore(type);
    }
  }

  void _loadMore(String type) {
    if (type == "from") {
      if (!fromHasMore.value || fromAirportLoadingMore.value) return;
      fromAirportLoadingMore(true);
      _fromPage++;
      searchAirports(type: type, page: _fromPage, append: true);
    } else {
      if (!toHasMore.value || toAirportLoadingMore.value) return;
      toAirportLoadingMore(true);
      _toPage++;
      searchAirports(type: type, page: _toPage, append: true);
    }
  }

  void searchAirports({
    required String type,
    int page = 1,
    bool append = false,
  }) async {
    // Avoid running search when input is empty.
    final keyword =
        (type == "from" ? fromController.text : toController.text).trim();

    if (keyword.isEmpty) {
      if (type == "from") {
        fromAirports.clear();
      } else {
        toAirports.clear();
      }
      return;
    }

    if (!append) {
      if (type == "from") {
        fromAirportSearching(true);
      } else {
        toAirportSearching(true);
      }
    }

    final Map<String, dynamic> requestData = {
      "search": keyword,
      "limit": _pageSize,
      "page": page,
    };

    try {
      final response = await FlightServices().searchAirports(
        type: type,
        requestData: requestData,
      );

      final List<AirportModel> airports =
          response['airports'] as List<AirportModel>;
      final Map<String, dynamic> pagination =
          response['pagination'] as Map<String, dynamic>? ?? {};
      final bool hasNextPage = pagination['hasNextPage'] == true;

      if (type == "from") {
        if (append) {
          fromAirports.addAll(airports);
        } else {
          fromAirports
            ..clear()
            ..addAll(airports);
        }
        fromHasMore(hasNextPage);
        fromAirportLoadingMore(false);
      } else {
        if (append) {
          toAirports.addAll(airports);
        } else {
          toAirports
            ..clear()
            ..addAll(airports);
        }
        toHasMore(hasNextPage);
        toAirportLoadingMore(false);
      }
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      if (type == "from") {
        fromAirportLoadingMore(false);
        if (!append) fromAirportSearching(false);
      } else {
        toAirportLoadingMore(false);
        if (!append) toAirportSearching(false);
      }
    }
  }

  /// Loads filter reference data used by the filter sheet (airlines & aircraft types).
  Future<void> loadFilterData() async {
    await Future.wait([fetchAirlines(), fetchAircraftTypes()]);
  }

  /// Fetches airlines used for the filter dropdown.
  Future<void> fetchAirlines({String search = ""}) async {
    isLoadingAirlines(true);

    try {
      final response = await FlightServices().searchAirlines(
        requestData: {"search": search, "limit": _pageSize, "page": 1},
      );

      airlineOptions
        ..clear()
        ..addAll((response["airlines"] as List).cast<String>());
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoadingAirlines(false);
    }
  }

  /// Fetches aircraft types used for the filter dropdown.
  Future<void> fetchAircraftTypes({String search = ""}) async {
    isLoadingAircraftTypes(true);

    try {
      final response = await FlightServices().searchAircraftTypes(
        requestData: {"search": search, "limit": _pageSize, "page": 1},
      );

      aircraftTypeOptions
        ..clear()
        ..addAll((response["aircraftTypes"] as List).cast<String>());
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoadingAircraftTypes(false);
    }
  }

  void onAirlineSearchChanged(String value) {
    airlineSearchQuery.value = value;
    _airlineSearchDebounce?.cancel();
    _airlineSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      fetchAirlines(search: value);
    });
  }

  void onAircraftTypeSearchChanged(String value) {
    aircraftTypeSearchQuery.value = value;
    _aircraftTypeSearchDebounce?.cancel();
    _aircraftTypeSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      fetchAircraftTypes(search: value);
    });
  }

  List<String> sortOptions = [
    "Lowest Price to Highest",
    "Shortest Duration",
    "Earliest Departure",
  ];
  RxString selectedSortOption = "Lowest Price to Highest".obs;
  RxInt currentPage = 1.obs;
  RxBool hasNextPage = false.obs;
  RxBool isSearchingFlights = false.obs;
  RxBool isLoadingMoreFlights = false.obs;
  RxList<FlightModel> foundFlights = <FlightModel>[].obs;

  /// Initiates a flight search using the configured inputs.
  Future<void> findFlights({
    bool navigate = true,
    bool isLoadMore = false,
  }) async {
    if (selectedFromAirport.value == null || selectedToAirport.value == null) {
      SnackbarHelper.showError(
        "Please select both departure and arrival airports.",
      );
      return;
    }

    //  Handle Pagination State
    if (isLoadMore) {
      if (!hasNextPage.value || isLoadingMoreFlights.value) return;
      isLoadingMoreFlights(true);
      currentPage.value++;
    } else {
      isSearchingFlights(true);
      currentPage.value = 1;
      hasNextPage.value = false;
    }

    final int passengers = int.tryParse(people.value.split(" ").first) ?? 1;

    String sortBy;
    switch (selectedSortOption.value) {
      case "Shortest Duration":
        sortBy = "duration_asc";
        break;
      case "Earliest Departure":
        sortBy = "departure_asc";
        break;
      case "Lowest Price to Highest":
      default:
        sortBy = "price_asc";
    }

    final searchDate =
        selectedDate.value != null
            ? DateFormat("yyyy-MM-dd").format(selectedDate.value!)
            : "";

    //  Add the page parameter to the request body
    final requestData = {
      "from": selectedFromAirport.value!.airportCode,
      "to": selectedToAirport.value!.airportCode,
      "date": searchDate,
      "passengers": passengers,
      "sort_by": sortBy,
      "page": currentPage.value,
      "limit": 10,
      "filters": {
        "airline": activeFilters["airline"] ?? "",
        "price_min": activeFilters["price_min"] ?? 0,
        "price_max": activeFilters["price_max"] ?? 0,
        "stops": activeFilters["stops"] ?? 0,
        "aircraft_type": activeFilters["aircraft_type"] ?? "",
      },
    };

    try {
      final response = await FlightServices().searchFlights(
        requestData: requestData,
      );

      final List<FlightModel> flights =
          response["flights"] as List<FlightModel>;
      final Map<String, dynamic> paginationInfo = response["pagination"];

      //Update pagination state based on API response
      hasNextPage.value = paginationInfo["hasNextPage"] ?? false;

      // Append or Replace data
      if (isLoadMore) {
        foundFlights.addAll(flights);
      } else {
        foundFlights.assignAll(flights);
      }

      if (foundFlights.isEmpty && !isLoadMore) {
        SnackbarHelper.showError("No flights found for the selected route.");
      }

      if (navigate && !isLoadMore) {
        Get.toNamed(Routes.flightList);
      }
    } catch (e) {
      SnackbarHelper.showError(e.toString());
      // Revert page count if pagination fails
      if (isLoadMore) currentPage.value--;
    } finally {
      isSearchingFlights(false);
      isLoadingMoreFlights(false);
    }
  }

  // Helper method to trigger from the UI
  void loadMoreFlights() {
    findFlights(navigate: false, isLoadMore: true);
  }

  RxMap<String, dynamic> activeFilters =
      <String, dynamic>{
        "airline": "",
        "price_min": 0,
        "price_max": 0,
        "stops": 0,
        "aircraft_type": "",
      }.obs;

  /// Stores the given filters and re-triggers a flight search in place
  void applyFiltersAndSearch(Map<String, dynamic> filters) {
    activeFilters.assignAll(filters);
    findFlights(navigate: false);
  }

  RxBool isSearchingFlightDetails = false.obs;
  Rxn<FlightDetailsModel> selectedFlightDetails = Rxn<FlightDetailsModel>();

  /// Fetches detailed information for a specific flight by its ID.
  /// This can be used to power the flight details page.
  Future<void> getFlightDetails(int flightId) async {
    try {
      isSearchingFlightDetails(true);

      // The service now returns the Model directly!
      final flightDetails = await FlightServices().fetchFlightDetails(
        flightId: flightId,
      );

      // Assign the model directly to the Rx variable
      selectedFlightDetails.value = flightDetails;
    } catch (e) {
      SnackbarHelper.showError(e.toString());
      selectedFlightDetails.value = null;
    } finally {
      isSearchingFlightDetails(false);
    }
  }
}
