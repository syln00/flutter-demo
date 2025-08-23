import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demo/features/category_list/category_list_page.dart';
import 'package:demo/features/notifications/notifications_page.dart';
import 'package:demo/features/profile/profile_page.dart';

/// 管理当前底部导航栏索引的 Provider
/// 使用 Riverpod 进行状态管理，即使是简单的UI状态，也能保持一致性和可扩展性。
/// 当其他地方需要知道当前选中的是哪个tab时，可以直接监听这个Provider。
final tabIndexProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  final List<Widget> _pages = const [
    CategoryListPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch 会订阅 Provider 的状态，当状态改变时，
    // 会自动重建当前 Widget，从而更新UI。
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      // IndexedStack 是一个特殊的 Stack，它一次只显示一个子 Widget。
      // 它的好处是当切换 tab 时，其他 tab 页面的状态会被完整保留下来，
      // 这对于需要保持滚动位置或表单输入的场景非常有用。
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // 当用户点击某个 tab 时，我们调用 read(provider.notifier).state 来修改状态。
          // 注意这里用 ref.read 而不是 ref.watch，因为我们不需要在 onTap 回调中订阅状态，
          // 只是单纯地触发一次状态变更。
          ref.read(tabIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: '列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: '通知',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
