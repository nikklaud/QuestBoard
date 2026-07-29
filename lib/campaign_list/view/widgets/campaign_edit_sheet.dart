import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';
import 'package:quest_board/campaign_list/data/repo/abstract_campaign_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CampaignEditSheet extends StatefulWidget {
  const CampaignEditSheet({
    super.key,
    required this.campaign,
    required this.onSaved,
    required this.onDelete,
  });

  final Campaign campaign;
  final VoidCallback onSaved;
  final VoidCallback onDelete;

  @override
  State<CampaignEditSheet> createState() => _CampaignEditSheetState();
}

class _CampaignEditSheetState extends State<CampaignEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _campaignNameController;
  late TextEditingController _worldNameController;

  @override
  void initState() {
    super.initState();
    _campaignNameController = TextEditingController(
      text: widget.campaign.campaignName,
    );
    _worldNameController = TextEditingController(
      text: widget.campaign.worldName,
    );
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _worldNameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final campaignName = _campaignNameController.text.trim();
      final worldName = _worldNameController.text.trim();

      if (campaignName == widget.campaign.campaignName &&
          worldName == widget.campaign.worldName) {
        Navigator.pop(context);
        return;
      }

      try {
        GetIt.I<AbstractCampaignRepo>().updateCampaign(
          widget.campaign.copyWith(
            campaignName: campaignName,
            worldName: worldName,
            updatedAt: DateTime.now(),
          ),
        );
        GetIt.I<Talker>().debug(
          'Campaign updated: ${widget.campaign.campaignName}',
        );
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update campaign: $e')),
          );
        }
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text(
          'This will permanently delete the campaign and all its quests. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Campaign',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Only campaign name and world name can be changed. '
              'Changing months or days of week may affect existing quests.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _campaignNameController,
                    decoration: InputDecoration(
                      labelText: 'Campaign Name',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: const UnderlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter campaign name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _worldNameController,
                    decoration: InputDecoration(
                      labelText: 'World Name',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: const UnderlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter world name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete Campaign',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
