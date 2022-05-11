import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({Key? key, required this.data}) : super(key: key);
  final String data;
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: const TextStyle(fontSize: 15, fontFamily: 'Comfort'),
    );
  }
}
