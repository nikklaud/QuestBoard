import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quest_board/campaign_detail/cubit/campaign_detail_cubit.dart';
import 'package:quest_board/campaign_detail/data/model/hero.dart';
import 'package:quest_board/campaign_list/data/model/custom_month.dart';

class CreateQuestSheet extends StatefulWidget {
  const CreateQuestSheet({required this.heroes, required this.months});

  final List<CampaignHero> heroes;
  final List<CustomMonth> months;

  @override
  State<CreateQuestSheet> createState() => _CreateQuestSheetState();
}

class _CreateQuestSheetState extends State<CreateQuestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _startMonthIndex;
  int? _startDay;
  int? _endMonthIndex;
  int? _endDay;
  List<String> _selectedHeroIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int getMaxDays(int monthIndex) {
    if (monthIndex < 0 || monthIndex >= widget.months.length) return 31;
    return widget.months[monthIndex].daysCount;
  }

  int getAbsoluteDay(int monthIndex, int day) {
    if (monthIndex < 0 || monthIndex >= widget.months.length) return day;
    int totalDays = 0;
    for (int i = 0; i < monthIndex; i++) {
      totalDays += widget.months[i].daysCount;
    }
    return totalDays + day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              buildDateDropdowns(),
              const SizedBox(height: 16),
              HeroMultiSelect(
                heroes: widget.heroes,
                selectedIds: _selectedHeroIds,
                onChanged: (ids) {
                  setState(() {
                    _selectedHeroIds = ids;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Create')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateDropdowns() {
    return Column(
      children: [
        const Text('Start Date'),
        Row(
          children: [
            Expanded(
              child: DropdownMenu<int>(
                hintText: 'Month',
                initialSelection: _startMonthIndex,
                dropdownMenuEntries: widget.months.asMap().entries.map((e) {
                  return DropdownMenuEntry(value: e.key, label: e.value.name);
                }).toList(),
                onSelected: (v) => setState(() => _startMonthIndex = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownMenu<int>(
                hintText: 'Day',
                initialSelection: _startDay,
                dropdownMenuEntries:
                    List.generate(
                      _startMonthIndex != null
                          ? getMaxDays(_startMonthIndex!)
                          : 31,
                      (i) => i + 1,
                    ).map((d) {
                      return DropdownMenuEntry(value: d, label: '$d');
                    }).toList(),
                onSelected: (v) => setState(() => _startDay = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('End Date'),
        Row(
          children: [
            Expanded(
              child: DropdownMenu<int>(
                hintText: 'Month',
                initialSelection: _endMonthIndex,
                dropdownMenuEntries: widget.months.asMap().entries.map((e) {
                  return DropdownMenuEntry(value: e.key, label: e.value.name);
                }).toList(),
                onSelected: (v) => setState(() => _endMonthIndex = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownMenu<int>(
                hintText: 'Day',
                initialSelection: _endDay,
                dropdownMenuEntries:
                    List.generate(
                      _endMonthIndex != null ? getMaxDays(_endMonthIndex!) : 31,
                      (i) => i + 1,
                    ).map((d) {
                      return DropdownMenuEntry(value: d, label: '$d');
                    }).toList(),
                onSelected: (v) => setState(() => _endDay = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startMonthIndex == null ||
          _startDay == null ||
          _endMonthIndex == null ||
          _endDay == null) {
        return;
      }

      final startAbsolute = getAbsoluteDay(_startMonthIndex!, _startDay!);
      final endAbsolute = getAbsoluteDay(_endMonthIndex!, _endDay!);

      if (endAbsolute < startAbsolute) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must not be before start date'),
          ),
        );
        return;
      }

      try {
        context.read<CampaignDetailCubit>().createQuest(
          title: _titleController.text,
          description: _descriptionController.text,
          startMonthIndex: _startMonthIndex!,
          startDayNumber: _startDay!,
          endMonthIndex: _endMonthIndex!,
          endDayNumber: _endDay!,
          heroIds: _selectedHeroIds,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to create quest: $e')));
        }
      }
    }
  }
}

class HeroMultiSelect extends StatelessWidget {
  const HeroMultiSelect({
    required this.heroes,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<CampaignHero> heroes;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    if (heroes.isEmpty) {
      return const Text('No heroes available');
    }

    return Wrap(
      spacing: 8,
      children: heroes.map((hero) {
        final selected = selectedIds.contains(hero.id);
        return FilterChip(
          label: Text(hero.name),
          selected: selected,
          onSelected: (s) {
            final newIds = [...selectedIds];
            if (s) {
              newIds.add(hero.id);
            } else {
              newIds.remove(hero.id);
            }
            onChanged(newIds);
          },
        );
      }).toList(),
    );
  }
}
