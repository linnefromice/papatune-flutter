import 'package:flutter/material.dart';

import '../../../enums/plan_mode.dart';

class PlanModeIndicator extends StatelessWidget {
  final PlanMode mode;
  const PlanModeIndicator({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: mode.color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: mode.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  mode.label.split(' ').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mode.color,
                    ),
                  ),
                  Text(
                    mode.description,
                    style: TextStyle(
                      color: mode.color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
