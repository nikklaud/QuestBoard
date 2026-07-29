import 'package:flutter/material.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';

class QuestPreviewSection extends StatelessWidget {
  const QuestPreviewSection({required this.campaign, required this.quests});

  final Campaign campaign;
  final List<Quest> quests;

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'События месяца',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final quest in quests)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuestPreviewCard(quest: quest, campaign: campaign),
          ),
      ],
    );
  }
}

class QuestPreviewCard extends StatelessWidget {
  const QuestPreviewCard({required this.quest, required this.campaign});

  final Quest quest;
  final Campaign campaign;

  String monthName(int monthIndex) {
    if (monthIndex < 0 || monthIndex >= campaign.months.length) {
      return 'Deleted';
    }

    return campaign.months[monthIndex].name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                color: quest.displayColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7A7A7A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${monthName(quest.startMonthIndex)} ${quest.startDayNumber} - ${monthName(quest.endMonthIndex)} ${quest.endDayNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9A9A9A),
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
