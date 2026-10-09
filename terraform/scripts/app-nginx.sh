#!/bin/bash
dnf install -y nginx

HOST=$(hostname)
IP=$(hostname -I | awk '{print $1}')

cat > /usr/share/nginx/html/index.html <<HTML
<h1>${HOST}</h1>
<p>IP: ${IP}</p>
HTML

systemctl enable --now nginx
firewall-cmd --permanent --add-service=http
firewall-cmd --reload