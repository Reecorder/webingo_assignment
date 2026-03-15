import "package:booking_app/app/widgets/common_button.dart";
import "package:flutter/services.dart";
import "package:gal/gal.dart";
import "package:booking_app/app/theme/app_colors.dart";
import "package:booking_app/app/widgets/background.dart";
import "package:booking_app/app/widgets/universel_card.dart";
import "package:booking_app/app/widgets/custom_appbar.dart";
import "package:booking_app/app/widgets/flight_route.dart";
import "package:booking_app/data/models/flight_details.dart";
import "package:booking_app/modules/flight/controllers/flight_controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';

class FlightDetailsPage extends StatefulWidget {
  const FlightDetailsPage({super.key});

  @override
  State<FlightDetailsPage> createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
  final FlightController flightController = Get.find<FlightController>();
  final ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGrad(
        gradColors: const [Color(0xFFC4C9D5), Color(0xFFE1E1E2), Color(0xFFF0F1F3)],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const CommonAppBar(title: "Your Flight Details"),
              _flightdetailsSection(),

              Obx(
                () =>
                    flightController.isSearchingFlightDetails.value
                        ? const SizedBox.shrink()
                        : _downloadPassButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── Flight Details & Loader ────────────────────────────────────────────────────────
  Widget _flightdetailsSection() => Obx(() {
    if (flightController.isSearchingFlightDetails.value) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final flight = flightController.selectedFlightDetails.value?.flightDetails;

    if (flight == null) {
      return const Expanded(child: Center(child: Text("Could not load flight details.")));
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                _flightInfoCard(),
                const SizedBox(height: 16),
                _passengerInfoCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  });

  // ─── Flight & Terminal Info ──────────────────────────────────────────────────

  Widget _flightInfoCard() => Obx(() {
    final flight = flightController.selectedFlightDetails.value?.flightDetails;

    if (flight == null) {
      return const SizedBox(height: 230, child: Center(child: CircularProgressIndicator()));
    }

    return UniversalTicketCard(
      cardHeight: 230,
      dividerPosition: 140,
      topContent: _buildTopContent(flight),
      bottomContent: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoColumn("TERMINAL", flight.terminal),
          _infoColumn("GATE", flight.gate),
          _infoColumn("Class", flight.seatClass),
        ],
      ),
    );
  });

  // ─── Flight Info ────────────────────────────────────────────────
  Widget _buildTopContent(FlightDetails flight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    radius: 18,
                    backgroundImage: NetworkImage(flight.airlineLogo),
                    child: const Icon(Icons.flight, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      flight.airlineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            Text(
              flight.flightId,
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        // Flight Route Section
        FlightRouteSection(
          fromCode: flight.departure.airportCode,
          fromCity: flight.departure.city,
          toCode: flight.arrival.airportCode,
          toCity: flight.arrival.city,
          departureTime: flight.departure.time.substring(0, 5),
          arrivalTime: flight.arrival.time.substring(0, 5),
          duration: flight.duration,
        ),
      ],
    );
  }

  // ─── Passenger Info & Barcode ────────────────────────────────────────────────

  Widget _passengerInfoCard() => Obx(() {
    final passengers = flightController.selectedFlightDetails.value?.passengers ?? [];
    final flight = flightController.selectedFlightDetails.value?.flightDetails;

    if (passengers.isEmpty) return const SizedBox.shrink();

    // Dynamic Height Calculation based on the reactive list
    double calculatedDividerPosition = 80.0 + (passengers.length * 65.0);
    double calculatedCardHeight = calculatedDividerPosition + 125.0;

    return UniversalTicketCard(
      cardHeight: calculatedCardHeight,
      dividerPosition: calculatedDividerPosition,
      topContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Passengers Info",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          // Loop through the controller's passenger list
          ...List.generate(passengers.length, (index) {
            final p = passengers[index];
            return Column(
              children: [
                _passengerRow(
                  "PASSENGER ${p.passengerNumber}",
                  "${p.title} ${p.name}",
                  p.seat,
                  p.profilePicture,
                ),

                // Add the divider ONLY if it's not the very last passenger
                if (index != passengers.length - 1)
                  const Divider(
                    color: Color.fromARGB(163, 158, 158, 158),
                    height: 30,
                    thickness: 1,
                  ),
              ],
            );
          }),
        ],
      ),
      bottomContent: Center(child: _realBarcodeWidget(flight!.flightId)),
    );
  });

  // ─── Reusable Section Widgets ────────────────────────────────────────────────

  Widget _infoColumn(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    ],
  );

  Widget _passengerRow(String label, String name, String seat, String imageUrl) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10, letterSpacing: 0.5),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "SEAT",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, letterSpacing: 0.5),
          ),
          Text(
            seat,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ],
  );

  //  The Real Barcode Widget
  Widget _realBarcodeWidget(String data) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BarcodeWidget(
        barcode: Barcode.code128(),
        data: data,
        drawText: false,
        color: const Color(0xFF1C1C28),
      ),
    );
  }

  // ─── Bottom Action Button & Download Logic ──────────────────────────────────

  Widget _downloadPassButton() => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(color: Color(0xFFEFF2F9)),
    child: SafeArea(
      top: false,
      child: CommonButton(
        width: Get.width,
        buttonText: 'Download & Save pass',
        onChanged: () {
          saveTicket();
        },
      ),
    ),
  );

  Future<void> saveTicket() async {
    try {
      // Show a quick loading toast so the user knows it's working
      Get.snackbar(
        "Saving Ticket...",
        "Please wait while we generate your pass.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      //  Capture the widget as a Uint8List (Image)
      final Uint8List? image = await screenshotController.capture(
        delay: const Duration(milliseconds: 200),
      );

      if (image != null) {
        //  Request permissions seamlessly using the gal package
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }

        //  Save the image directly to the gallery
        await Gal.putImageBytes(
          image,
          name: "Flight_Ticket_${DateTime.now().millisecondsSinceEpoch}",
        );

        // Success Message
        Get.snackbar(
          "Success!",
          "Ticket successfully saved to your phone's gallery.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      // Handle Permission Denied or other errors
      Get.snackbar(
        "Permission Required",
        "Could not save ticket. Please allow photo gallery access in your settings.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
