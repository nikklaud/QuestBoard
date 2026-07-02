import 'package:flutter/material.dart';
import 'package:quest_board/campaign_list/data/model/day_of_week.dart';

class WeekdayCard extends StatelessWidget {
  final DayOfWeek day;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WeekdayCard({
    super.key,
    required this.day,
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
            child: Text(
              day.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
