import 'package:flutter/material.dart';

import '../models/item.dart';
import 'item_card.dart';

class ItemsView extends StatefulWidget {
  final List<Item> items;
  final List<Category> categories;
  final String searchQuery;
  final Category? selectedCategoryFilter;
  final bool showOnlyGoalReached;
  final bool showSegmentedProgressBar;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<Category?> onCategoryFilterChanged;
  final ValueChanged<bool> onGoalFilterChanged;
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
    this.showSegmentedProgressBar = true,
    required this.onSearchQueryChanged,
    required this.onCategoryFilterChanged,
    required this.onGoalFilterChanged,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onUpdateMonthlyStatus,
  });

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  bool _isCompactView = false;

  Widget _buildItemCard(Item item) {
    return _isCompactView
        ? CompactItemCard(
            item: item,
            showSegmentedProgressBar: widget.showSegmentedProgressBar,
            onEdit: () => widget.onEditItem(item),
            onDelete: () => widget.onDeleteItem(item.id),
            onUpdateMonthlyStatus: (newStatus) =>
                widget.onUpdateMonthlyStatus(item, newStatus),
          )
        : ItemCard(
            item: item,
            showSegmentedProgressBar: widget.showSegmentedProgressBar,
            onEdit: () => widget.onEditItem(item),
            onDelete: () => widget.onDeleteItem(item.id),
            onUpdateMonthlyStatus: (newStatus) =>
                widget.onUpdateMonthlyStatus(item, newStatus),
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 12),
        // Search & View Mode Toggle Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search items...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: widget.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => widget.onSearchQueryChanged(''),
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
                      onChanged: widget.onSearchQueryChanged,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Compact / Detailed View Toggle Button
                  IconButton.filledTonal(
                    tooltip: _isCompactView ? 'Switch to Detailed View' : 'Switch to Compact View',
                    icon: Icon(_isCompactView ? Icons.view_agenda_outlined : Icons.view_headline),
                    onPressed: () {
                      setState(() {
                        _isCompactView = !_isCompactView;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Categories'),
                      selected: widget.selectedCategoryFilter == null && !widget.showOnlyGoalReached,
                      onSelected: (selected) {
                        if (selected) {
                          widget.onCategoryFilterChanged(null);
                          widget.onGoalFilterChanged(false);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Goal Reached'),
                      selected: widget.showOnlyGoalReached,
                      onSelected: (selected) {
                        widget.onGoalFilterChanged(selected);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...widget.categories.map((cat) {
                      final selected = widget.selectedCategoryFilter?.id == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          avatar: Icon(cat.icon, size: 16, color: selected ? null : cat.color),
                          label: Text(cat.displayName),
                          selected: selected,
                          onSelected: (isSelected) {
                            widget.onCategoryFilterChanged(isSelected ? cat : null);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Items List or Responsive Multi-Column Grid
        Expanded(
          child: widget.items.isEmpty
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    // Calculate grid columns dynamically for wide screens (tablets, foldables, web, desktop)
                    int crossAxisCount = 1;
                    if (width >= 1350) {
                      crossAxisCount = 3;
                    } else if (width >= 900) {
                      crossAxisCount = 2;
                    }

                    if (crossAxisCount == 1) {
                      return ListView.builder(
                        itemCount: widget.items.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          return _buildItemCard(widget.items[index]);
                        },
                      );
                    } else {
                      return GridView.builder(
                        itemCount: widget.items.length,
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80, top: 4),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: _isCompactView ? 95 : 240,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          return _buildItemCard(widget.items[index]);
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}
