import "package:flutter/material.dart";

class UniversalTicketCard extends StatelessWidget {
  final Widget topContent;
  final Widget bottomContent;
  final double cardWidth;
  final double cardHeight;
  final double dividerPosition;

  const UniversalTicketCard({
    super.key,
    required this.topContent,
    required this.bottomContent,
    this.cardWidth = double.infinity,
    this.cardHeight = 200,
    this.dividerPosition = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: TicketClipper(cutPosition: dividerPosition),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Half
                  SizedBox(
                    height: dividerPosition,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: topContent,
                    ),
                  ),
                  // Bottom Half
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: bottomContent,
                    ),
                  ),
                ],
              ),

              // Center Dotted Divider
              Positioned(
                top: dividerPosition - 1,
                left: 20,
                right: 20,
                child: const TicketDottedDivider(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double cutPosition;

  TicketClipper({required this.cutPosition});

  @override
  Path getClip(Size size) {
    const cutRadius = 15.0;

    Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cutPosition - cutRadius);

    // Right cut
    path.arcToPoint(
      Offset(size.width, cutPosition + cutRadius),
      radius: const Radius.circular(cutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, cutPosition + cutRadius);

    // Left cut
    path.arcToPoint(
      Offset(0, cutPosition - cutRadius),
      radius: const Radius.circular(cutRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TicketDottedDivider extends StatelessWidget {
  const TicketDottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int dots = (constraints.maxWidth / 12).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dots,
            (index) =>
                Container(width: 6, height: 2, color: Colors.grey.shade300),
          ),
        );
      },
    );
  }
}
