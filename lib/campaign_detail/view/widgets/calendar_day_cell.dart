import 'package:flutter/material.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    required this.day,
    required this.quests,
    required this.onTap,
  });

  final int day;
  final List<Quest> quests;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasQuests = quests.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = hasQuests
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = hasQuests
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasQuests)
                Align(
                  alignment: Alignment.bottomRight,
                  child: QuestDots(quests: quests),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestDots extends StatelessWidget {
  const QuestDots({required this.quests});

  final List<Quest> quests;

  static const int maxDots = 7;

  @override
  Widget build(BuildContext context) {
    final visibleCount = quests.length <= maxDots ? quests.length : maxDots - 1;
    final showMore = quests.length > maxDots;

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        for (var i = 0; i < visibleCount; i++)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: quests[i].displayColor,
              shape: BoxShape.circle,
            ),
          ),
        if (showMore)
          SizedBox(
            width: 6,
            height: 6,
            child: Center(
              child: Text(
                '+${quests.length - (maxDots - 1)}',
                style: const TextStyle(fontSize: 6, height: 1),
              ),
            ),
          ),
      ],
    );
  }
}
