import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';

/// Bottom sheet for picking or creating a category
class CategoryPickerSheetWidget extends StatefulWidget {
  final String? selectedCategoryId;
  final ValueChanged<CategoryEntity> onSelected;

  const CategoryPickerSheetWidget({
    super.key,
    this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  State<CategoryPickerSheetWidget> createState() =>
      _CategoryPickerSheetWidgetState();
}

class _CategoryPickerSheetWidgetState extends State<CategoryPickerSheetWidget> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  bool _showCreateForm = false;

  final List<Color> _colorOptions = const [
    Color(0xFFF5D5E0),
    Color(0xFFD4C5F9),
    Color(0xFFB8CCE3),
    Color(0xFFFFD4A8),
    Color(0xFFFFB3BA),
    Color(0xFFA8D8B9),
    Color(0xFFF9E4B7),
    Color(0xFFC9DCD2),
    Color(0xFFE8C5E8),
    Color(0xFFC5D8F0),
  ];

  Color _selectedColor = const Color(0xFFF5D5E0);

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _createCategory() {
    if (_nameController.text.trim().isEmpty) return;

    final category = CategoryEntity(
      id: IdGenerator.generate(),
      name: _nameController.text.trim(),
      emoji: _emojiController.text.trim().isEmpty
          ? '📌'
          : _emojiController.text.trim(),
      colorValue: _selectedColor.toARGB32(),
    );

    context.read<CategoryBloc>().add(AddCategoryEvent(category));
    widget.onSelected(category);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Pick a Category',
            style: AppTypography.h2(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),

          // Category grid
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              final categories =
                  state is CategoryLoaded ? state.categories : <CategoryEntity>[];

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...categories.map((cat) {
                    final isActive = cat.id == widget.selectedCategoryId;
                    return GestureDetector(
                      onTap: () {
                        widget.onSelected(cat);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Color(cat.colorValue)
                              : Color(cat.colorValue).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Color(cat.colorValue),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '${cat.emoji} ${cat.name}',
                          style: AppTypography.small(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }),
                  // Add new button
                  GestureDetector(
                    onTap: () => setState(() => _showCreateForm = !_showCreateForm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        '+ Add New',
                        style: AppTypography.small(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Create form
          if (_showCreateForm) ...[
            const SizedBox(height: 20),
            Text(
              'Create New Category',
              style: AppTypography.h3(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Emoji
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _emojiController,
                    decoration: const InputDecoration(
                      hintText: '😊',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Category name',
                    ),
                    style: AppTypography.body(
                        color: theme.colorScheme.onSurface),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Color picker
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final isActive = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _createCategory,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Category',
                  style: AppTypography.bodyBold(
                      color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
