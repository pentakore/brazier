import 'package:flutter/material.dart';

class Category {
  final String id;
  String displayName;
  IconData icon;
  Color color;

  Category({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  static List<Category> get defaultCategories => [
    Category(id: 'clothes', displayName: 'Clothes', icon: Icons.checkroom, color: Colors.purple),
    Category(id: 'devices', displayName: 'Devices', icon: Icons.devices, color: Colors.blue),
    Category(id: 'home', displayName: 'Home', icon: Icons.home, color: Colors.orange),
    Category(id: 'books', displayName: 'Books', icon: Icons.menu_book, color: Colors.amber),
    Category(id: 'vehicles', displayName: 'Vehicles', icon: Icons.directions_car, color: Colors.red),
    Category(id: 'entertainment', displayName: 'Entertainment', icon: Icons.sports_esports, color: Colors.green),
    Category(id: 'fitness', displayName: 'Fitness & Sports', icon: Icons.fitness_center, color: Colors.teal),
    Category(id: 'other', displayName: 'Other', icon: Icons.category, color: Colors.grey),
  ];

  Category copyWith({
    String? id,
    String? displayName,
    IconData? icon,
    Color? color,
  }) {
    return Category(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
  Category category;
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
    Category? category,
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
