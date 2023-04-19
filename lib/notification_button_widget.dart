import 'package:flutter/material.dart';

class NotificationButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const NotificationButtonWidget({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 50,
      elevation: 20,
      color: Colors.blue,
      onPressed: onPressed,
      child: Text(text,style: const TextStyle(color: Colors.white),),
    );
  }
}
