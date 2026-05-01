# CodeFlash HarmonyOS App

<div align="center">

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-API%2012+-blue.svg)](https://www.harmonyos.com/)

**CodeFlash 鸿蒙端应用**

原生 ArkTS 实现 · 自动扫描 · 双向同步

[官网](https://codeflash.zestbox.cn/) · [主仓库](https://github.com/ZestBox-18/CodeFlash) · [问题反馈](https://github.com/ZestBox-18/CodeFlash/issues)

</div>

---

## 📖 简介

这是 CodeFlash 项目的 HarmonyOS 客户端应用，使用原生 ArkTS 开发，为鸿蒙设备提供剪贴板同步功能。

### ✨ 功能特性

| 特性 | 说明 |
|------|------|
| 🔍 **自动发现** | 一键扫描局域网内的电脑设备 |
| 📤 **推送到电脑** | 将手机剪贴板内容发送到电脑 |
| 📥 **从电脑获取** | 从电脑剪贴板获取内容到手机 |
| 📜 **历史记录** | 查看同步历史，快速重发 |
| ⚙️ **灵活配置** | 自定义服务器地址、端口等 |
| 🎨 **深色模式** | 支持跟随系统或手动切换 |

---

## 🛠️ 技术栈

- **开发语言**: ArkTS
- **UI 框架**: ArkUI 声明式开发范式
- **目标平台**: HarmonyOS
- **最低 API**: API 23
- **网络通信**: HTTP + UDP 广播
- **数据存储**: Preferences

---

## 🚀 快速开始

### 环境要求

- [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio) 6.1+
- HarmonyOS SDK API 23+

### 安装与运行

#### 1. 克隆仓库

```bash
# 克隆主仓库（包含子模块）
git clone --recursive https://github.com/ZestBox-18/CodeFlash.git

# 或单独克隆此仓库
git clone https://github.com/ZestBox-18/codeflash-harmony.git
```

#### 2. 打开项目

使用 DevEco Studio 打开项目目录：

```bash
# 如果克隆的是主仓库
# 打开 CodeFlash/codeflash-harmony 目录

# 如果单独克隆
# 打开 codeflash-harmony 目录
```

#### 3. 连接设备

- **真机**: 连接 HarmonyOS 手机，开启开发者模式和 USB 调试
- **模拟器**: 在 DevEco Studio 中启动 HarmonyOS 模拟器

#### 4. 运行应用

点击 DevEco Studio 工具栏的 **Run** 按钮（或按 `Shift + F10`）

---

## 📁 项目结构

```
codeflash-harmony/
├── AppScope/                      # 应用全局配置
│   ├── app.json5                 # 应用配置（名称、版本等）
│   └── resources/                # 全局资源（图标、字符串）
│       ├── base/
│       │   ├── element/
│       │   │   └── string.json   # 全局字符串
│       │   └── media/            # 应用图标
│       └── ...
│
├── entry/                         # 主模块（Entry 模块）
│   ├── src/
│   │   ├── main/                 # 主代码
│   │   │   ├── ets/
│   │   │   │   ├── constants/    # 常量定义
│   │   │   │   │   ├── CommonConstants.ets
│   │   │   │   │   └── RouterUrlConstants.ets
│   │   │   │   ├── database/     # 数据库配置
│   │   │   │   │   └── config.ets
│   │   │   │   ├── entryability/ # 应用入口
│   │   │   │   │   └── EntryAbility.ets
│   │   │   │   ├── model/        # 数据模型
│   │   │   │   │   ├── Device.ets
│   │   │   │   │   └── History.ets
│   │   │   │   ├── pages/        # 页面
│   │   │   │   │   └── Index.ets # 主页面
│   │   │   │   └── view/         # 视图组件
│   │   │   │       ├── DashboardView.ets    # 主面板
│   │   │   │       ├── HistoryView.ets      # 历史记录
│   │   │   │       ├── SettingsView.ets     # 设置页面
│   │   │   │       ├── FAQ.ets              # 常见问题
│   │   │   │       ├── UserGuide.ets        # 使用指南
│   │   │   │       └── Sponsorship.ets      # 赞助支持
│   │   │   ├── module.json5      # 模块配置
│   │   │   └── resources/        # 资源文件
│   │   │       ├── base/
│   │   │       │   ├── element/  # 字符串、颜色、数值
│   │   │       │   ├── media/    # 图片资源
│   │   │       │   └── profile/  # 配置文件
│   │   │       └── dark/         # 深色模式资源
│   │   ├── ohosTest/             # 测试代码
│   │   └── test/                 # 单元测试
│   ├── build-profile.json5       # 构建配置
│   ├── hvigorfile.ts             # 构建脚本
│   └── oh-package.json5          # 依赖配置
│
├── hvigor/                        # Hvigor 构建工具配置
│   └── hvigor-config.json5
│
├── build-profile.json5            # 项目构建配置
├── hvigorfile.ts                  # 项目构建脚本
├── oh-package.json5               # 项目依赖配置
└── oh-package-lock.json5          # 依赖锁定文件
```

---

## 📱 使用说明

### 首次使用

#### 1. 启动电脑端服务

确保电脑端服务已启动：

```bash
# macOS（使用 Homebrew）
brew services start codeflash

# 或手动运行
./codeflash-server
```

#### 2. 连接同一 WiFi

确保手机和电脑连接到同一局域网 WiFi。

#### 3. 自动扫描

1. 打开 CodeFlash App
2. 点击右上角的 **「自动扫描」** 按钮
3. 等待扫描完成，选择发现的电脑设备
4. 授权剪贴板访问权限（首次使用）

### 日常使用

#### 推送到电脑

1. 在手机上复制内容（文本、图片等）
2. 打开 CodeFlash App
3. 点击大大的蓝色 **「推送」** 按钮
4. 电脑端会收到通知，内容自动写入剪贴板

#### 从电脑获取

1. 在电脑上复制内容
2. 打开 CodeFlash App
3. 点击 **「从电脑获取」** 按钮
4. 内容自动写入手机剪贴板
5. 可以直接粘贴使用

### 历史记录

- 查看最近同步的内容
- 点击历史记录可快速重发
- 支持清空历史记录

---

## ⚙️ 配置说明

### 网络配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| HTTP 端口 | 56669 | 剪贴板数据传输 |
| UDP 端口 | 56670 | 设备发现广播 |

### 手动连接

如果自动扫描失败，可以手动输入：

1. 进入 **设置** 页面
2. 输入电脑的 IP 地址
3. 点击 **连接** 按钮

### 深色模式

- **跟随系统**：自动跟随系统设置
- **手动切换**：在设置页面手动开启/关闭

---

## 🔧 开发指南

### 代码规范

- 使用 ArkTS 严格模式
- 组件命名：PascalCase（如 `DashboardView`）
- 函数命名：camelCase（如 `handleScan`）
- 常量命名：UPPER_SNAKE_CASE（如 `MAX_RETRY_COUNT`）

### 资源管理

- 字符串：统一在 `resources/base/element/string.json` 中定义
- 颜色：在 `resources/base/element/color.json` 中定义
- 图片：放在 `resources/base/media/` 目录

### 调试技巧

```bash
# 查看日志
hdc shell hilog | grep CodeFlash

# 清除应用数据
hdc shell rm -rf /data/local/tmp/codeflash

# 重新安装
hdc install -r entry-default-signed.hap
```

---

## ❓ 常见问题

<details>
<summary><b>扫描不到电脑？</b></summary>

**检查清单：**
1. 确保手机和电脑在同一 WiFi 网络
2. 检查电脑防火墙是否开放端口 56669/56670
3. 确认电脑端服务已启动
4. 尝试手动输入电脑 IP 地址

**获取电脑 IP：**
- macOS: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- Windows: `ipconfig`

</details>

<details>
<summary><b>无法访问剪贴板？</b></summary>

**解决方案：**
1. 检查是否授权剪贴板权限
2. 进入系统设置 → 应用管理 → CodeFlash
3. 开启剪贴板读写权限
4. 重启应用

</details>

<details>
<summary><b>连接超时？</b></summary>

**可能原因：**
1. 网络不稳定
2. 电脑端服务未响应
3. IP 地址错误

**解决方案：**
1. 切换到更稳定的 WiFi
2. 重启电脑端服务
3. 重新扫描或手动输入 IP

</details>

<details>
<summary><b>推送/获取失败？</b></summary>

**排查步骤：**
1. 检查网络连接状态
2. 查看电脑端是否收到请求
3. 检查内容大小是否超限
4. 查看应用日志排查错误

</details>

---

## 🔗 相关链接

- **官网**: [https://codeflash.zestbox.cn/](https://codeflash.zestbox.cn/)
- **主仓库**: [CodeFlash](https://github.com/ZestBox-18/CodeFlash)
- **电脑端服务**: [server](https://github.com/ZestBox-18/CodeFlash/tree/main/server)
- **Homebrew Tap**: [homebrew-codeflash](https://github.com/ZestBox-18/homebrew-codeflash)
- **问题反馈**: [GitHub Issues](https://github.com/ZestBox-18/CodeFlash/issues)

---

## 🤝 贡献

欢迎贡献代码！

### 开发流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 使用 DevEco Studio 开发和测试
4. 提交更改 (`git commit -m 'feat: add some AmazingFeature'`)
5. 推送到分支 (`git push origin feature/AmazingFeature`)
6. 提交 Pull Request

### 提交规范

遵循 [约定式提交](https://www.conventionalcommits.org/zh-hans/)：

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `refactor`: 重构
- `chore`: 构建/工具变动

---

## 📄 许可证

本项目基于 [MIT License](https://github.com/ZestBox-18/CodeFlash/blob/main/LICENSE) 开源。

---

## 🙏 致谢

感谢以下技术和项目：

- [HarmonyOS](https://www.harmonyos.com/) - 华为鸿蒙操作系统
- [ArkUI](https://developer.harmonyos.com/cn/develop/arkui) - 声明式 UI 框架
- [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio) - 一站式开发工具

---

<div align="center">

如果这个项目对你有帮助，请给一个 ⭐ Star 支持一下！

**[官网](https://codeflash.zestbox.cn/)** · **[GitHub](https://github.com/ZestBox-18/codeflash-harmony)** · **[问题反馈](https://github.com/ZestBox-18/CodeFlash/issues)**

</div>
