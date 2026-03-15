import "package:booking_app/app/widgets/airline_header.dart";
import "package:booking_app/app/widgets/background.dart";
import "package:booking_app/app/widgets/flight_route.dart";
import "package:booking_app/app/widgets/universel_card.dart";
import "package:booking_app/app/theme/app_colors.dart";
import "package:booking_app/app/widgets/bottom_nav.dart";
import "package:booking_app/app/widgets/common_button.dart";
import "package:booking_app/app/widgets/common_textfield.dart";
import "package:booking_app/app/widgets/snackbar_helper.dart";
import "package:booking_app/data/models/airport_model.dart";
import "package:booking_app/modules/flight/controllers/flight_controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

class FlightSearchPage extends StatelessWidget {
  FlightSearchPage({super.key});

  final flightController = Get.find<FlightController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(),
      body: BackgroundGrad(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: Get.height * 0.05,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: ListView(
              children: [
                topSectionProfileImg(),
                searchFlightSection(),
                savedTrips,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchFlightSection() => Container(
    margin: EdgeInsets.only(top: 30),
    width: Get.width,
    decoration: searchFlightSectionDecoration,
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      children: [
        SizedBox(height: 10),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Column(
              children: [
                // From location textfield
                CommonTextField(
                  hint: "Where are you flying from?",
                  label: "From",
                  controller: flightController.fromController,
                  onChanged: flightController.onFromTextChanged,
                ),

                Obx(() {
                  if (!flightController.isFromFieldActive.value) {
                    return const SizedBox.shrink();
                  }

                  return airportSuggestionsList(
                    airports: flightController.fromAirports,
                    searching: flightController.fromAirportSearching,
                    loadingMore: flightController.fromAirportLoadingMore.value,
                    scrollController: flightController.fromScrollController,
                    type: "from",
                  );
                }),

                // To location textfield
                CommonTextField(
                  hint: "Where are you flying to?",
                  label: "To",
                  controller: flightController.toController,
                  onChanged: flightController.onToTextChanged,
                ),

                Obx(() {
                  if (!flightController.isToFieldActive.value) {
                    return const SizedBox.shrink();
                  }

                  return airportSuggestionsList(
                    airports: flightController.toAirports,
                    searching: flightController.toAirportSearching,
                    loadingMore: flightController.toAirportLoadingMore.value,
                    scrollController: flightController.toScrollController,
                    type: "to",
                  );
                }),
              ],
            ),

            Positioned(
              right: 10,
              top: 40,
              child: InkWell(
                onTap: flightController.swapLocations,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(LucideIcons.arrowDownUp300, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),

        // Departure Date and selected person
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                readOnly: true,
                controller: flightController.dateController,
                label: "Departure",
                hint: "Departure Date",
                suffixIcon: Icon(
                  LucideIcons.calendarDays300,
                  size: 20,
                  color: Colors.black54,
                ),
                onTap: () => flightController.pickDate(Get.context!),
              ),
            ),

            SizedBox(width: 10),

            // Person
            Expanded(
              child: Obx(
                () => DropdownButtonFormField(
                  value: flightController.people.value,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    labelStyle: TextStyle(color: AppColors.textPrimary),
                  ),
                  items:
                      flightController.peopleList.map((person) {
                        return DropdownMenuItem(
                          value: person,
                          child: Text(person),
                        );
                      }).toList(),
                  onChanged: (value) {
                    flightController.people.value = value!;
                  },
                ),
              ),
            ),
          ],
        ),

        // Search flight button
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child:
                flightController.isSearchingFlights.value
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : CommonButton(
                      width: Get.width,
                      buttonText: "Search Flights",
                      onChanged: () {
                        if (flightController.selectedFromAirport.value ==
                            null) {
                          SnackbarHelper.showError(
                            "Please select a departure airport.",
                          );
                          return;
                        }
                        if (flightController.selectedToAirport.value == null) {
                          SnackbarHelper.showError(
                            "Please select a destination airport.",
                          );
                          return;
                        }
                        if (flightController.dateController.text.isEmpty) {
                          SnackbarHelper.showError(
                            "Please select a departure date",
                          );
                          return;
                        }

                        flightController.findFlights();
                      },
                    ),
          ),
        ),
      ],
    ),
  );

  // Airport list UI
  Widget airportSuggestionsList({
    required List<AirportModel> airports,
    required RxBool searching,
    required bool loadingMore,
    required ScrollController scrollController,
    required String type,
  }) {
    return Container(
      height: Get.height * 0.2,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() {
        if (searching.value && airports.isEmpty) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (airports.isEmpty) {
          return const Center(
            child: Text(
              "No airports found",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: airports.length + (loadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index >= airports.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final airport = airports[index];
            return ListTile(
              onTap:
                  () => flightController.selectAirport(
                    type: type,
                    airport: airport,
                  ),
              title: Text(
                airport.airportCode,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(airport.city),
              trailing: Text(
                "${airport.flightCount} flights",
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      }),
    );
  }

  // Search flight decoration
  Decoration get searchFlightSectionDecoration => BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(11, 0, 0, 0),
        blurRadius: 30,
        spreadRadius: 2,
        offset: const Offset(0, 12),
      ),
    ],
    border: Border.all(color: Colors.white, width: 2),
    borderRadius: BorderRadius.circular(30),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFDCE7F7), Color(0xFFFFFFFF)],
    ),
  );

  // Top section - Title and the logged in user profile image
  Widget topSectionProfileImg() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Plan your trip",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w400,
        ),
      ),
      CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            "https://plus.unsplash.com/premium_photo-1668485966810-cbd0f685f58f?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ],
  );

  // Saved trips
  Widget get savedTrips => Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Saved Trips",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              "See more",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: UniversalTicketCard(
                  cardWidth: Get.width * 0.85,
                  cardHeight: 220,
                  dividerPosition: 130,
                  topContent: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      AirlineHeader(
                        logoPath: 'assets/logo.png',
                        isCentered: true,
                      ),
                      FlightRouteSection(
                        fromCode: 'CGK',
                        fromCity: 'Jakarta',
                        toCode: 'NRT',
                        toCity: 'Tokyo',
                        departureTime: '07:47',
                        arrivalTime: '14:30',
                        duration: '7h 20m',
                      ),
                    ],
                  ),
                  bottomContent: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "DATE",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "14 Mar, 2026",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "DATE",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "14 Mar, 2026",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
