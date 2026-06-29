import 'package:flutter/material.dart';
import '../theme.dart';

class ListCard extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback? onTap;

  const ListCard({super.key, required this.children, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: hpCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hpTeal.withOpacity(0.14)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: children),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
