# 极客碎语 — Hugo 静态博客

基于 [Hugo](https://gohugo.io) + [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 的个人博客。

🔗 **https://bmg.l2.ink/**

## 技术栈

| 组件 | 说明 |
|------|------|
| 生成器 | Hugo v0.146.5 Extended |
| 主题 | PaperMod（深色模式 / Fuse.js 搜索） |
| 服务器 | Ubuntu 24.04 / Nginx / HTTPS |
| CI/CD | GitHub Actions 自动部署 |
| 域名 | bmg.l2.ink |

## 写作流程

```bash
# 1. 创建新文章
hugo new content posts/my-post.md

# 2. 编辑 Markdown，改 draft: false

# 3. 本地预览
hugo server -D

# 4. 提交 → 推送 → 自动部署
git add -A && git commit -m "新文章" && git push
```

推送后 GitHub Actions 自动构建并部署到服务器，无需手动操作。

## 项目结构

```
├── hugo.yaml                 # Hugo 配置
├── content/posts/            # 文章（Markdown）
├── themes/PaperMod/          # 主题（Git submodule）
├── server-config/
│   ├── nginx-blog.conf       # Nginx 配置（HTTP→HTTPS + SSL）
│   └── server-setup.sh       # 服务器初始化脚本
├── .github/workflows/
│   └── deploy.yml            # GitHub Actions 自动部署
├── deploy.ps1                # Windows 手动部署
└── deploy.sh                 # Linux/Mac 手动部署
```

## 手动部署

```powershell
# Windows
.\deploy.ps1

# Linux/Mac
bash deploy.sh
```

## 服务器信息

- Ubuntu 24.04，2vCPU / 2 GiB / 40 GB
- Nginx 常驻 ~50 MB，剩余资源充裕
