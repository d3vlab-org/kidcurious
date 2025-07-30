# Multi-stage production Dockerfile for KidCurious monorepo
# Stage 1: Build React frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy frontend package files
COPY KidCurious-front/package*.json ./

# Install frontend dependencies
RUN npm ci --only=production

# Copy frontend source code
COPY KidCurious-front/ ./

# Build frontend for production
RUN npm run build

# Stage 2: Setup Laravel backend
FROM php:8.2-fpm-alpine AS backend-builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    bcmath \
    gd \
    xml \
    zip \
    pcntl \
    sockets

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy backend composer files
COPY KidCurious-backend/composer.json KidCurious-backend/composer.lock ./

# Install PHP dependencies (production only)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy backend application code
COPY KidCurious-backend/ ./

# Stage 3: Final production image with Nginx
FROM nginx:alpine AS production

# Install PHP-FPM and supervisor
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-pdo \
    php82-pdo_pgsql \
    php82-bcmath \
    php82-gd \
    php82-xml \
    php82-zip \
    php82-pcntl \
    php82-sockets \
    php82-redis \
    php82-session \
    php82-tokenizer \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-curl \
    php82-json \
    supervisor \
    curl

# Create symlink for php command
RUN ln -s /usr/bin/php82 /usr/bin/php

# Copy backend files from backend-builder
COPY --from=backend-builder /var/www/html /var/www/html

# Copy frontend build from frontend-builder
COPY --from=frontend-builder /app/frontend/dist /var/www/html/public/frontend

# Create nginx configuration
COPY <<EOF /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    server {
        listen 8080;
        server_name _;
        root /var/www/html/public;
        index index.php index.html;
        
        # Handle frontend routes
        location / {
            try_files \$uri \$uri/ /frontend/index.html;
        }
        
        # Handle API routes
        location /api {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        # Handle Laravel routes
        location ~ \.php\$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # Static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Create supervisor configuration
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/nginx/error.log
stdout_logfile=/var/log/nginx/access.log

[program:php-fpm]
command=php-fpm82 --nodaemonize
autostart=true
autorestart=true
stderr_logfile=/var/log/php-fpm.log
stdout_logfile=/var/log/php-fpm.log
EOF

# Set permissions
RUN chown -R nginx:nginx /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]