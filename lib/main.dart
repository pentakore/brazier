import 'package:flutter/material.dart';

import 'models/item.dart';
import 'widgets/item_card.dart';
import 'widgets/item_dialog.dart';
import 'widgets/review_view.dart';
import 'widgets/statistics_view.dart';

void main() {
  runApp(const BrazierApp());
}

class BrazierApp extends StatefulWidget {
  const BrazierApp({super.key});

  @override
  State<BrazierApp> createState() => _BrazierAppState();
}

class _BrazierAppState extends State<BrazierApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seedColor = const Color(0xFF5C6BC0);

    return MaterialApp(
      title: 'Brazier - Item Cost Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: HomeScreen(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  // Initial sample items
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

  int get _pendingReviewCount {
    return _items.where((i) => i.currentMonthlyStatus == MonthlyReviewStatus.pending).length;
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

  void _handleReviewItem(Item item, bool used) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final current = _items[index];
        if (used) {
          current.usedDurationMonths += 1;
          current.currentMonthUsed = true;
        } else {
          current.currentMonthUsed = false;
        }
        current.lastReviewedMonthKey = Item.currentMonthKey;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          used
              ? 'Marked "${item.name}" as USED (+1 mo)!'
              : 'Marked "${item.name}" as NOT USED.',
        ),
      ),
    );
  }

  void _resetAllReviews() {
    setState(() {
      for (final item in _items) {
        item.lastReviewedMonthKey = null;
        item.currentMonthUsed = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset all monthly item reviews for testing.')),
    );
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

  String get _appBarTitle {
    switch (_currentTabIndex) {
      case 0:
        return 'Brazier Items';
      case 1:
        return 'Monthly Review';
      case 2:
        return 'Overview & Statistics';
      default:
        return 'Brazier';
    }
  }

  IconData get _themeIcon {
    switch (widget.themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredItems;
    final pendingCount = _pendingReviewCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Text(
              _appBarTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Switcher Menu
          PopupMenuButton<ThemeMode>(
            icon: Icon(_themeIcon),
            tooltip: 'Appearance Theme',
            onSelected: widget.onThemeModeChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(
                      Icons.brightness_auto,
                      color: widget.themeMode == ThemeMode.system
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'System Default',
                      style: TextStyle(
                        fontWeight: widget.themeMode == ThemeMode.system
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(
                      Icons.light_mode,
                      color: widget.themeMode == ThemeMode.light
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Light Theme',
                      style: TextStyle(
                        fontWeight: widget.themeMode == ThemeMode.light
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(
                      Icons.dark_mode,
                      color: widget.themeMode == ThemeMode.dark
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dark Theme',
                      style: TextStyle(
                        fontWeight: widget.themeMode == ThemeMode.dark
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Item',
            onPressed: _openAddDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            // TAB 0: Items List View
            Column(
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

                // Items List
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
                            );
                          },
                        ),
                ),
              ],
            ),

            // TAB 1: Monthly Review View
            ReviewView(
              items: _items,
              onReviewItem: _handleReviewItem,
              onResetAllReviews: _resetAllReviews,
            ),

            // TAB 2: Statistics View
            StatisticsView(items: _items),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Items',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.rate_review_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.rate_review),
            ),
            label: 'Review',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
