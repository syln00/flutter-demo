import 'package:freezed_annotation/freezed_annotation.dart';

// 这两行是 freezed 包的必需部分。
// 'category_item.freezed.dart' 将由 build_runner 自动生成，包含copyWith等方法。
part 'category_item.freezed.dart';
// 'category_item.g.dart' 将由 json_serializable 自动生成，包含fromJson/toJson方法。
part 'category_item.g.dart';

/// 分类项目的数据模型 (Data Transfer Object - DTO)
/// @freezed 注解会告诉代码生成器为这个类生成样板代码。
/// 这让我们能以非常简洁的方式定义一个功能强大的不可变数据类。
@freezed
class CategoryItem with _$CategoryItem {
  const factory CategoryItem({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
  }) = _CategoryItem;

  /// 这个工厂构造函数允许我们从JSON映射创建CategoryItem实例。
  /// json_serializable 包会自动实现它的逻辑。
  factory CategoryItem.fromJson(Map<String, dynamic> json) =>
      _$CategoryItemFromJson(json);
}
