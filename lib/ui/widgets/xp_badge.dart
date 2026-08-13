import 'package:flutter/material.dart';

class XpBadge extends StatelessWidget {
  final int xp;
  final int streak;

  const XpBadge({
    Key? key,
    required this.xp,
    required this.streak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            '$xp XP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 8),
          Text(
            '$streak Days',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
