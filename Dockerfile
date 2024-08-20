# Use the official PHP image as a base
FROM php:8.2-fpm
# Arguments for user and group IDs
ARG user
ARG uid
# Create a non-root user and group
RUN groupadd -g ${uid} ${user} && \
    useradd -r -u ${uid} -g ${user} -m ${user}
# Set working directory
WORKDIR /var/www
# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    bash \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Install pnpm
RUN npm install -g pnpm
# Set permissions for Laravel folders
 RUN mkdir -p /var/www/storage /var/www/bootstrap/cache && \
    chown -R ${user}:${user} /var/www && \
    chmod -R 775 /var/www/storage && \
    chmod -R 775 /var/www/bootstrap/cache \
    chmod +x /var/www/entrypoint.sh
# Switch to the non-root user
USER ${user}
# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
