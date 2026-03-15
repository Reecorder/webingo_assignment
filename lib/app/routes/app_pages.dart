import "package:booking_app/modules/flight/bindings/flight_binding.dart";
import "package:booking_app/modules/flight/presentations/flight_details_ui.dart";
import "package:booking_app/modules/flight/presentations/flight_list.dart";
import "package:booking_app/modules/flight/presentations/flight_search.dart";
import "package:booking_app/modules/splash/bindings/splash_bindig.dart";
import "package:booking_app/modules/splash/presentation/splash_screen.dart";
import "package:get/get.dart";
import "app_routes.dart";

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Routes.flightSearch,
      page: () => FlightSearchPage(),
      binding: FlightBinding(),
    ),
    GetPage(
      name: Routes.flightList,
      page: () => FlightResultPage(),
      binding: FlightBinding(),
    ),
    GetPage(
      name: Routes.flightDetails,
      page: () => FlightDetailsPage(),
      binding: FlightBinding(),
    ),
  ];
}
