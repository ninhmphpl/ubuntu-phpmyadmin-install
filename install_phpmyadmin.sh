#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the package list
echo "Updating package list..."
sudo apt-get update

# Install necessary packages
echo "Installing required packages..."
sudo apt-get install -y apache2 mysql-server php php-mbstring php-zip php-gd php-json php-curl

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
sudo apt-get install -y phpmyadmin

# Enable mbstring PHP extension
echo "Enabling mbstring PHP extension..."
sudo phpenmod mbstring

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

# Include phpMyAdmin configuration in Apache
echo "Configuring Apache to include phpMyAdmin configuration..."
sudo tee /etc/apache2/conf-available/phpmyadmin.conf <<EOF
# phpMyAdmin default Apache configuration

Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options FollowSymLinks
    DirectoryIndex index.php

    <IfModule mod_php7.c>
        <FilesMatch ".+\.ph(ar|p|tml)$">
            SetHandler application/x-httpd-php
        </FilesMatch>
        <FilesMatch ".+\.phps$">
            SetHandler application/x-httpd-php-source
        </FilesMatch>
    </IfModule>

    <IfModule mod_deflate.c>
        <IfModule mod_filter.c>
            AddOutputFilterByType DEFLATE application/json
            AddOutputFilterByType DEFLATE application/javascript
            AddOutputFilterByType DEFLATE text/javascript
            AddOutputFilterByType DEFLATE text/css
            AddOutputFilterByType DEFLATE text/html
            AddOutputFilterByType DEFLATE text/plain
        </IfModule>
    </IfModule>

    <IfModule mod_php7.c>
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/var/lib/phpmyadmin/tmp/:/usr/share/php/php-gettext/:/usr/share/javascript/
    </IfModule>

</Directory>

<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>

<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOF

# Enable the phpMyAdmin configuration in Apache
echo "Enabling phpMyAdmin configuration in Apache..."
sudo a2enconf phpmyadmin

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "phpMyAdmin installation and configuration completed successfully."
