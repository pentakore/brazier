import 'package:flutter/material.dart';

import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onUpdateUsedDuration;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateUsedDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGoalReached = item.isGoalReached;

    // Distinct colors for normal vs goal-reached states
    final cardBgColor = isGoalReached
        ? Colors.green.shade50
        : theme.colorScheme.surface;

    final cardBorderColor = isGoalReached
        ? Colors.green.shade400
        : theme.colorScheme.outlineVariant;

    final primaryAccentColor = isGoalReached
        ? Colors.green.shade800
        : theme.colorScheme.primary;

    final progressRatio = (item.progressRatio).clamp(0.0, 1.0);

    return Card(
      elevation: isGoalReached ? 3 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cardBorderColor,
          width: isGoalReached ? 2.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category chip, Goal status badge, Actions menu
            Row(
              children: [
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.category.icon,
                        size: 16,
                        color: item.category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.category.displayName,
                        style: TextStyle(
                          color: item.category.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Goal Reached Badge
                if (isGoalReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Goal Reached',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Edit / Delete Popup Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item Name & Total Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isGoalReached ? Colors.green.shade900 : null,
                    ),
                  ),
                ),
                Text(
                  '${item.price.toStringAsFixed(2)} €',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryAccentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cost per Month Comparison Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGoalReached
                    ? Colors.white.withValues(alpha: 0.7)
                    : theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Goal Duration Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Goal (${item.goalDurationMonths} mo)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.goalPricePerMonth.toStringAsFixed(2)} € / mo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(width: 12),
                  // Used Duration Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 16,
                              color: isGoalReached ? Colors.green.shade700 : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Used (${item.usedDurationMonths} mo)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isGoalReached ? Colors.green.shade800 : Colors.grey.shade700,
                                fontWeight: isGoalReached ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.usedDurationMonths > 0
                              ? '${item.usedPricePerMonth.toStringAsFixed(2)} € / mo'
                              : 'N/A',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isGoalReached
                                ? Colors.green.shade800
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Usage Progress',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                    Text(
                      '${item.usedDurationMonths} / ${item.goalDurationMonths} months',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isGoalReached ? Colors.green.shade800 : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 8,
                    backgroundColor: isGoalReached
                        ? Colors.green.shade100
                        : theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isGoalReached ? Colors.green.shade600 : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick Duration Adjustment Controls (+1 mo / -1 mo)
            Row(
              children: [
                Text(
                  'Quick adjust used duration:',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
                const Spacer(),
                IconButton.outlined(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: item.usedDurationMonths > 0
                      ? () => onUpdateUsedDuration(item.usedDurationMonths - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Decrease 1 month',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${item.usedDurationMonths} mo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton.outlined(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: () => onUpdateUsedDuration(item.usedDurationMonths + 1),
                  icon: const Icon(Icons.add),
                  tooltip: 'Increase 1 month',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
