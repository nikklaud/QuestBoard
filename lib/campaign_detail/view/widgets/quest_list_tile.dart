import 'package:flutter/material.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';

class QuestListTile extends StatefulWidget {
  const QuestListTile({required this.quest, required this.campaign});

  final Quest quest;
  final Campaign campaign;

  @override
  State<QuestListTile> createState() => _QuestListTileState();
}

class _QuestListTileState extends State<QuestListTile> {
  bool _expanded = false;

  String _safeMonthName(int monthIndex) {
    if (monthIndex < 0 || monthIndex >= widget.campaign.months.length) {
      return 'Deleted';
    }
    return widget.campaign.months[monthIndex].name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 16,
            height: 16,
            color: widget.quest.displayColor,
          ),
          title: Text(widget.quest.title),
          subtitle: Text(
            '${_safeMonthName(widget.quest.startMonthIndex)} ${widget.quest.startDayNumber} - '
            '${_safeMonthName(widget.quest.endMonthIndex)} ${widget.quest.endDayNumber}',
          ),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
          ),
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.quest.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}
