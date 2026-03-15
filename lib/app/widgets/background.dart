import "package:flutter/material.dart";
import "package:get/get.dart";

class BackgroundGrad extends StatelessWidget {
  const BackgroundGrad({super.key, required this.child, this.gradColors});

  final Widget child;
  final List<Color>? gradColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              gradColors ??
              [
                Color(0xFF2F6FE4),
                Color(0xFF7EA4E5),
                Colors.white,
                Color.fromARGB(255, 235, 227, 227),
              ],
        ),
      ),
      child: child,
    );
  }
}
