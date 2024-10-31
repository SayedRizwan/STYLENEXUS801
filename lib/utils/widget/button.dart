import 'package:flutter/material.dart';

import '../app_colors.dart';


class button extends StatefulWidget {
  final double width;
  final String text;
  VoidCallback onPress;

  button({super.key, required this.width, required this.text, required this.onPress});

  @override
  State<button> createState() => _buttonState();
}

class _buttonState extends State<button> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        height: 40,
        child:ElevatedButton(
          onPressed: widget.onPress,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
          child: Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),),
        )
    );
  }
}
