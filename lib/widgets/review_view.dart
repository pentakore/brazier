import 'dart:math';
import 'package:flutter/material.dart';

import '../models/item.dart';

class ReviewView extends StatefulWidget {
  final List<Item> items;
  final Function(Item item, bool used) onReviewItem;
  final VoidCallback onResetAllReviews;

  const ReviewView({
    super.key,
    required this.items,
    required this.onReviewItem,
    required this.onResetAllReviews,
  });

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;

  List<Item> get _pendingItems {
    return widget.items
        .where((i) => i.currentMonthlyStatus == MonthlyReviewStatus.pending)
        .toList();
  }

  void _handleReview(Item item, bool used) {
    widget.onReviewItem(item, used);
    setState(() {
      _dragOffset = Offset.zero;
      if (_currentIndex >= _pendingItems.length - 1) {
        _currentIndex = max(0, _pendingItems.length - 2);
      }
    });
  }

  void _nextItem() {
    final pending = _pendingItems;
    if (pending.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % pending.length;
      _dragOffset = Offset.zero;
    });
  }

  void _previousItem() {
    final pending = _pendingItems;
    if (pending.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + pending.length) % pending.length;
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final pending = _pendingItems;

    if (pending.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.green.shade900.withValues(alpha: 0.3)
                      : Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_outlined,
                  size: 72,
                  color: isDarkMode ? Colors.green.shade300 : Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'All caught up for this month! 🎉',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have reviewed all your items for the current month (${Item.currentMonthKey}).\nYour review list will reset next month automatically.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: widget.onResetAllReviews,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Monthly Reviews (Testing)'),
              ),
            ],
          ),
        ),
      );
    }

    // Safety index check
    if (_currentIndex >= pending.length) {
      _currentIndex = 0;
    }

    final currentItem = pending[_currentIndex];

    // Calculate swipe progress (-1 to +1 horizontally)
    final horizontalDrag = _dragOffset.dx;
    final screenWidth = MediaQuery.of(context).size.width;

    final isSwipingRight = horizontalDrag > 40;
    final isSwipingLeft = horizontalDrag < -40;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Usage Review',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} of ${pending.length} left',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe RIGHT if used this month, LEFT if not used, UP/DOWN to skip.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Swipe Card Stack Area
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Next Card in background (if available)
                  if (pending.length > 1)
                    Transform.scale(
                      scale: 0.94,
                      child: Transform.translate(
                        offset: const Offset(0, 16),
                        child: Opacity(
                          opacity: 0.6,
                          child: _ReviewCardContent(
                            item: pending[(_currentIndex + 1) % pending.length],
                          ),
                        ),
                      ),
                    ),

                  // Top Interactive Swipable Card
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta;
                      });
                    },
                    onPanEnd: (_) {
                      final dx = _dragOffset.dx;
                      final dy = _dragOffset.dy;

                      if (dx > screenWidth * 0.25) {
                        // Swiped Right -> Used!
                        _handleReview(currentItem, true);
                      } else if (dx < -screenWidth * 0.25) {
                        // Swiped Left -> Not Used!
                        _handleReview(currentItem, false);
                      } else if (dy < -80) {
                        // Swiped Up -> Next item
                        _nextItem();
                      } else if (dy > 80) {
                        // Swiped Down -> Previous item
                        _previousItem();
                      } else {
                        // Reset card position
                        setState(() {
                          _dragOffset = Offset.zero;
                        });
                      }
                    },
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Transform.rotate(
                        angle: (_dragOffset.dx / screenWidth) * (pi / 8),
                        child: Stack(
                          children: [
                            _ReviewCardContent(item: currentItem),

                            // "USED" Stamp Overlay when dragging right
                            if (isSwipingRight)
                              Positioned(
                                top: 40,
                                left: 30,
                                child: Transform.rotate(
                                  angle: -pi / 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.green, width: 4),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.green.withValues(alpha: 0.2),
                                    ),
                                    child: const Text(
                                      'USED (+1 mo)',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // "NOT USED" Stamp Overlay when dragging left
                            if (isSwipingLeft)
                              Positioned(
                                top: 40,
                                right: 30,
                                child: Transform.rotate(
                                  angle: pi / 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red, width: 4),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.red.withValues(alpha: 0.2),
                                    ),
                                    child: const Text(
                                      'NOT USED',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // NOT USED Button (Left gesture equivalent)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.red.shade900.withValues(alpha: 0.4)
                      : Colors.red.shade50,
                  foregroundColor: isDarkMode ? Colors.red.shade200 : Colors.red.shade700,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: isDarkMode ? Colors.red.shade400 : Colors.red.shade200,
                    ),
                  ),
                ),
                onPressed: () => _handleReview(currentItem, false),
                icon: const Icon(Icons.close, size: 24),
                label: const Text(
                  'Not Used',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Up/Down Navigation / Skip Buttons
              IconButton.filledTonal(
                tooltip: 'Previous Item (Swipe Down)',
                icon: const Icon(Icons.arrow_upward),
                onPressed: _previousItem,
              ),
              IconButton.filledTonal(
                tooltip: 'Next Item (Swipe Up)',
                icon: const Icon(Icons.arrow_downward),
                onPressed: _nextItem,
              ),

              // USED Button (Right gesture equivalent)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.green.shade700 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _handleReview(currentItem, true),
                icon: const Icon(Icons.check, size: 24),
                label: const Text(
                  'Used',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ReviewCardContent extends StatelessWidget {
  final Item item;

  const _ReviewCardContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Predict new cost if used
    final nextUsedDuration = item.usedDurationMonths + 1;
    final currentCostPerMo = item.usedDurationMonths > 0
        ? '${item.usedPricePerMonth.toStringAsFixed(2)} €/mo'
        : 'N/A';
    final newCostPerMo = '${(item.price / nextUsedDuration).toStringAsFixed(2)} €/mo';

    return SizedBox(
      width: double.infinity,
      height: 380,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Category Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.category.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.category.icon,
                          size: 18,
                          color: item.category.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.category.displayName,
                          style: TextStyle(
                            color: item.category.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.price.toStringAsFixed(2)} €',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Item Name & Prompt
              Column(
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Did you use this item during ${Item.currentMonthKey}?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              // Cost Impact Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Goal duration:', style: theme.textTheme.bodyMedium),
                        Text(
                          '${item.goalDurationMonths} mo (${item.goalPricePerMonth.toStringAsFixed(2)} €/mo)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current used duration:', style: theme.textTheme.bodyMedium),
                        Text(
                          '${item.usedDurationMonths} mo ($currentCostPerMo)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_down,
                              size: 18,
                              color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text('If used (+1 mo):', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          '$nextUsedDuration mo → $newCostPerMo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
