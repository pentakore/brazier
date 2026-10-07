import 'package:flutter/material.dart';

import '../models/item.dart';
import 'item_card.dart';

class ItemsView extends StatelessWidget {
  final List<Item> items;
  final List<Category> categories;
  final String searchQuery;
  final Category? selectedCategoryFilter;
  final bool showOnlyGoalReached;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<Category?> onCategoryFilterChanged;
  final ValueChanged<bool> onGoalFilterChanged;
  final VoidCallback onOpenCategoryManager;
  final ValueChanged<Item> onEditItem;
  final ValueChanged<String> onDeleteItem;
  final Function(Item item, MonthlyReviewStatus status) onUpdateMonthlyStatus;

  const ItemsView({
    super.key,
    required this.items,
    required this.categories,
    required this.searchQuery,
    required this.selectedCategoryFilter,
    required this.showOnlyGoalReached,
    required this.onSearchQueryChanged,
    required this.onCategoryFilterChanged,
    required this.onGoalFilterChanged,
    required this.onOpenCategoryManager,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onUpdateMonthlyStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 12),
        // Search & Category Filter Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => onSearchQueryChanged(''),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: onSearchQueryChanged,
              ),
              const SizedBox(height: 10),

              // Category Filter Chips & Category Manager Button
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Categories'),
                      selected: selectedCategoryFilter == null && !showOnlyGoalReached,
                      onSelected: (selected) {
                        if (selected) {
                          onCategoryFilterChanged(null);
                          onGoalFilterChanged(false);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Goal Reached'),
                      selected: showOnlyGoalReached,
                      onSelected: (selected) {
                        onGoalFilterChanged(selected);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((cat) {
                      final selected = selectedCategoryFilter?.id == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          avatar: Icon(cat.icon, size: 16, color: selected ? null : cat.color),
                          label: Text(cat.displayName),
                          selected: selected,
                          onSelected: (isSelected) {
                            onCategoryFilterChanged(isSelected ? cat : null);
                          },
                        ),
                      );
                    }),
                    // Manage Categories Action Chip
                    ActionChip(
                      avatar: const Icon(Icons.settings, size: 16),
                      label: const Text('Manage Categories'),
                      onPressed: onOpenCategoryManager,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Items List
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items match your filters.\nTap "+" to add a new item!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemCard(
                      item: item,
                      onEdit: () => onEditItem(item),
                      onDelete: () => onDeleteItem(item.id),
                      onUpdateMonthlyStatus: (newStatus) =>
                          onUpdateMonthlyStatus(item, newStatus),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
