import 'package:flutter/material.dart';

import '../../../enums/disruption_type.dart';

class QuickInputBar extends StatelessWidget {
  final void Function(DisruptionType) onTap;
  const QuickInputBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: DisruptionType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _QuickInputChip(type: type, onTap: () => onTap(type)),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickInputChip extends StatelessWidget {
  final DisruptionType type;
  final VoidCallback onTap;
  const _QuickInputChip({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(type.icon, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                type.label,
                style: theme.textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
