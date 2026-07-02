import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quest_board/campaign_list/cubit/create_campaign_cubit.dart';
import 'package:quest_board/campaign_list/view/widgets/month_card.dart';

class MonthInputSection extends StatefulWidget {
  const MonthInputSection({super.key});

  @override
  State<MonthInputSection> createState() => _MonthInputSectionState();
}

class _MonthInputSectionState extends State<MonthInputSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _daysController = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _addOrUpdateMonth() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final days = int.parse(_daysController.text.trim());

      if (_editingIndex != null) {
        context.read<CreateCampaignCubit>().updateMonth(
          _editingIndex!,
          name,
          days,
        );
      } else {
        context.read<CreateCampaignCubit>().addMonth(name, days);
      }

      _clearInputs();
    }
  }

  void _clearInputs() {
    _nameController.clear();
    _daysController.clear();
    _editingIndex = null;
    setState(() {});
  }

  void _editMonth(int index) {
    final month = context.read<CreateCampaignCubit>().state.months[index];
    _nameController.text = month.name;
    _daysController.text = month.daysCount.toString();
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
          'Months',
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
                flex: 2,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Month name',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(5),
                      ),
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
              Expanded(
                child: TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Days',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(15),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days < 1) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addOrUpdateMonth,
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
            if (state.months.isEmpty) {
              return Text(
                'No months added yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.months.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final month = state.months[index];
                return MonthCard(
                  month: month,
                  onEdit: () => _editMonth(index),
                  onDelete: () =>
                      context.read<CreateCampaignCubit>().removeMonth(index),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
