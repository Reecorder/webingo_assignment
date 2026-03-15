import 'package:booking_app/modules/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    Get.find<SplashController>();

    return Scaffold(
      body: _buildBackground(child: Center(child: _buildAnimatedContent())),
    );
  }

  // ─── Background ──────────────────────────────────────────────────────────────
  Widget _buildBackground({required Widget child}) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7EA4E5), Color(0xFF2F6FE4), Color(0xFF1A4BB8)],
      ),
    ),
    child: child,
  );

  // ─── Animated Content  ──────────────────────────────────────────────
  Widget _buildAnimatedContent() => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 1200),
    curve: Curves.easeOutBack,
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 24),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
            ],
          ),
        ),
      );
    },
  );

  // ───  UI Elements ────────────────────────────────────────────────
  Widget _buildLogo() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: const Icon(
      Icons.flight_takeoff_rounded,
      color: Color(0xFF2F6FE4),
      size: 60,
    ),
  );

  Widget _buildTitle() => const Text(
    "Webingo",
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.2,
    ),
  );

  Widget _buildSubtitle() => Text(
    "Find your next destination",
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.8),
      letterSpacing: 0.5,
    ),
  );
}
