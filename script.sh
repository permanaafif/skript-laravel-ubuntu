#!/bin/bash

# Perbarui daftar paket
sudo apt update

# Instal Apache2
sudo apt install -y apache2

# Instal PHP dan ekstensi yang diperlukan
sudo apt install -y php libapache2-mod-php php-mbstring php-xmlrpc php-soap php-gd php-xml php-cli php-zip php-bcmath php-tokenizer php-json php-pear

# Instal Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Klon repositori
cd /var/www/html
sudo git clone https://github.com/permanaafif/website-senior.git

# Atur izin
sudo chgrp -R www-data /var/www/html/website-senior/
sudo chmod -R 775 /var/www/html/website-senior/storage

# Instal dependensi proyek
cd /var/www/html/website-senior
sudo composer install --ignore-platform-req=ext-curl --no-interaction

# Atur file lingkungan
sudo cp .env.example .env
sudo php artisan key:generate

# Cadangkan konfigurasi default Apache
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak

# Tulis konfigurasi baru Apache
sudo sh -c 'cat <<EOT > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/website-senior/public

    <Directory /var/www/html/website-senior>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT'

# Aktifkan mod_rewrite
sudo a2enmod rewrite

# Restart Apache untuk menerapkan perubahan
sudo systemctl restart apache2
