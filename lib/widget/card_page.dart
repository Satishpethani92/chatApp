import 'package:flutter/material.dart';

class CardPage extends StatelessWidget {
  const CardPage({Key? key, required this.wgt}) : super(key: key);
  final Widget wgt;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.cyanAccent,
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: wgt,
      ),
    );
  }
}
