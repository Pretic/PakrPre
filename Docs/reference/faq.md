# 常见问题

## 打包失败怎么办？

先点击页面右上角的「详细日志」查看最近日志。若仍无法定位，再进入你 Fork 的仓库 → **Actions**，找到对应的 workflow 运行记录查看完整日志。

常见原因：
- Cloudflare Pages 中的 `GH_PAT` 或 `GITHUB_TOKEN` 权限不足，需要 `repo` + `workflow` 两个权限
- Keystore Secrets 配置错误或未配置
- 目标网址无法访问
- 包名格式不合法
- 在线图标无法下载或格式不支持

## APK 安装后无法升级覆盖？

说明两次打包使用了不同的签名。需要正确配置 Keystore Secrets（`KEYSTORE_BASE64`、`KEYSTORE_PASSWORD`、`KEY_ALIAS`、`KEY_PASSWORD`），确保每次签名一致。

## 打包历史丢了？

打包历史保存在浏览器 LocalStorage，清除浏览器缓存后会丢失，这是正常现象。

## 详细日志会长期保存吗？

页面只临时显示当前构建的日志。关闭网页后，页面内缓存会消失；GitHub Actions 自身仍会保留该次运行日志。

## 管理密码默认启用吗？

不会。只有在 Cloudflare Pages 的环境变量中手动添加 `ADMIN_PASSWORD` 后，登录保护才会生效。

## 自定义域名下下载链接为什么还显示 pages.dev？

如果设置了 `PUBLIC_BASE_URL`，从 `pages.dev` 打开会自动跳转到该自定义域名；如果没有设置，页面会按当前访问域名生成下载链接和二维码。

## Actions 额度用完了？

GitHub 免费账号每月 2000 分钟，单次构建约 3~5 分钟，每月约可打包 400~600 次。超出后需等下月重置或升级 GitHub 套餐。

## 支持 iOS 吗？

暂不支持，目前只生成 Android APK。

## 可以打包需要登录的网页吗？

可以，WebView 支持 Cookie，登录状态会保留在应用中。
