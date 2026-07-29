import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/campaign_list/data/model/campaign.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onInvite;
  final Function(String playerId)? onRemovePlayer;
  final Map<String, String>? playerNicknames;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.isOwner,
    this.onEdit,
    this.onInvite,
    this.onRemovePlayer,
    this.playerNicknames,
  });

  void _showPlayersDialog(BuildContext context) {
    final theme = Theme.of(context);
    final ownerNickname = playerNicknames?[campaign.ownerId] ?? 'Owner';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Players'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.star, color: theme.colorScheme.primary),
                title: Text(ownerNickname),
                trailing: Text(
                  'Owner',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              ...campaign.playerIds.map((playerId) {
                final nickname = playerNicknames?[playerId] ?? 'Unknown';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(nickname),
                  trailing: isOwner
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            onRemovePlayer?.call(playerId);
                            Navigator.pop(context);
                          },
                          tooltip: 'Remove player',
                        )
                      : null,
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainer,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/campaign/${campaign.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.campaignName.isEmpty
                                ? 'Unnamed Campaign'
                                : campaign.campaignName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            campaign.worldName.isEmpty
                                ? 'Unknown World'
                                : campaign.worldName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Owner',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showPlayersDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${campaign.playerIds.length + 1} players',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (isOwner)
                      Row(
                        children: [
                          SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: onInvite,
                              icon: const Icon(
                                Icons.person_add_outlined,
                                size: 18,
                              ),
                              label: const Text('Invite'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: FilledButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
