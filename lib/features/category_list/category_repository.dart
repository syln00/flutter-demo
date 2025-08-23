import 'package:demo/core/api/api_service.dart';
import 'package:demo/shared/models/category_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CategoryRepository负责获取分类数据。
class CategoryRepository {
  final ApiService _apiService;

  CategoryRepository(this._apiService);

  Future<List<CategoryItem>> getCategories() async {
    final List<Map<String, dynamic>> rawData = await _apiService.getCategories();
    final List<CategoryItem> categoryItems = rawData
        .map((json) => CategoryItem.fromJson(json))
        .toList();
    return categoryItems;
  }
}

// --- Providers ---

/// 提供CategoryRepository实例的Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CategoryRepository(apiService);
});