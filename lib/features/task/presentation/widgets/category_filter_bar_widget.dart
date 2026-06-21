import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/widgets/category_chip_widget.dart';

/// Horizontal category filter bar for the home page
class CategoryFilterBarWidget extends StatelessWidget {
  final String activeCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterBarWidget({
    super.key,
    required this.activeCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories =
            state is CategoryLoaded ? state.categories : <CategoryEntity>[];

        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onCategorySelected('all'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: activeCategoryId == 'all'
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: activeCategoryId == 'all'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      'All ✨',
                      style: AppTypography.small(
                        color: activeCategoryId == 'all'
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              // Category chips
              ...categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChipWidget(
                    category: cat,
                    isSelected: activeCategoryId == cat.id,
                    onTap: () => onCategorySelected(cat.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
