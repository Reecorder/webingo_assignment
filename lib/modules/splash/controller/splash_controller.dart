import 'package:get/get.dart';
import 'package:booking_app/app/routes/app_routes.dart'; // Adjust path if needed

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Wait for 2.5 seconds to let the animation play out
    await Future.delayed(const Duration(milliseconds: 2500));

    // Use Get.offAllNamed to remove the splash screen from the navigation stack
    // so the user can't hit the "back" button and return to it.
    Get.offAllNamed(Routes.flightSearch);
  }
}
