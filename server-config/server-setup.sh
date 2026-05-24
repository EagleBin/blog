#!/bin/bash
# 服务器初始化脚本 — Ubuntu 24.04
# 用法：将本文件 SCP 到服务器后执行
# scp server-config/server-setup.sh root@47.107.56.48:/tmp/
# ssh root@47.107.56.48 "bash /tmp/server-setup.sh"

set -e

echo "=== 1. 更新系统 ==="
apt update && apt upgrade -y

echo "=== 2. 安装 Nginx ==="
apt install -y nginx

echo "=== 3. 创建博客目录 ==="
mkdir -p /var/www/blog
chown -R www-data:www-data /var/www/blog

echo "=== 4. 部署 Nginx 配置 ==="
cp server-config/nginx-blog.conf /etc/nginx/sites-available/blog
ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo "=== 5. 测试配置并重载 ==="
nginx -t && systemctl reload nginx

echo "=== 6. 安装防火墙（可选） ==="
apt install -y ufw
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "=== 7. 安装 Certbot（用于 HTTPS） ==="
apt install -y certbot python3-certbot-nginx

echo "=== 初始化完成！==="
echo "Nginx 已运行在 80 端口"
echo "博客目录：/var/www/blog"
echo ""
echo "下一步：运行 deploy.sh 上传博客文件"
echo "HTTPS：certbot --nginx -d your-domain.com"
