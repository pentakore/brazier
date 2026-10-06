import 'package:flutter/material.dart';

import 'models/item.dart';
import 'widgets/item_card.dart';
import 'widgets/item_dialog.dart';
import 'widgets/summary_card.dart';

void main() {
  runApp(const BrazierApp());
}

class BrazierApp extends StatelessWidget {
  const BrazierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brazier - Item Cost Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  // Sample initial items to give the user immediate interactive data
  final List<Item> _items = [
    Item(
      id: '1',
      name: 'Smartphone',
      price: 800.0,
      category: ItemCategory.devices,
      goalDurationMonths: 24,
      usedDurationMonths: 26,
    ),
    Item(
      id: '2',
      name: 'Winter Jacket',
      price: 120.0,
      category: ItemCategory.clothes,
      goalDurationMonths: 6,
      usedDurationMonths: 4,
    ),
    Item(
      id: '3',
      name: 'Noise Cancelling Headphones',
      price: 240.0,
      category: ItemCategory.devices,
      goalDurationMonths: 12,
      usedDurationMonths: 12,
    ),
    Item(
      id: '4',
      name: 'Running Shoes',
      price: 100.0,
      category: ItemCategory.fitness,
      goalDurationMonths: 5,
      usedDurationMonths: 2,
    ),
  ];

  String _searchQuery = '';
  ItemCategory? _selectedCategoryFilter;
  bool _showOnlyGoalReached = false;

  List<Item> get _filteredItems {
    return _items.where((item) {
      final matchesQuery = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == null ||
          item.category == _selectedCategoryFilter;
      final matchesGoalFilter = !_showOnlyGoalReached || item.isGoalReached;

      return matchesQuery && matchesCategory && matchesGoalFilter;
    }).toList();
  }

  void _addItem(Item newItem) {
    setState(() {
      _items.add(newItem);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${newItem.name}"'),
        action: SnackBarAction(
          label: 'DISMISS',
          onPressed: () {},
        ),
      ),
    );
  }

  void _editItem(Item updatedItem) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated "${updatedItem.name}"')),
    );
  }

  void _deleteItem(String id) {
    final itemToDelete = _items.firstWhere((i) => i.id == id);
    setState(() {
      _items.removeWhere((i) => i.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${itemToDelete.name}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _items.add(itemToDelete);
            });
          },
        ),
      ),
    );
  }

  void _updateUsedDuration(String id, int newDuration) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index].usedDurationMonths = newDuration;
      }
    });
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) => ItemDialog(
        onSave: _addItem,
      ),
    );
  }

  void _openEditDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) => ItemDialog(
        item: item,
        onSave: _editItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Text(
              'Brazier Cost Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Item',
            onPressed: _openAddDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stats Summary
            SummaryCard(items: _items),

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
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Categories'),
                          selected: _selectedCategoryFilter == null && !_showOnlyGoalReached,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoryFilter = null;
                                _showOnlyGoalReached = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          avatar: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Goal Reached'),
                          selected: _showOnlyGoalReached,
                          selectedColor: Colors.green.shade100,
                          onSelected: (selected) {
                            setState(() {
                              _showOnlyGoalReached = selected;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...ItemCategory.values.map((cat) {
                          final selected = _selectedCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              avatar: Icon(cat.icon, size: 16, color: selected ? null : cat.color),
                              label: Text(cat.displayName),
                              selected: selected,
                              onSelected: (isSelected) {
                                setState(() {
                                  _selectedCategoryFilter = isSelected ? cat : null;
                                });
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

            // Item List
            Expanded(
              child: filtered.isEmpty
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
                            _items.isEmpty
                                ? 'No items tracked yet.\nTap "+" to add your first item!'
                                : 'No items match your filters.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ItemCard(
                          item: item,
                          onEdit: () => _openEditDialog(item),
                          onDelete: () => _deleteItem(item.id),
                          onUpdateUsedDuration: (newDuration) =>
                              _updateUsedDuration(item.id, newDuration),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
