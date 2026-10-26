import 'package:flutter/material.dart';

import '../models/lab_marker.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final MarkerStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      MarkerStatus.normal => ('Normal', AppColors.sage, const Color(0xFFE4F3EC)),
      MarkerStatus.low => ('Low', AppColors.amber, const Color(0xFFF8EBD9)),
      MarkerStatus.high => ('High', AppColors.coral, const Color(0xFFF8E4E0)),
      MarkerStatus.unknown => ('Review', AppColors.muted, AppColors.mint),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 12,
            ),
      ),
    );
  }
}
