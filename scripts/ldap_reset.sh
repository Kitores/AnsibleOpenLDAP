#!/bin/bash
sudo apt-get purge -y slapd ldap-utils
sudo rm -rf /var/lib/ldap
sudo rm -rf /etc/ldap/slapd.d

# подкладываем настройки в debconf
echo "slapd slapd/domain string mydomain.org" | sudo debconf-set-selections
echo "slapd slapd/internal/admin_password password SuperSecret123" | sudo debconf-set-selections
echo "slapd slapd/internal/admin_password_confirmation password SuperSecret123" | sudo debconf-set-selections

# устанавливаем заново
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils

# проверка
echo "Пробуем авторизоваться..."
ldapwhoami -x -D "cn=admin,dc=mydomain,dc=org" -w SuperSecret123
