import "package:booking_app/modules/flight/controllers/flight_controller.dart";
import "package:get/get.dart";

class FlightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlightController>(() => FlightController());
  }
}
