#!/bin/bash
set -e

# 1. Install Nginx and OpenSSL
yum update -y
yum install -y nginx openssl
systemctl start nginx
systemctl enable nginx

# 2. SSL Directory Setup
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

# 3. Get Public IP for SSL Certificate
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: \$TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

# 4. Generate Self-Signed Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/CN=\$PUBLIC_IP" \
  -addext "subjectAltName=IP:\$PUBLIC_IP"

# 5. Full Nginx Configuration
cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    
    # Enhanced Logging Format (Requirement 3.2)
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    'Cache: \$upstream_cache_status';
    access_log /var/log/nginx/access.log main;

    # Caching Configuration
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m;

    upstream backend_servers {
        server BACKEND_IP_1:80;
        server BACKEND_IP_2:80;
        server BACKEND_IP_3:80 backup; # Part 5.4 requirement
    }

    # HTTP to HTTPS Redirect
    server {
        listen 80;
        server_name _;
        location / { return 301 https://\$host\$request_uri; }
    }

    # HTTPS Server
    server {
        listen 443 ssl;
        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;

        # Security Headers (Requirement 3.2)
        add_header Strict-Transport-Security "max-age=31536000" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;

        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            
            # Caching
            proxy_cache my_cache;
            proxy_cache_valid 200 60m;
            add_header X-Cache-Status \$upstream_cache_status;
        }

        # Health Check Endpoint
        location /health {
            return 200 "Nginx is healthy\n";
        }
    }
}
EOF

# 6. Permissions and Restart
mkdir -p /var/cache/nginx
chown -R nginx:nginx /var/cache/nginx
nginx -t && systemctl restart nginx#!/bin/bash
set -e

# 1. Install Nginx and OpenSSL
yum update -y
yum install -y nginx openssl
systemctl start nginx
systemctl enable nginx

# 2. SSL Directory Setup
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

# 3. Get Public IP for SSL Certificate
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: \$TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

# 4. Generate Self-Signed Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/CN=\$PUBLIC_IP" \
  -addext "subjectAltName=IP:\$PUBLIC_IP"

# 5. Full Nginx Configuration
cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    
    # Enhanced Logging Format (Requirement 3.2)
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    'Cache: \$upstream_cache_status';
    access_log /var/log/nginx/access.log main;

    # Caching Configuration
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m;

    upstream backend_servers {
        server BACKEND_IP_1:80;
        server BACKEND_IP_2:80;
        server BACKEND_IP_3:80 backup; # Part 5.4 requirement
    }

    # HTTP to HTTPS Redirect
    server {
        listen 80;
        server_name _;
        location / { return 301 https://\$host\$request_uri; }
    }

    # HTTPS Server
    server {
        listen 443 ssl;
        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;

        # Security Headers (Requirement 3.2)
        add_header Strict-Transport-Security "max-age=31536000" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;

        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            
            # Caching
            proxy_cache my_cache;
            proxy_cache_valid 200 60m;
            add_header X-Cache-Status \$upstream_cache_status;
        }

        # Health Check Endpoint
        location /health {
            return 200 "Nginx is healthy\n";
        }
    }
}
EOF

# 6. Permissions and Restart
mkdir -p /var/cache/nginx
chown -R nginx:nginx /var/cache/nginx
nginx -t && systemctl restart nginx