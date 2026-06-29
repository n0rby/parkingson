import 'package:flutter/material.dart';
import '../theme.dart';

class ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;

  const ActionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (accent != null) ...[
              Container(width: 4, height: 40, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: hpText)),
                Text(subtitle, style: const TextStyle(color: hpMuted, fontSize: 13)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: hpSubtle),
          ],
        ),
      ),
    );
  }
}
