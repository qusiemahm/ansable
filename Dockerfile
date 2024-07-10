# Use the official OpenLiteSpeed Docker image
FROM litespeedtech/openlitespeed:latest

# Install required packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php8.0 php8.0-fpm php8.0-cli php8.0-mysql php8.0-xml php8.0-mbstring php8.0-curl php8.0-zip php8.0-gd unzip curl git

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Remove existing directory and clone Bedrock repository
RUN rm -rf /var/www/vhosts/localhost && \
    git clone https://github.com/roots/bedrock.git /var/www/vhosts/localhost

# Copy .env file from host to container
COPY .env /var/www/vhosts/localhost/.env

# Set working directory
WORKDIR /var/www/vhosts/localhost

# Install Bedrock dependencies
RUN composer install --no-dev --optimize-autoloader

# Update OpenLiteSpeed configuration to use 'web' instead of 'html'
RUN sed -i 's|$VH_ROOT/html|$VH_ROOT/web|g' /usr/local/lsws/conf/templates/docker.conf

# Expose ports
EXPOSE 80 443 7080 8088 8083 8084 8085

# Create a startup script
RUN echo '#!/bin/bash\n\
composer install --no-dev --optimize-autoloader\n\
/usr/local/lsws/bin/lswsctrl start\n\
tail -f /usr/local/lsws/logs/error.log' > /start.sh && \
    chmod +x /start.sh

# Set the startup script as the entry point
CMD ["/start.sh"]