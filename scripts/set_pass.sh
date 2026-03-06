#!/bin/bash
NEW_PASS="SuperSecret123"
HASH=$(slappasswd -s "$NEW_PASS")

# создаем файл изменений
cat <<EOF > rootpw.ldif
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $HASH
EOF

# применяем его через локальный сокет (БЕЗ ПАРОЛЯ)
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f rootpw.ldif

echo ">>> Пароль обновлен. Пробуем войти..."
ldapwhoami -x -D "cn=admin,dc=mydomain,dc=org" -w "$NEW_PASS"
