---
title: "从零搭建 Hugo 静态博客：方案、配置与部署全记录"
date: "2026-05-24T22:30:00+08:00"
description: "记录用 Hugo + Nginx 在阿里云轻量服务器上搭建静态博客的完整过程，包括选型思路、配置要点和部署脚本。"
tags:
  - Hugo
  - Nginx
  - 静态博客
  - DevOps
categories:
  - 技术
draft: false
---

## 背景

我一直想有个自己的技术博客，需求很明确：

- 📝 用 Markdown 写文章，本地编辑，Git 版本管理
- ⚡ 访问速度快，不依赖后端数据库
- 🛡️ 安全性高，不想整天操心补丁和漏洞
- 💰 成本低，现有服务器跑得动就行
- 🎨 界面简洁，阅读体验好

## 选型：动态 vs 静态

| 维度 | 动态博客 (WordPress/Typecho) | 静态博客 (Hugo/Hexo) |
|---|---|---|
| 速度 | 每次请求查数据库 → 渲染 | 直接返回预生成 HTML，毫秒级 |
| 安全 | SQL 注入、后台漏洞，需持续维护 | 零攻击面，没有可执行代码 |
| 运维 | 需维护 PHP/MySQL/运行环境 | 部署到 Nginx 即可，几乎零维护 |
| 编辑 | 浏览器在线编辑 | 本地 Markdown + Git |
| 服务器要求 | MySQL 就吃掉大半内存 | Nginx 常驻 ~50MB |

我有一台阿里云轻量服务器（2vCPU / 2GiB / 40GB），跑 WordPress 的话 MySQL 一装内存就满了。**静态博客是唯一合理的选择。**

在静态生成器里，我选了 Hugo：

- **速度**：Go 编译的单二进制，全站构建 150ms 以内
- **主题**：PaperMod 简洁现代，内置搜索/暗色模式/RSS
- **部署**：一个 `public/` 目录丢给 Nginx 就完事

## 项目结构

```
Blog/
├── hugo.yaml             # Hugo 配置
├── content/
│   ├── posts/            # 文章（Markdown）
│   └── about.md          # 关于页
├── themes/
│   └── PaperMod/         # 主题（Git submodule）
├── server-config/
│   ├── nginx-blog.conf   # Nginx 配置
│   └── server-setup.sh   # 服务器初始化脚本
├── deploy.ps1            # Windows 部署脚本
├── deploy.sh             # Linux/Mac 部署脚本
└── public/               # 生成的静态文件
```

## Hugo 配置要点

```yaml
# hugo.yaml 核心配置
baseURL: https://47.107.56.48/
languageCode: zh-cn
title: "极客碎语"
theme: PaperMod

params:
  defaultTheme: dark       # 默认深色模式
  ShowCodeCopyButtons: true
  ShowReadingTime: true
  ShowToc: true
  fuseOpts:                # 内置搜索
    threshold: 0.4
    keys: [title, permalink, summary, content]
```

几个值得注意的配置点：

1. **`defaultTheme: dark`** — PaperMod 支持自动切换，这里设深色为默认
2. **`fuseOpts`** — PaperMod 内置 Fuse.js 模糊搜索，无需第三方服务
3. **`--minify`** — 构建时压缩 HTML/CSS/JS，减少传输体积

## Nginx 配置

```nginx
server {
    listen 80;
    server_name 47.107.56.48;

    root /var/www/blog;
    index index.html index.htm;

    # Gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json
               application/javascript text/xml
               application/rss+xml image/svg+xml;

    # 静态资源缓存 30 天
    location ~* \.(jpg|jpeg|png|gif|ico|svg|css|js|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # HTML 不缓存
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-cache";
    }

    location / {
        try_files $uri $uri/ $uri.html =404;
    }
}
```

核心思路：

- **静态资源长缓存** — 图片/CSS/JS 文件名带 hash，改内容即改 URL，30 天没问题
- **HTML 不缓存** — 保证文章更新立即生效
- **`try_files`** — 支持 clean URL（`/posts/xxx` → `/posts/xxx.html`）

## 部署流程

```bash
# 1. 本地构建（142ms 完成）
hugo --minify

# 2. 上传到服务器
scp -r public/* root@47.107.56.48:/var/www/blog/

# 3. 修正权限
ssh root@47.107.56.48 "chown -R www-data:www-data /var/www/blog"
```

部署脚本已写好，Windows 用 `deploy.ps1`，Linux/Mac 用 `deploy.sh`，一条命令搞定。

## 服务器端初始化

```bash
# 一次性操作
apt install -y nginx
mkdir -p /var/www/blog
ufw allow 80/tcp
ufw allow 443/tcp

# 部署 Nginx 配置
cp nginx-blog.conf /etc/nginx/sites-available/blog
ln -s /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
```

## 待做事项

- [ ] 绑定域名 + 配置 HTTPS（Certbot + Let's Encrypt）
- [ ] 配置 GitHub Actions 自动部署（push → build → deploy）
- [ ] 接入评论系统（Giscus / Waline）
- [ ] 添加 sitemap 和 SEO 优化

## 总结

整个搭建过程不到半小时，最终效果：

- 🏗️ **Hugo** 生成 25 页，耗时 **142ms**
- 🌐 **Nginx** 常驻内存 ~50MB
- 📦 全站静态文件 < 1MB
- 🔒 零运行时漏洞面

静态博客方案非常适合技术类个人博客。写文章就是写 Markdown，部署就是 `scp`，干净利落。后面我会陆续把技术笔记搬上来，也会持续完善这个博客的配置。

---

*如果你也想搭建，可以参考这个博客的完整配置：[GitHub 仓库](https://github.com/)（待上传）*
