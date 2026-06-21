import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/category_entity.dart';

/// Category chip with emoji, pastel background, and selected state
class CategoryChipWidget extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChipWidget({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = Color(category.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? catColor
              : catColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? catColor
                : catColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: AppTypography.small(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
