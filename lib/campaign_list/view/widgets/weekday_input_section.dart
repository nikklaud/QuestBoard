import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quest_board/campaign_list/cubit/create_campaign_cubit.dart';
import 'package:quest_board/campaign_list/view/widgets/weekday_card.dart';

class WeekdayInputSection extends StatefulWidget {
  const WeekdayInputSection({super.key});

  @override
  State<WeekdayInputSection> createState() => _WeekdayInputSectionState();
}

class _WeekdayInputSectionState extends State<WeekdayInputSection> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOrUpdateDay() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _controller.text.trim();
      if (_editingIndex != null) {
        context.read<CreateCampaignCubit>().updateDay(_editingIndex!, name);
      } else {
        context.read<CreateCampaignCubit>().addDay(name);
      }
      _clearInputs();
    }
  }

  void _clearInputs() {
    _controller.clear();
    _editingIndex = null;
    setState(() {});
  }

  void _editDay(int index) {
    final day = context.read<CreateCampaignCubit>().state.daysOfWeek[index];
    _controller.text = day.name;
    _editingIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days of Week',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Day name',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addOrUpdateDay,
                icon: Icon(_editingIndex != null ? Icons.check : Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CreateCampaignCubit, CreateCampaignState>(
          builder: (context, state) {
            if (state.daysOfWeek.isEmpty) {
              return Text(
                'No days added yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.daysOfWeek.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final day = state.daysOfWeek[index];
                return WeekdayCard(
                  day: day,
                  onEdit: () => _editDay(index),
                  onDelete: () =>
                      context.read<CreateCampaignCubit>().removeDay(index),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
