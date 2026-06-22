import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../../core/constants/app_typography.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';

/// Horizontal category filter bar for the home page using shadcn
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
                child: activeCategoryId == 'all'
                    ? shadcn.Button(
                        style: const shadcn.ButtonStyle.primary(
                          size: shadcn.ButtonSize.small,
                        ),
                        onPressed: () => onCategorySelected('all'),
                        child: Text('All ✨',
                            style: AppTypography.small(
                                color: theme.colorScheme.onPrimary)),
                      )
                    : shadcn.Button(
                        style: const shadcn.ButtonStyle.outline(
                          size: shadcn.ButtonSize.small,
                        ),
                        onPressed: () => onCategorySelected('all'),
                        child: Text('All ✨',
                            style: AppTypography.small(
                                color: theme.colorScheme.onSurface)),
                      ),
              ),
              // Category chips
              ...categories.map((cat) {
                final isSelected = activeCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: isSelected
                      ? shadcn.Button(
                          style: const shadcn.ButtonStyle.primary(
                            size: shadcn.ButtonSize.small,
                          ),
                          onPressed: () => onCategorySelected(cat.id),
                          child: Text('${cat.emoji} ${cat.name}',
                              style: AppTypography.small(
                                  color: theme.colorScheme.onPrimary)),
                        )
                      : shadcn.Button(
                          style: const shadcn.ButtonStyle.outline(
                            size: shadcn.ButtonSize.small,
                          ),
                          onPressed: () => onCategorySelected(cat.id),
                          child: Text('${cat.emoji} ${cat.name}',
                              style: AppTypography.small(
                                  color: theme.colorScheme.onSurface)),
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
