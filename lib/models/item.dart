import 'package:flutter/material.dart';

enum ItemCategory {
  clothes('Clothes', Icons.checkroom, Colors.purple),
  devices('Devices', Icons.devices, Colors.blue),
  home('Home', Icons.home, Colors.orange),
  books('Books', Icons.menu_book, Colors.amber),
  vehicles('Vehicles', Icons.directions_car, Colors.red),
  entertainment('Entertainment', Icons.sports_esports, Colors.green),
  fitness('Fitness & Sports', Icons.fitness_center, Colors.teal),
  other('Other', Icons.category, Colors.grey);

  final String displayName;
  final IconData icon;
  final Color color;

  const ItemCategory(this.displayName, this.icon, this.color);

  static ItemCategory fromName(String name) {
    return ItemCategory.values.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase() || cat.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => ItemCategory.other,
    );
  }
}

enum MonthlyReviewStatus {
  pending,
  used,
  notUsed,
}

class Item {
  final String id;
  String name;
  double price;
  ItemCategory category;
  int goalDurationMonths;
  int usedDurationMonths;
  String? lastReviewedMonthKey;
  bool? currentMonthUsed;
  bool isDefaultUsed;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.goalDurationMonths,
    required this.usedDurationMonths,
    this.lastReviewedMonthKey,
    this.currentMonthUsed,
    this.isDefaultUsed = false,
  });

  /// Calculates current year-month key string, e.g. "2025-05".
  static String get currentMonthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Automatically syncs monthly usage if [isDefaultUsed] is enabled.
  void checkAutoSyncDefaultUsed() {
    if (isDefaultUsed && lastReviewedMonthKey != currentMonthKey) {
      if (lastReviewedMonthKey != null) {
        // A new month has arrived for a default-used item -> increment usage
        usedDurationMonths += 1;
      }
      lastReviewedMonthKey = currentMonthKey;
      currentMonthUsed = true;
    }
  }

  /// Returns the current month's review status.
  MonthlyReviewStatus get currentMonthlyStatus {
    checkAutoSyncDefaultUsed();
    if (isDefaultUsed) {
      return MonthlyReviewStatus.used;
    }
    if (lastReviewedMonthKey != currentMonthKey) {
      return MonthlyReviewStatus.pending;
    }
    if (currentMonthUsed == true) {
      return MonthlyReviewStatus.used;
    } else if (currentMonthUsed == false) {
      return MonthlyReviewStatus.notUsed;
    }
    return MonthlyReviewStatus.pending;
  }

  /// Calculates the price per month based on goal duration.
  double get goalPricePerMonth {
    if (goalDurationMonths <= 0) return price;
    return price / goalDurationMonths;
  }

  /// Calculates the price per month based on actual used duration.
  double get usedPricePerMonth {
    if (usedDurationMonths <= 0) return price;
    return price / usedDurationMonths;
  }

  /// Returns true if the actual used duration has reached or exceeded the goal duration.
  bool get isGoalReached => usedDurationMonths >= goalDurationMonths;

  /// Progress ratio towards goal (0.0 to 1.0+).
  double get progressRatio {
    if (goalDurationMonths <= 0) return 1.0;
    return usedDurationMonths / goalDurationMonths;
  }

  Item copyWith({
    String? id,
    String? name,
    double? price,
    ItemCategory? category,
    int? goalDurationMonths,
    int? usedDurationMonths,
    String? lastReviewedMonthKey,
    bool? currentMonthUsed,
    bool? isDefaultUsed,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      goalDurationMonths: goalDurationMonths ?? this.goalDurationMonths,
      usedDurationMonths: usedDurationMonths ?? this.usedDurationMonths,
      lastReviewedMonthKey: lastReviewedMonthKey ?? this.lastReviewedMonthKey,
      currentMonthUsed: currentMonthUsed ?? this.currentMonthUsed,
      isDefaultUsed: isDefaultUsed ?? this.isDefaultUsed,
    );
  }
}
