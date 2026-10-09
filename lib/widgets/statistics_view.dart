import 'dart:math';
import 'package:flutter/material.dart';

import '../models/item.dart';
import 'summary_card.dart';

class ItemsDetailScreen extends StatelessWidget {
  final String title;
  final List<Item> items;
  final Category? category;

  const ItemsDetailScreen({
    super.key,
    required this.title,
    required this.items,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Baseline scaling: max total price and max monthly cost across items in this subpage
    final maxPrice = items.fold(0.0, (maxVal, item) => item.price > maxVal ? item.price : maxVal);
    final maxMonthlyCost = items.fold(0.0, (maxVal, item) {
      final usedCost = item.usedDurationMonths > 0 ? item.usedPricePerMonth : item.goalPricePerMonth;
      final itemMax = max(item.goalPricePerMonth, usedCost);
      return itemMax > maxVal ? itemMax : maxVal;
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (category != null) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: category!.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                child: Icon(category!.icon, size: 16, color: category!.color),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No items found in this section.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final cat = item.category;

                // Total Price ratio (scaled to maxPrice)
                final priceRatio = maxPrice > 0 ? (item.price / maxPrice).clamp(0.05, 1.0) : 0.0;

                // Monthly Progress ratios (scaled relative to maxMonthlyCost)
                final usedPrice = item.usedDurationMonths > 0 ? item.usedPricePerMonth : item.goalPricePerMonth;
                final goalRatio = maxMonthlyCost > 0 ? (item.goalPricePerMonth / maxMonthlyCost).clamp(0.02, 1.0) : 0.0;
                final usedRatio = maxMonthlyCost > 0 ? (usedPrice / maxMonthlyCost).clamp(0.02, 1.0) : 0.0;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Category Icon + Item Name + Goal Badge
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: cat.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                            child: Icon(cat.icon, size: 16, color: cat.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (item.isGoalReached)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.green.shade900.withValues(alpha: 0.5) : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Goal Reached',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.green.shade300 : Colors.green.shade900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bar 1: Total Price Bar (scaled to maxPrice)
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              'Total Price:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: priceRatio,
                                minHeight: 8,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 80,
                            child: Text(
                              '${item.price.toStringAsFixed(2)} €',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Bar 2: Monthly Cost Bar with 8px Amber Goal Target Notch ALWAYS ON TOP
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              'Monthly Cost:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;
                                final goalLeft = (totalWidth * goalRatio).clamp(0.0, totalWidth);
                                final markerLeft = (goalLeft - 4).clamp(0.0, totalWidth - 8);

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Gray Background Track (100% width)
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),

                                    // 2. Current Used Monthly Cost Fill Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: usedRatio,
                                        minHeight: 8,
                                        backgroundColor: Colors.transparent,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          item.isGoalReached
                                              ? (isDarkMode ? Colors.green.shade400 : Colors.green.shade600)
                                              : theme.colorScheme.tertiary,
                                        ),
                                      ),
                                    ),

                                    // 3. Target Goal Indicator Segment (8px Notch ALWAYS ON TOP)
                                    Positioned(
                                      left: markerLeft,
                                      child: Tooltip(
                                        message: 'Target Goal (${item.goalDurationMonths} mo): ${item.goalPricePerMonth.toStringAsFixed(2)} €/mo',
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black38,
                                                blurRadius: 3,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 80,
                            child: Text(
                              item.usedDurationMonths > 0
                                  ? '${item.usedPricePerMonth.toStringAsFixed(2)} €/mo'
                                  : '${item.goalPricePerMonth.toStringAsFixed(2)} €/mo',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: item.isGoalReached
                                    ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade800)
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class WinstreaksDetailScreen extends StatelessWidget {
  final List<Item> items;

  const WinstreaksDetailScreen({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final sortedItems = List<Item>.from(items)
      ..sort((a, b) => b.usageStreak.compareTo(a.usageStreak));

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text(
              'Usage Winstreaks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: sortedItems.isEmpty
          ? Center(
              child: Text(
                'No items found.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          : Column(
              children: [
                // Column Headers Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Item',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Used / Goal',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Current Streak',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Items List
                Expanded(
                  child: ListView.separated(
                    itemCount: sortedItems.length,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      final cat = item.category;
                      final hasStreak = item.usageStreak > 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Column 0: Category Icon + Item Name
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: cat.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                                    child: Icon(cat.icon, size: 14, color: cat.color),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Column 1: Used Months / Goal Months
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${item.usedDurationMonths} / ${item.goalDurationMonths} mo',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: item.isGoalReached
                                      ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade800)
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Column 2: Winstreak Badge
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: hasStreak
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.deepOrange.shade900.withValues(alpha: 0.4)
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDarkMode ? Colors.deepOrange.shade400 : Colors.orange.shade400,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.local_fire_department,
                                              size: 13,
                                              color: isDarkMode ? Colors.orange.shade300 : Colors.deepOrange,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${item.usageStreak} mo',
                                              style: TextStyle(
                                                color: isDarkMode ? Colors.orange.shade200 : Colors.deepOrange.shade900,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        'No streak',
                                        style: TextStyle(
                                          color: theme.colorScheme.outline,
                                          fontSize: 11,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class StatisticsView extends StatelessWidget {
  final List<Item> items;

  const StatisticsView({
    super.key,
    required this.items,
  });

  void _navigateToDetailSubpage(
    BuildContext context,
    String title,
    List<Item> subpageItems, {
    Category? category,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ItemsDetailScreen(
          title: title,
          items: subpageItems,
          category: category,
        ),
      ),
    );
  }

  void _navigateToWinstreaksSubpage(BuildContext context, List<Item> allItems) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WinstreaksDetailScreen(items: allItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No statistics available yet.\nAdd items to see your cost analysis!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalSpent = items.fold(0.0, (sum, item) => sum + item.price);
    final reachedGoals = items.where((i) => i.isGoalReached).toList();
    final inProgress = items.where((i) => !i.isGoalReached).toList();
    final activeStreaksCount = items.where((i) => i.usageStreak > 0).length;

    // Group items by category
    final Map<Category, List<Item>> categoryMap = {};
    for (final item in items) {
      categoryMap.putIfAbsent(item.category, () => []).add(item);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Summary Card (Clickable to open subpage with all items)
          SummaryCard(
            items: items,
            onTap: () => _navigateToDetailSubpage(
              context,
              'Overview Summary',
              items,
            ),
          ),

          const SizedBox(height: 8),

          // Goal Achievement Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Goal Achievement Status',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatusStatBox(
                            title: 'Goals Reached',
                            count: reachedGoals.length,
                            color: isDarkMode ? Colors.green.shade300 : Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatusStatBox(
                            title: 'In Progress',
                            count: inProgress.length,
                            color: isDarkMode ? Colors.orange.shade300 : Colors.orange,
                            icon: Icons.timelapse,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Overall Completion: ${(reachedGoals.length / items.length * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: items.isNotEmpty ? reachedGoals.length / items.length : 0.0,
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? Colors.green.shade400 : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Usage Winstreaks Grid Section (Clickable to view winstreaks subpage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _navigateToWinstreaksSubpage(context, items),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Winstreaks Grid',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.deepOrange.shade900.withValues(alpha: 0.4)
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$activeStreaksCount/${items.length} Active 🔥',
                              style: TextStyle(
                                color: isDarkMode ? Colors.orange.shade200 : Colors.deepOrange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.outline,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid filled with points (Minimalist Disks & Fires)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: items.map((item) {
                          final hasStreak = item.usageStreak > 0;

                          if (hasStreak) {
                            // Fire Icon with Streak Number
                            return Tooltip(
                              message: '${item.name}: ${item.usageStreak} mo streak 🔥',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.deepOrange.shade900.withValues(alpha: 0.5)
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.deepOrange.shade400 : Colors.orange.shade400,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepOrange.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      size: 18,
                                      color: Colors.deepOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.usageStreak}',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.orange.shade200 : Colors.deepOrange.shade900,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // Simple Minimalist Disk / Dot
                            return Tooltip(
                              message: '${item.name}: No active streak',
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.outline,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Breakdown Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Cost Breakdown by Category (Tap to view items)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Category Cards (Clickable to open subpage with category items)
          ...categoryMap.entries.map((entry) {
            final category = entry.key;
            final catItems = entry.value;
            final categoryTotal = catItems.fold(0.0, (sum, i) => sum + i.price);
            final categoryGoalRate = catItems.fold(0.0, (sum, i) => sum + i.goalPricePerMonth);
            final categoryUsedRate = catItems.fold(0.0, (sum, i) => sum + i.usedPricePerMonth);
            final categoryPercentage = totalSpent > 0 ? (categoryTotal / totalSpent) : 0.0;
            final catColor = category.color;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToDetailSubpage(
                    context,
                    category.displayName,
                    catItems,
                    category: category,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: category.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                              child: Icon(category.icon, size: 18, color: catColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${categoryTotal.toStringAsFixed(2)} €',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.outline,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${catItems.length} ${catItems.length == 1 ? 'item' : 'items'} (${(categoryPercentage * 100).toStringAsFixed(0)}% of total)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Goal: ${categoryGoalRate.toStringAsFixed(2)} €/mo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: categoryPercentage.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(catColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Used Rate Equivalent:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${categoryUsedRate.toStringAsFixed(2)} € / mo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusStatBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusStatBox({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
