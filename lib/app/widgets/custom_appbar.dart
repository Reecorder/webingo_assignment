import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CommonAppBar extends StatelessWidget {
  final String title;
  final bool showMoreOption;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showMoreOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft300,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              // fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Optional 3-Dot Menu
          if (showMoreOption)
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  LucideIcons.ellipsisVertical300,
                  color: Colors.black87,
                  size: 20,
                ),
                onPressed: () {},
              ),
            )
          else
            const SizedBox(
              width: 45,
            ), // Keeps the title centered if no trailing icon
        ],
      ),
    );
  }
}
