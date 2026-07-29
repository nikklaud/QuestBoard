import 'package:flutter/material.dart';
import 'package:quest_board/campaign_detail/data/model/quest.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';
import 'package:quest_board/campaign_list/data/model/day_of_week.dart';
import 'package:quest_board/campaign_detail/view/widgets/calendar_day_cell.dart';

class CalendarSurface extends StatelessWidget {
  const CalendarSurface({
    required this.month,
    required this.daysOfWeek,
    required this.questsByCell,
    required this.monthOffset,
    required this.monthIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onCellTap,
  });

  final CustomMonth month;
  final List<DayOfWeek> daysOfWeek;
  final Map<String, List<Quest>> questsByCell;
  final int monthOffset;
  final int monthIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onCellTap;

  @override
  Widget build(BuildContext context) {
    final sortedDaysOfWeek = List<DayOfWeek>.from(daysOfWeek)
      ..sort((a, b) => a.order.compareTo(b.order));

    if (sortedDaysOfWeek.isEmpty) {
      return const CalendarCard(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Days of week not configured')),
        ),
      );
    }

    return CalendarCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MonthNavigator(
            months: [month],
            currentMonthIndex: 0,
            onPrevious: onPrevious,
            onNext: onNext,
          ),
          const SizedBox(height: 20),
          DaysOfWeekHeader(daysOfWeek: sortedDaysOfWeek),
          const SizedBox(height: 14),
          CalendarMonthGrid(
            month: month,
            daysOfWeek: sortedDaysOfWeek,
            monthOffset: monthOffset,
            monthIndex: monthIndex,
            questsByCell: questsByCell,
            onCellTap: onCellTap,
          ),
        ],
      ),
    );
  }
}

class CalendarCard extends StatelessWidget {
  const CalendarCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: child,
        ),
      ),
    );
  }
}

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    required this.months,
    required this.currentMonthIndex,
    required this.onPrevious,
    required this.onNext,
  });

  final List<CustomMonth> months;
  final int currentMonthIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NavigatorButton(icon: Icons.chevron_left, onPressed: onPrevious),
        const SizedBox(width: 10),
        Text(
          months[currentMonthIndex].name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 10),
        NavigatorButton(icon: Icons.chevron_right, onPressed: onNext),
      ],
    );
  }
}

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    required this.month,
    required this.daysOfWeek,
    required this.questsByCell,
    required this.monthOffset,
    required this.monthIndex,
    required this.onCellTap,
  });

  final CustomMonth month;
  final List<DayOfWeek> daysOfWeek;
  final Map<String, List<Quest>> questsByCell;
  final int monthOffset;
  final int monthIndex;
  final ValueChanged<int> onCellTap;

  @override
  Widget build(BuildContext context) {
    final sortedDaysOfWeek = List<DayOfWeek>.from(daysOfWeek)
      ..sort((a, b) => a.order.compareTo(b.order));

    if (sortedDaysOfWeek.isEmpty) {
      return const Center(child: Text('Days of week not configured'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayCount = sortedDaysOfWeek.length;
        final availableWidth = constraints.maxWidth - (dayCount - 1) * 8;
        final cellSize = (availableWidth / dayCount).clamp(32.0, 80.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: dayCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: monthOffset + month.daysCount,
          itemBuilder: (context, index) {
            if (index < monthOffset) {
              return const SizedBox.shrink();
            }

            final day = index - monthOffset + 1;
            final cellQuests = questsByCell['$monthIndex-$day'] ?? const [];

            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: cellSize,
                minHeight: cellSize,
              ),
              child: CalendarDayCell(
                day: day,
                quests: cellQuests,
                onTap: () => onCellTap(day),
              ),
            );
          },
        );
      },
    );
  }
}

class DaysOfWeekHeader extends StatelessWidget {
  const DaysOfWeekHeader({required this.daysOfWeek});

  final List<DayOfWeek> daysOfWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (final day in daysOfWeek)
          Expanded(
            child: Center(
              child: Text(
                weekdayShortLabel(day.name),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String weekdayShortLabel(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }

    return trimmed.toUpperCase();
  }
}

class NavigatorButton extends StatelessWidget {
  const NavigatorButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return InkResponse(
      onTap: onPressed,
      radius: 24,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
