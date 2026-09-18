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
        color: colorScheme.surfaceContainer,
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
        if (onPrevious != null) ...[
          NavigatorButton(icon: Icons.chevron_left, onPressed: onPrevious),
          const SizedBox(width: 10),
        ],
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
    if (daysOfWeek.isEmpty) {
      return const Center(child: Text('Days of week not configured'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayCount = daysOfWeek.length;
        final gap = (8.0 - (dayCount - 7) * 0.5).clamp(3.0, 8.0).toDouble();
        final availableWidth = constraints.maxWidth - (dayCount - 1) * gap;
        final minCellSize = switch (dayCount) {
          <= 7 => 44.0,
          <= 10 => 36.0,
          <= 14 => 30.0,
          _ => 26.0,
        };
        final cellSize = (availableWidth / dayCount)
            .clamp(minCellSize, double.infinity)
            .toDouble();
        final childAspectRatio = switch (dayCount) {
          <= 3 => 1.35,
          <= 5 => 1.15,
          _ => 1.0,
        };
        final cellHeight = cellSize / childAspectRatio;
        final itemCount = monthOffset + month.daysCount;
        final rowCount = (itemCount / dayCount).ceil();
        final contentHeight = rowCount * cellHeight + (rowCount - 1) * gap;
        const maxViewportHeight = 560.0;
        final viewportHeight = contentHeight
            .clamp(0.0, maxViewportHeight)
            .toDouble();
        final gridWidth = dayCount * cellSize + (dayCount - 1) * gap;

        // `shrinkWrap: true` made the parent ListView lay out every day in a
        // month before it could paint anything. Keep a bounded viewport so the
        // GridView can lazily build only the visible cells (plus its cache).
        return SizedBox(
          height: viewportHeight + 34,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: gridWidth,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                    child: DaysOfWeekHeader(daysOfWeek: daysOfWeek),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: GridView.builder(
                      primary: false,
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: dayCount,
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index < monthOffset) {
                          return const SizedBox.shrink();
                        }

                        final day = index - monthOffset + 1;
                        final cellQuests =
                            questsByCell['$monthIndex-$day'] ?? const [];

                        return CalendarDayCell(
                          day: day,
                          quests: cellQuests,
                          cellSize: cellSize,
                          onTap: () => onCellTap(day),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
