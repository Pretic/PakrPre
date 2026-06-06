<div align="center">

# PakrPre — 网页一键打包 APK

**填写网址和应用信息，云端自动生成可安装的 Android APK。**

基于 Cloudflare Pages + GitHub Actions，无需在服务器上安装 Android 构建环境。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Platform-Android-3ddc84.svg?logo=android&logoColor=white)](https://developer.android.com)
[![Cloudflare Pages](https://img.shields.io/badge/Hosted_on-Cloudflare_Pages-f6821f.svg?logo=cloudflare&logoColor=white)](https://pages.cloudflare.com)
[![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088ff.svg?logo=githubactions&logoColor=white)](https://github.com/features/actions)

**[在线体验](https://pakrpre.precc.eu.cc) · [GitHub 仓库](https://github.com/Pretic/PakrPre)**

</div>

---

## 来源与致谢

PakrPre 是基于原项目二次开发的版本。感谢原作者 **ZSFan / ZhangShengFan** 开源 Pakr。

- 原作者：ZSFan / ZhangShengFan
- 原项目：[ZhangShengFan/Pakr](https://github.com/ZhangShengFan/Pakr)
- 当前仓库：[Pretic/PakrPre](https://github.com/Pretic/PakrPre)

本项目继续遵循原项目的 MIT License。若继续分发或二次开发，请保留原作者版权与许可证信息。

---

## 功能特性

| 功能 | 说明 |
|------|------|
| 云端构建 APK | 前端提交参数后触发 GitHub Actions，自动注入配置、编译、签名并上传 APK |
| Cloudflare Pages 部署 | 前端页面和 `_worker.js` 合并部署在 Cloudflare Pages，无需单独维护服务器 |
| 多架构输出 | 同时输出 `arm64-v8a` 和 `armeabi-v7a` APK |
| Release 签名 | 支持自定义 Keystore；未配置时会使用临时 Debug Key，不建议正式分发 |
| 自定义图标 | 支持在线图标，也支持按 App 名称/包名生成默认图标和自定义十六进制颜色 |
| 访问身份 | 可选择 `Auto`、`Android`、`iPhone`、`HarmonyOS`、`Android Pad`、`iPad` 等 UA |
| 可选声明页 | 生成时可选择是否在 App 首次进入时显示免责声明 |
| 禁止截图 | 可选择是否在 App 内禁止截图/录屏 |
| 元素屏蔽器 | App 内右键/长按可屏蔽元素、查看元素、管理已屏蔽列表 |
| 规则导入导出 | 元素屏蔽规则可导出/导入，方便迁移到同域名的其他 App |
| 文本与链接复制 | App 内右键/长按文本可复制文本，链接文本可复制文本和链接 |
| 字号调整 | App 内右键/长按菜单提供 `A- / A / A+` 阅读字号调整 |
| 详细日志 | 前端可查看 GitHub Actions 详细日志，并对常见错误进行高亮提示 |
| 管理密码 | 可选配置 `ADMIN_PASSWORD`，配置后才启用页面访问保护 |
| 自定义域名 | 可选配置 `PUBLIC_BASE_URL`，用于自定义域名跳转、下载链接和二维码生成 |
| 打包历史 | 浏览器本地保存最近打包记录，支持复用参数 |

---

## 架构说明

```
浏览器
  │
  ▼
Cloudflare Pages（index.html + _worker.js）
  │
  ├── 触发 GitHub Actions 构建
  ├── 查询构建状态和详细日志
  └── 代理下载 GitHub Artifacts
       │
       ▼
GitHub Actions（Android Gradle 构建、签名、上传 APK）
```

---

## 项目结构

```
PakrPre/
├── .github/workflows/
│   ├── build.yml              # 主构建流程
│   └── gen-keystore.yml       # 生成签名 Keystore
├── Scripts/
│   ├── build_local.ps1        # 本地构建脚本
│   └── process_icon.py        # 图标处理脚本
├── Docs/                      # 旧版文档站内容，当前部署说明以 README 为准
├── Frontend/                  # 旧部署目录提示页，请勿作为当前部署入口
├── index.html                 # 前端页面
├── _worker.js                 # Cloudflare Pages Function API
└── app/                       # Android WebView 项目源码
```

---

## 快速部署

> 旧版文档站与当前二开版本已有明确差异，部署步骤请以本 README 为准。

### 前置要求

- GitHub 账号
- Cloudflare 账号
- 一个 GitHub Personal Access Token，至少需要能触发 Actions、读取 Actions 和下载 Artifacts。公开仓库通常可使用较窄权限；私有仓库需要对应仓库访问权限。

### 第一步 — 准备仓库

将本仓库上传到你自己的 GitHub 仓库，例如 `Pretic/PakrPre`。如果是从原项目或其他仓库 Fork/复制而来，请确认：

- 仓库默认分支为 `main`
- `.github/workflows/build.yml` 和 `.github/workflows/gen-keystore.yml` 已存在
- `index.html` 右上角 GitHub 地址已改成你的仓库地址
- `_worker.js` 中读取的 `GITHUB_OWNER`、`GITHUB_REPO` 与 Cloudflare 变量一致

### 第二步 — 生成签名 Keystore

仓库 → **Actions** → **Generate Keystore** → **Run workflow**。

填写 `key_alias`、`key_password`、`store_password` 后运行，完成后从日志中复制：

- `KEYSTORE_BASE64`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `STORE_PASSWORD`

### 第三步 — 配置 GitHub Actions Secrets

仓库 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**。

| Secret 名称 | 说明 |
|-------------|------|
| `KEYSTORE_BASE64` | 上一步输出的 Base64 Keystore 字符串 |
| `KEYSTORE_PASSWORD` | Keystore / Store 密码 |
| `KEY_ALIAS` | Key 别名 |
| `KEY_PASSWORD` | Key 密码 |

> 未配置 Keystore Secrets 时也能构建，但会使用临时 Debug Key。不同次打包签名可能不一致，无法稳定覆盖安装。

### 第四步 — 部署到 Cloudflare Pages

Cloudflare Dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**，选择你的仓库。

构建配置：

| 配置项 | 值 |
|--------|----|
| Framework preset | None |
| Build command | 留空 |
| Build output directory | `/` |

部署完成后，进入 Pages 项目 → **Settings** → **Environment variables**，添加以下变量。

必填变量：

| 变量名 | 说明 |
|--------|------|
| `GITHUB_OWNER` | GitHub 用户名或组织名，例如 `Pretic` |
| `GITHUB_REPO` | 仓库名，例如 `PakrPre` |
| `GH_PAT` 或 `GITHUB_TOKEN` | GitHub Personal Access Token |

可选变量：

| 变量名 | 说明 |
|--------|------|
| `ADMIN_PASSWORD` | 管理密码。只有设置后才启用登录保护；不设置则公开访问 |
| `PUBLIC_BASE_URL` | 自定义访问域名，例如 `https://pakrpre.precc.eu.cc` |

变量保存后，如果 Cloudflare 提示需要重新部署，请进入 **Deployments** 对最新部署执行 **Retry deployment**。

### 第五步 — 绑定自定义域名（可选）

如果你在 Cloudflare Pages 绑定了自定义域名，建议同时设置：

```text
PUBLIC_BASE_URL=https://你的域名
```

设置后：

- 从 `pages.dev` 打开时会跳转到自定义域名
- 下载链接和二维码会使用自定义域名
- 未设置时，页面会按当前访问域名生成链接

### 第六步 — 验证构建

打开 Pages 域名，填写：

- 目标网址
- App 名称
- 包名
- 版本号
- 图标来源 / 默认图标颜色
- 访问身份
- 禁止截图 / 添加声明

点击「开始打包」。构建完成后下载 `arm64-v8a` 或 `armeabi-v7a` APK 安装测试。

---

## 本地构建

本地构建需要安装 JDK、Android SDK、Python 3 和 Pillow。准备好环境后可使用：

```powershell
.\Scripts\build_local.ps1 `
  -AppUrl "https://example.com" `
  -AppName "Example" `
  -PackageName "com.example.app" `
  -VersionName "1.0.0" `
  -IconMode generated `
  -IconColor "#BF3EFF" `
  -UaMode auto
```

如需安装到已连接设备，可追加 `-Install`。

---

## 构建流程

```
提交表单
  │
  ▼
_worker.js 触发 GitHub Actions workflow_dispatch
  │
  ▼
GitHub Actions
  ├── 注入 URL / 包名 / 版本号 / 图标 / UA / 开关参数
  ├── 处理在线图标或默认图标
  ├── Gradle 编译 APK
  ├── zipalign + apksigner 签名
  └── 上传 arm64-v8a / armeabi-v7a Artifacts
  │
  ▼
前端轮询状态和日志
  │
  ▼
构建完成后显示下载、二维码和复制链接
```

---

## 注意事项

- GitHub Actions 免费额度有限，频繁测试会消耗分钟数。
- Cloudflare Pages 免费额度也有限；公开部署时建议设置 `ADMIN_PASSWORD`，避免地址泄露后被大量触发构建。
- `ADMIN_PASSWORD` 不会自动生成，只有在 Cloudflare Pages 变量中手动添加后才生效。
- 元素屏蔽规则保存在 App 本地，同域名下可通过导入/导出规则迁移。
- 打包历史和页面日志保存在浏览器当前会话/本地记录中，清理缓存后可能丢失。
- APK 是否被系统或安全软件拦截，取决于签名、下载来源、应用行为和各厂商策略。本项目不会主动加入恶意逻辑，但不能保证所有设备都完全不拦截。

---

## License

[MIT](LICENSE)
