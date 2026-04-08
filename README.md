# 消防设施操作员题库 App

一款用于消防设施操作员考试的练习应用，支持单选题和多项选择题练习、模拟考试、错题本和学习统计功能。

## 功能特点

- 📝 **练习模式** - 顺序刷题，做完即时显示答案解析
- ⏱️ **模拟考试** - 随机抽题、限时作答、自动评分
- ❌ **错题本** - 自动记录错题，支持重练
- 📊 **学习统计** - 正确率、答题数、学习进度可视化

## 题库内容

- 单选题：198 道
- 多选题：8 道
- 总计：206 道消防设施操作员考试题目

## 技术栈

- Flutter 3.x
- Provider (状态管理)
- SharedPreferences (本地存储)
- fl_chart (图表)

## 打包 APK

### 方法一：Codemagic 在线打包（推荐，无需安装环境）

1. 将项目推送到 GitHub
2. 访问 [codemagic.io](https://codemagic.io) 并关联 GitHub
3. 选择项目，点击 "Start new build"
4. 构建完成后下载 APK

### 方法二：本地打包

1. 安装 Flutter SDK
2. 运行 `flutter pub get`
3. 运行 `flutter build apk --release`
4. APK 文件位于 `build/app/outputs/flutter-apk/app-release.apk`

## 安装使用

1. 下载 APK 文件到手机
2. 允许安装未知来源应用
3. 安装后即可使用

## 截图预览

| 首页 | 练习 | 考试 |
|------|------|------|
| ![Home](screenshots/home.png) | ![Practice](screenshots/practice.png) | ![Exam](screenshots/exam.png) |

## License

MIT License
