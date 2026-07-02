import 'package:flutter/material.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';

class MonthCard extends StatelessWidget {
  final CustomMonth month;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MonthCard({
    super.key,
    required this.month,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${month.daysCount} days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }
}
