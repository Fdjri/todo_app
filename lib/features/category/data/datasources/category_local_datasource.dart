import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/category_entity.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  static const String _categoriesKey = 'categories_data';
  static const String _initializedKey = 'categories_initialized';
  final SharedPreferences _prefs;

  CategoryLocalDataSource(this._prefs);

  Future<List<CategoryModel>> getAllCategories() async {
    // Seed defaults on first run
    if (!(_prefs.getBool(_initializedKey) ?? false)) {
      await _seedDefaults();
    }
    final jsonStr = _prefs.getString(_categoriesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    return CategoryModel.decodeList(jsonStr);
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _prefs.setString(_categoriesKey, CategoryModel.encodeList(categories));
  }

  Future<void> addCategory(CategoryModel category) async {
    final categories = await getAllCategories();
    categories.add(category);
    await saveCategories(categories);
  }

  Future<void> deleteCategory(String categoryId) async {
    final categories = await getAllCategories();
    categories.removeWhere((c) => c.id == categoryId);
    await saveCategories(categories);
  }

  Future<void> _seedDefaults() async {
    final defaults = CategoryEntity.defaults
        .map((e) => CategoryModel.fromEntity(e))
        .toList();
    await saveCategories(defaults);
    await _prefs.setBool(_initializedKey, true);
  }
}
