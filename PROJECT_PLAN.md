# Flutter 教学演示项目规划

## 1. 项目简介

本项目旨在创建一个功能丰富的 Flutter 教学应用，用于演示在真实项目中常见的核心功能。项目将严格遵循 Flutter 社区推崇的最佳实践，注重代码的可读性、可维护性和可扩展性。

**核心原则**:
- **清晰架构**: 采用分层架构，分离 UI、业务逻辑和数据源。
- **代码规范**: 遵循官方推荐的编码风格，并使用 Lint 工具强制约束。
- **文档齐全**: 在关键代码和复杂逻辑处添加中文注释，解释“为什么”这么做。
- **组件化**: 尽可能将 UI 和逻辑拆分为可复用的组件。

---

## 2. 项目结构

我们将采用按功能（Feature-based）组织目录的结构，使项目在功能扩展时依然保持清晰。

```
flutter_demo/
├── lib/
│   ├── core/                     # 核心通用模块
│   │   ├── api/                  # API 客户端、拦截器等
│   │   ├── config/               # 全局配置，如主题、路由
│   │   ├── di/                   # 依赖注入配置
│   │   └── services/             # 通用服务，如通知、后台任务
│   │
│   ├── features/                 # 各个功能模块
│   │   ├── auth/                 # 认证模块 (登录、注册)
│   │   ├── home/                 # 主页 (Tab页)
│   │   ├── notifications/        # 消息通知模块
│   │   ├── profile/              # 个人中心 (包含图片上传)
│   │   └── category_list/        # 分类列表模块
│   │
│   ├── shared/                   # 多处共享的Widget、模型等
│   │   ├── models/               # 数据模型 (DTOs)
│   │   ├── widgets/              # 通用小组件
│   │   └── utils/                # 工具类
│   │
│   └── main.dart                 # 应用入口
│
├── assets/                       # 静态资源 (图片、字体、音频)
│   ├── images/
│   └── audio/
│
├── pubspec.yaml                  # 项目依赖配置文件
└── PROJECT_PLAN.md               # 本规划文档
```

---

## 3. 核心库选择

为了高效、高质量地完成开发，我们将依赖以下经过社区检验的优秀库。

| 功能领域 | 选择的库 | 用途和原因 | 文档地址 |
| :--- | :--- | :--- | :--- |
| **HTTP网络请求** | `dio` | 功能强大的HTTP客户端，支持拦截器、表单数据、取消请求等。比内置的`http`库更适合复杂项目。 | [https://pub.dev/packages/dio](https://pub.dev/packages/dio) |
| **状态管理** | `flutter_riverpod` | 现代、强大且可组合的状态管理库。通过 Provider 实现依赖注入和状态管理，代码结构清晰，易于测试。 | [https://pub.dev/packages/flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| **JSON序列化** | `freezed` / `json_serializable` | 自动生成数据类（Model）的样板代码，包括`fromJson`/`toJson`、`copyWith`等，确保数据类的不可变性，是现代Flutter开发的最佳实践。 | [https://pub.dev/packages/freezed](https://pub.dev/packages/freezed) |
| **依赖注入** | `get_it` / `injectable` | `get_it`是一个服务定位器，`injectable`配合它能自动注册依赖，实现优雅的依赖注入，尤其适合管理非UI逻辑的服务。 | [https://pub.dev/packages/get_it](https://pub.dev/packages/get_it) |
| **推送通知** | `firebase_messaging` | 集成 Firebase Cloud Messaging (FCM)，实现跨平台的推送通知功能，是行业标准方案。 | [https://pub.dev/packages/firebase_messaging](https://pub.dev/packages/firebase_messaging) |
| **图片选择** | `image_picker` | 官方维护的库，用于从相机或图库中选择图片，简单可靠。 | [https://pub.dev/packages/image_picker](https://pub.dev/packages/image_picker) |
| **后台任务/保活** | `flutter_background_service` | 在 Android 上创建前台服务以实现应用保活和后台任务，并为 iOS 提供有限的后台执行能力。 | [https://pub.dev/packages/flutter_background_service](https://pub.dev/packages/flutter_background_service) |
| **音频播放/播报** | `just_audio` | 功能强大的音频播放库，支持背景播放、播放列表、音效等，非常适合实现语音播报功能。 | [https://pub.dev/packages/just_audio](https://pub.dev/packages/just_audio) |
| **本地通知** | `flutter_local_notifications` | 用于在应用内触发本地通知，常与推送通知或后台任务配合使用，例如下载完成或后台任务提醒。 | [https://pub.dev/packages/flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |

---

## 4. 编码实践和规范

- **状态管理**: 全局使用 `Riverpod`。UI层通过 `ConsumerWidget` 监听 `Provider` 的状态变化并重建，业务逻辑封装在 `Notifier` 或 `Provider` 中。
- **数据层**: 创建一个 `Repository` 层，负责对接 `API` 和本地数据源。UI层只与 `Repository` 交互，不直接调用 `dio`。
- **数据模型**: 使用 `freezed` 创建不可变（Immutable）的数据模型，防止状态被意外修改，提升应用的稳定性。
- **错误处理**: 在 `Repository` 和 `API` 层进行统一的错误捕获和处理，向业务逻辑层返回定义好的结果（如 `Result` 类）。
- **注释**: 关键函数、复杂算法、以及 `Provider` 的定义必须有文档注释（`///`）。

---

## 5. 功能实现概要

- **Tab页**: 使用 `Scaffold` 和 `BottomNavigationBar` 实现，每个 Tab 对应一个独立的 Feature 模块。
- **后端接口请求**: `dio` 实例通过 `get_it` 注入到 `Repository` 中。使用拦截器统一处理日志打印、Token添加等。
- **分类列表**: 使用 `ListView.builder` 或 `GridView.builder` 构建，支持下拉刷新和上拉加载更多。
- **上传图片**: 使用 `image_picker` 获取图片文件，然后通过 `dio` 的 `FormData` 将其上传到服务器。
- **消息通知**:
  - **推送通知**: 集成 `firebase_messaging`，在 `main.dart` 或专门的 `NotificationService` 中处理后台和前台消息。
  - **本地通知**: 使用 `flutter_local_notifications` 在需要时（如后台任务完成）显示通知。
- **后台保活与语音播报**:
  - 使用 `flutter_background_service` 启动一个后台服务。
  - 在服务中监听事件（如来自推送的指令）。
  - 收到指令后，使用 `just_audio` 播放预设的提示音或语音文件，实现后台播报。

---

## 6. 下一步

1.  使用 `flutter create` 初始化项目。
2.  在 `pubspec.yaml` 文件中添加上述所有核心库的依赖。
3.  根据规划创建项目目录结构。
4.  开始实现第一个功能：搭建 Tab 首页框架。

这份规划文档将作为我们后续开发的指导方针。
