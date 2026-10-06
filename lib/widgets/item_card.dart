import 'package:flutter/material.dart';

import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<MonthlyReviewStatus> onUpdateMonthlyStatus;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateMonthlyStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isGoalReached = item.isGoalReached;
    final monthlyStatus = item.currentMonthlyStatus;

    // Colors for normal vs goal-reached states across Light and Dark themes
    final cardBgColor = isGoalReached
        ? (isDarkMode
            ? Colors.green.shade900.withValues(alpha: 0.3)
            : Colors.green.shade50)
        : theme.colorScheme.surface;

    final cardBorderColor = isGoalReached
        ? (isDarkMode ? Colors.green.shade400 : Colors.green.shade600)
        : theme.colorScheme.outlineVariant;

    final primaryAccentColor = isGoalReached
        ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade800)
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
            // Top Row: Category chip, Current Month Usage Status Dropdown, Goal status badge, Actions menu
            Row(
              children: [
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.category.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
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
                const SizedBox(width: 8),

                // Interactive Monthly Status Dropdown Chip
                PopupMenuButton<MonthlyReviewStatus>(
                  tooltip: 'Change current month usage state',
                  onSelected: onUpdateMonthlyStatus,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: MonthlyReviewStatus.used,
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.teal.shade600, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Currently Used (+1 mo)',
                            style: TextStyle(
                              fontWeight: monthlyStatus == MonthlyReviewStatus.used
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: MonthlyReviewStatus.notUsed,
                      child: Row(
                        children: [
                          Icon(Icons.close, color: Colors.orange.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Not Used',
                            style: TextStyle(
                              fontWeight: monthlyStatus == MonthlyReviewStatus.notUsed
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: MonthlyReviewStatus.pending,
                      child: Row(
                        children: [
                          const Icon(Icons.rate_review_outlined, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Needs Review',
                            style: TextStyle(
                              fontWeight: monthlyStatus == MonthlyReviewStatus.pending
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: monthlyStatus == MonthlyReviewStatus.used
                          ? (isDarkMode
                              ? Colors.teal.shade900.withValues(alpha: 0.5)
                              : Colors.teal.shade100)
                          : monthlyStatus == MonthlyReviewStatus.notUsed
                              ? (isDarkMode
                                  ? Colors.orange.shade900.withValues(alpha: 0.5)
                                  : Colors.orange.shade100)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: monthlyStatus == MonthlyReviewStatus.used
                            ? Colors.teal.shade400
                            : monthlyStatus == MonthlyReviewStatus.notUsed
                                ? (isDarkMode ? Colors.orange.shade400 : Colors.orange.shade300)
                                : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          monthlyStatus == MonthlyReviewStatus.used
                              ? Icons.check
                              : monthlyStatus == MonthlyReviewStatus.notUsed
                                  ? Icons.close
                                  : Icons.help_outline,
                          size: 13,
                          color: monthlyStatus == MonthlyReviewStatus.used
                              ? (isDarkMode ? Colors.teal.shade200 : Colors.teal.shade800)
                              : monthlyStatus == MonthlyReviewStatus.notUsed
                                  ? (isDarkMode ? Colors.orange.shade200 : Colors.orange.shade900)
                                  : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          monthlyStatus == MonthlyReviewStatus.used
                              ? 'Currently used'
                              : monthlyStatus == MonthlyReviewStatus.notUsed
                                  ? 'Not used'
                                  : 'Needs review',
                          style: TextStyle(
                            color: monthlyStatus == MonthlyReviewStatus.used
                                ? (isDarkMode ? Colors.teal.shade200 : Colors.teal.shade900)
                                : monthlyStatus == MonthlyReviewStatus.notUsed
                                    ? (isDarkMode ? Colors.orange.shade200 : Colors.orange.shade900)
                                    : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: monthlyStatus == MonthlyReviewStatus.used
                              ? (isDarkMode ? Colors.teal.shade200 : Colors.teal.shade800)
                              : monthlyStatus == MonthlyReviewStatus.notUsed
                                  ? (isDarkMode ? Colors.orange.shade200 : Colors.orange.shade900)
                                  : theme.colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Goal Reached Badge
                if (isGoalReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.green.shade700 : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Goal Reached',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
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
                      color: isGoalReached
                          ? (isDarkMode ? Colors.green.shade200 : Colors.green.shade900)
                          : null,
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
                    ? (isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.7))
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
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
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
                              color: isGoalReached
                                  ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade700)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Used (${item.usedDurationMonths} mo)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isGoalReached
                                    ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade800)
                                    : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
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
                                ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade800)
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${item.usedDurationMonths} / ${item.goalDurationMonths} months',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isGoalReached
                            ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade800)
                            : null,
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
                        ? (isDarkMode ? Colors.green.shade900.withValues(alpha: 0.5) : Colors.green.shade100)
                        : theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isGoalReached
                          ? (isDarkMode ? Colors.green.shade400 : Colors.green.shade600)
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
