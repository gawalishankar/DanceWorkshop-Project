# Use official PHP with Apache image
FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Copy your application code into the container
COPY . /var/www/html/

# Enable Apache rewrite module (if your app uses mod_rewrite)
RUN a2enmod rewrite

# Install mysqli extension for PHP
RUN docker-php-ext-install mysqli

# Set permissions for Apache (optional, depending on your app)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80 for ECS load balancer
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
