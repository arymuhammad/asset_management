import 'package:flutter/material.dart';

class CsContainerColor extends StatelessWidget {
  const CsContainerColor({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
