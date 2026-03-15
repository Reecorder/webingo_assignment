import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  CommonButton({super.key, required this.buttonText, required this.onChanged, this.width});
  String buttonText;
  Function onChanged;
  double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),

        onPressed: () {
          onChanged();
        },

        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
