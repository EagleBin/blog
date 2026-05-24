# 极客碎语 — Hugo 静态博客

基于 [Hugo](https://gohugo.io) + [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题的个人静态博客。

- 🖥️ 服务器：Ubuntu 24.04（2vCPU / 2 GiB / 40 GB）
- 📡 公网 IP：47.107.56.48
- ⚡ 生成器：Hugo Extended v0.145.0+
- 🎨 主题：PaperMod

---

## 项目结构

```
D:\Program\Blog\
├── hugo.yaml               # Hugo 主配置
├── .gitignore              # Git 忽略规则
├── deploy.ps1              # 部署脚本（Windows PowerShell）
├── deploy.sh               # 部署脚本（bash / WSL）
├── archetypes/
│   └── default.md          # 新文章模板
├── content/
│   ├── about.md            # 关于页
│   ├── search.md           # 搜索页
│   └── posts/              # 博客文章
│       ├── hello-world.md
│       └── markdown-guide.md
├── server-config/
│   ├── nginx-blog.conf     # Nginx 配置
│   └── server-setup.sh     # 服务器初始化脚本
├── static/                 # 静态资源（图片、favicon 等）
├── themes/
│   └── PaperMod/           # 主题
└── layouts/                # 自定义布局（如需）
```

---

## 快速开始

### 1. 本地写作

```powershell
# 创建新文章
.\bin\hugo.exe new content posts/my-post.md

# 编辑文章（Markdown）
# content/posts/my-post.md

# 本地预览（含草稿）
.\bin\hugo.exe server -D
# 打开 http://localhost:1313
```

### 2. 构建

```powershell
.\bin\hugo.exe --minify
# 产出在 public/ 目录
```

### 3. 部署

```powershell
# PowerShell 部署
.\deploy.ps1 -Server root@47.107.56.48

# 或 bash / WSL 部署
bash deploy.sh

# 仅预览不执行
.\deploy.ps1 -DryRun
```

---

## 服务器初始化（仅需一次）

### 1. SSH 登录服务器

```bash
ssh root@47.107.56.48
```

### 2. 上传并执行初始化脚本

```powershell
scp .\server-config\server-setup.sh root@47.107.56.48:/tmp/
scp .\server-config\nginx-blog.conf root@47.107.56.48:/tmp/
ssh root@47.107.56.48 "bash /tmp/server-setup.sh"
```

### 3. 配置 HTTPS（如有域名）

```bash
ssh root@47.107.56.48
certbot --nginx -d your-domain.com
# 测试自动续签
certbot renew --dry-run
```

---

## 日常写作流程

```
1. hugo new content posts/xxx.md    → 创建文章
2. 编辑 Markdown，改 draft: false   → 写内容
3. hugo server -D                   → 本地预览
4. hugo --minify                    → 构建
5. ./deploy.ps1                     → 部署
```

---

## 资源占用

| 组件   | 内存    |
|--------|---------|
| Nginx  | ~50 MB  |
| 系统   | ~300 MB |
| 可用   | ~1.6 GB |

40 GB 磁盘 + 200 Mbps 带宽，够用很多年。

---

## 待做

- [ ] 绑定域名
- [ ] 配置 HTTPS（Certbot）
- [ ] 添加更多文章
- [ ] 配置评论系统（giscus / utterances）
- [ ] 配置 Google Analytics / Umami 统计
