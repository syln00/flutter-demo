import 'package:demo/features/category_list/category_repository.dart';
import 'package:demo/shared/models/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. 定义 Notifier ---
/// CategoryListNotifier 负责管理分类列表的异步状态。
/// 它继承自 [AutoDisposeAsyncNotifier]，这是 Riverpod 中处理可变异步状态的标准方式。
class CategoryListNotifier extends AutoDisposeAsyncNotifier<List<CategoryItem>> {
  /// `build` 方法是 Notifier 的初始化方法。
  /// 当 Provider 第一次被读取时，此方法会被调用来生成初始状态。
  /// 它的作用类似于之前 FutureProvider 的创建回调。
  @override
  Future<List<CategoryItem>> build() async {
    // 获取 repository 实例并加载初始数据
    final repository = ref.watch(categoryRepositoryProvider);
    return repository.getCategories();
  }

  /// --- 2. 添加刷新逻辑 ---
  /// `refresh` 是我们自定义的方法，用于触发数据的重新加载。
  Future<void> refresh() async {
    // 首先，将当前状态设置为加载中，这会让UI显示加载指示器
    state = const AsyncValue.loading();
    try {
      // 重新从 repository 获取数据
      final repository = ref.read(categoryRepositoryProvider);
      final items = await repository.getCategories();
      // 成功后，更新状态为新的数据
      state = AsyncValue.data(items);
    } catch (e, s) {
      // 如果发生错误，将状态更新为错误信息
      state = AsyncValue.error(e, s);
    }
  }
}

// --- 3. 定义 AsyncNotifierProvider ---
/// 我们用 [AsyncNotifierProvider] 替换了之前的 [FutureProvider]。
/// 它将 Notifier (`CategoryListNotifier`) 与其管理的状态 (`List<CategoryItem>`) 关联起来。
final categoryListProvider =
    AsyncNotifierProvider.autoDispose<CategoryListNotifier, List<CategoryItem>>(
  () => CategoryListNotifier(),
);


/// 分类列表页面 (UI层)
class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategoryList = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类列表 (下拉刷新)'),
      ),
      body: asyncCategoryList.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('没有找到任何项目。'));
          }
          // --- 4. 添加 RefreshIndicator ---
          /// [RefreshIndicator] 是 Flutter 内置的下拉刷新组件。
          return RefreshIndicator(
            // onRefresh 回调会在用户下拉并释放时触发
            onRefresh: () async {
              // 我们调用 Notifier 的 refresh 方法来重新加载数据。
              // 使用 ref.read 是因为我们只想触发动作，而不想在此处订阅状态变化。
              await ref.read(categoryListProvider.notifier).refresh();
            },
            child: ListView.builder(
              // physics: const AlwaysScrollableScrollPhysics() 确保即使列表内容不足一屏也能触发下拉。
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Image.network(
                    item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                );
              },
            ),
          );
        },
        error: (err, stack) => Center(child: Text('发生错误: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
