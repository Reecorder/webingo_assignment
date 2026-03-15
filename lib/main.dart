import "package:booking_app/app/routes/app_pages.dart";
import "package:booking_app/app/theme/app_theme.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

void main() {
  runApp(const FlightBookingApp());
}

class FlightBookingApp extends StatelessWidget {
  const FlightBookingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flight Booking",
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
