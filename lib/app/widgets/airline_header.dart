import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class AirlineHeader extends StatelessWidget {
  final String logoPath;
  final String? airlineName;
  final bool isCentered;

  const AirlineHeader({
    super.key,
    required this.logoPath,
    this.airlineName,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Image.asset(
          logoPath,
          height: 30,
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.flight, color: Colors.blueAccent),
        ),

        if (airlineName != null && airlineName!.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            airlineName!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C28),
            ),
          ),
        ],
      ],
    );
  }
}
