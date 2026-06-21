import '../../domain/entities/category_entity.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> deleteCategory(String categoryId);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    return await localDataSource.getAllCategories();
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    await localDataSource.addCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await localDataSource.deleteCategory(categoryId);
  }
}
