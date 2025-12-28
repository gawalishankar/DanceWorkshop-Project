# # Use official PHP with Apache image
# FROM php:8.1-apache

# # Set working directory
# WORKDIR /var/www/html

# # Copy your application code into the container
# COPY . /var/www/html/

# # Enable Apache rewrite module (if your app uses mod_rewrite)
# RUN a2enmod rewrite

# # Install mysqli extension for PHP
# RUN docker-php-ext-install mysqli

# # Set permissions for Apache (optional, depending on your app)
# RUN chown -R www-data:www-data /var/www/html \
#     && chmod -R 755 /var/www/html

# # Expose port 80 for ECS load balancer
# EXPOSE 80

# # Start Apache in the foreground
# CMD ["apache2-foreground"]





FROM php:8.2-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set Apache DocumentRoot to danceworkshop folder
ENV APACHE_DOCUMENT_ROOT=/var/www/html

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copy project files
COPY danceworkshop/ /var/www/html/

# Fix permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Update Apache config to allow access
RUN sed -i 's|/var/www/html|/var/www/html|g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

EXPOSE 80
