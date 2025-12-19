import 'package:flutter/material.dart';

class YaziAlani extends StatelessWidget {
  final TextEditingController textEditingController;
  final EdgeInsets padding;
  final String hintText;
  final bool isVisible;

  const YaziAlani({
    required this.textEditingController,
    this.padding = const EdgeInsets.symmetric(horizontal: 15),
    this.hintText = '',
    this.isVisible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        obscureText: isVisible,
        controller: textEditingController,
        minLines: 1, // Minimum satır sayısını belirleyin

        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          hintStyle: const TextStyle(),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15), // Yüksekliği artırmak için padding
        ),
      ),
    );
  }
}
