# 介绍

**PakrPre** 是一个网页一键打包 APK 的工具。填写目标网址和应用信息后，3~5 分钟自动生成可安装的 Android APK，无需本地安装任何工具，全程云端完成编译、签名、打包。

## 工作原理

前后端合并部署在 **Cloudflare Pages**，无需单独部署 Worker：

```
浏览器
  │
  ▼
Cloudflare Pages（index.html + _worker.js）
  │  前端页面 + API 接口合二为一
  ▼
GitHub Actions ── 触发构建 / 查询进度 / 下载 APK
```

## 构建流程

```
提交表单
   │
   ▼
_worker.js ──→ 触发 GitHub Actions (workflow_dispatch)
   │
   ▼
GitHub Actions
   ├── 1. Inject parameters   注入 URL / 包名 / 版本号 / UA / 开关参数
   ├── 2. Process icon        处理文字图标、图片图标或默认 logo.jpg
   ├── 3. Build APK           Gradle 编译（arm64 + armeabi-v7a）
   └── 4. Sign & Upload       zipalign + apksigner 签名，上传 Artifact
   │
   ▼
前端轮询 /status 和 /logs，更新进度、步骤状态和详细日志
   │
   ▼
构建完成 → 显示多架构下载按钮，记录到历史面板
```

## 在线体验

- **当前演示站：** [pakrpre.precc.eu.cc](https://pakrpre.precc.eu.cc)
- **GitHub：** [Pretic/PakrPre](https://github.com/Pretic/PakrPre)
