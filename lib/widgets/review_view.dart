import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/item.dart';

const Color fireOrange = Color(0xFFFF5226); // Single unified Fire Orange Accent

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

    const darkSlateBlue = Color(0xFF252D3C);

    if (pending.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: fireOrange.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  size: 64,
                  color: fireOrange,
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Monthly Usage Review',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fireOrange.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} of ${pending.length} left',
                  style: const TextStyle(
                    color: fireOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Swipe RIGHT if used, LEFT if not used, UP/DOWN to skip.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Swipe Card Stack Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  // 2nd Background Card (deepest, if 3+ pending items)
                  if (pending.length > 2)
                    Transform.scale(
                      scaleX: 0.90,
                      scaleY: 1.0,
                      child: Transform.translate(
                        offset: const Offset(0, 26),
                        child: _ReviewCardContent(
                          item: pending[(_currentIndex + 2) % pending.length],
                        ),
                      ),
                    ),

                  // 1st Background Card (middle, if 2+ pending items)
                  if (pending.length > 1)
                    Transform.scale(
                      scaleX: 0.95,
                      scaleY: 1.0,
                      child: Transform.translate(
                        offset: const Offset(0, 14),
                        child: _ReviewCardContent(
                          item: pending[(_currentIndex + 1) % pending.length],
                        ),
                      ),
                    ),

                  // Top Interactive Swipable Card
                  Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        final dx = pointerSignal.scrollDelta.dx;
                        final dy = pointerSignal.scrollDelta.dy;

                        if (dx > 30) {
                          _handleReview(currentItem, true);
                        } else if (dx < -30) {
                          _handleReview(currentItem, false);
                        } else if (dy > 30 || dy < -30) {
                          _nextItem();
                        }
                      }
                    },
                    child: GestureDetector(
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
                        } else if (dy < -80 || dy > 80) {
                          // Swiped Up/Down -> Next item
                          _nextItem();
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
                            fit: StackFit.expand,
                            children: [
                              _ReviewCardContent(item: currentItem),

                              // "USED" Stamp Overlay when dragging right (Single Fire Orange)
                              if (isSwipingRight)
                                Positioned(
                                  top: 30,
                                  left: 20,
                                  child: Transform.rotate(
                                    angle: -pi / 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: fireOrange, width: 3.5),
                                        borderRadius: BorderRadius.circular(12),
                                        color: fireOrange.withValues(alpha: 0.2),
                                      ),
                                      child: const Text(
                                        'USED (+1 mo)',
                                        style: TextStyle(
                                          color: fireOrange,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // "NOT USED" Stamp Overlay when dragging left (Dark Slate)
                              if (isSwipingLeft)
                                Positioned(
                                  top: 30,
                                  right: 20,
                                  child: Transform.rotate(
                                    angle: pi / 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFF64748B), width: 3.5),
                                        borderRadius: BorderRadius.circular(12),
                                        color: darkSlateBlue.withValues(alpha: 0.85),
                                      ),
                                      child: const Text(
                                        'NOT USED',
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          letterSpacing: 1.2,
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
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // NOT USED Button (Dark Slate Blue)
              Flexible(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkSlateBlue,
                    foregroundColor: const Color(0xFFE2E8F0),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF475569)),
                    ),
                  ),
                  onPressed: () => _handleReview(currentItem, false),
                  icon: const Icon(Icons.close, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Not Used',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Up/Down Navigation Buttons
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: 'Previous Item',
                icon: const Icon(Icons.arrow_upward, size: 20),
                onPressed: _previousItem,
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: 'Next Item (swipe up/down)',
                icon: const Icon(Icons.arrow_downward, size: 20),
                onPressed: _nextItem,
              ),
              const SizedBox(width: 4),

              // USED Button (Single Fire Orange)
              Flexible(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fireOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _handleReview(currentItem, true),
                  icon: const Icon(Icons.check, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Used (+1 mo)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Category Badge & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          Text(
                            '${item.price.toStringAsFixed(2)} €',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: fireOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Item Name & Prompt
                      Column(
                        mainAxisSize: MainAxisSize.min,
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
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

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
                                Flexible(
                                  child: Text(
                                    '${item.goalDurationMonths} mo (${item.goalPricePerMonth.toStringAsFixed(2)} €/mo)',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Current used:', style: theme.textTheme.bodyMedium),
                                Flexible(
                                  child: Text(
                                    '${item.usedDurationMonths} mo ($currentCostPerMo)',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.trending_down,
                                      size: 16,
                                      color: fireOrange,
                                    ),
                                    SizedBox(width: 4),
                                    Text('If used (+1 mo):', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Flexible(
                                  child: Text(
                                    '$nextUsedDuration mo → $newCostPerMo',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: fireOrange,
                                    ),
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
          },
        ),
      ),
    );
  }
}
