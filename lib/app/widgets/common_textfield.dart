import "package:flutter/material.dart";

class CommonTextField extends StatelessWidget {
  final String label;
  final String hint;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const CommonTextField({
    super.key,
    required this.label,
    required this.hint,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      onChanged: onChanged,
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelStyle: TextStyle(color: Colors.black, fontSize: 18),
        hintStyle: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.normal),
        labelStyle: const TextStyle(fontSize: 20, color: Colors.black54),
        suffixIcon:
            suffixIcon != null
                ? InkWell(
                  onTap: () {
                    if (onTap != null) {
                      onTap!();
                    }
                  },
                  child: suffixIcon,
                )
                : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
