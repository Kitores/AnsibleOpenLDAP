# Автоматизация развертывания OpenLDAP через Ansible

Данный проект реализует автоматизированную установку и настройку сервера OpenLDAP на базе **Ubuntu LTS** с использованием **Ansible** и шаблонизатора **Jinja2**.

## 📋 Задача

1. на ОС ubuntu LTS установить openldap сервер
2. установить в ldap пароль администратора
3. установить в ldap domain и organization
4. добавить 2 пользователя в ldap
5. добавить 2 группы в ldap

## 🛠 Подготовка стенда

Для реализации использована связка:

* **Контроллер:** WSL Ubuntu (Ansible).
* **Целевой хост:** VirtualBox Ubuntu LTS.
* **Связь:** SSH по ключам, настроенный файл `inventory.ini`.

```ini
[openLDAP_server]
ubuntuLTS ansible_host=192.168.56.1

[openLDAP_server:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_port=2222
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_user=mihail
ansible_become_password=123456
```

Проверка доступности:
`ansible -i inventory.ini all -m ping` -> **"pong"**

---

## ⚡ Кейс: Решение проблемы "Invalid Credentials (49)"

В процессе разработки возникла классическая проблема: при попытке импорта данных через `ldapadd` сервер возвращал ошибку:

> `ldap_bind: Invalid credentials (49)`

### Причина возникновения

Стандартная установка через `apt` и `debconf` в современных дистрибутивах Ubuntu не всегда гарантирует корректную инициализацию пароля в конфигурационной базе данных (`cn=config`). База может инициализироваться с пустым паролем или на основе системного Hostname, что делает невозможным вход под ожидаемыми учетными данными `admin`.

### Решение: Метод прямой модификации

Вместо того чтобы полагаться на автоматику установщика, в Playbook был добавлен этап **принудителной настройки**.

**Ключевые особенности решения:**

1. **Использование SASL EXTERNAL:** Мы подключаемся через Unix-сокет (`ldapi:///`), что позволяет администратору системы (`sudo`) вносить изменения без знания текущего LDAP-пароля.
2. **Атомарная модификация:** С помощью одной операции `ldapmodify` мы синхронизируем:
* `olcSuffix` — корень домена.
* `olcRootDN` — точное имя администратора.
* `olcRootPW` — хешированный пароль.



---

## 🏗 Структура решения

### 1. Шаблон данных (Jinja2)

Использование шаблона `data.ldif.j2` позволяет динамически генерировать структуру каталога.

```jinja2
dn: {{ ldap_dn }}
objectClass: dcObject
objectClass: organization
o: {{ ldap_org }}
dc: {{ ldap_domain.split('.')[0] }}

dn: ou=groups,{{ ldap_dn }}
objectClass: organizationalUnit
ou: groups

{% for group in my_groups %}
dn: cn={{ group.name }},ou=groups,{{ ldap_dn }}
...
{% endfor %}

```

### 2. Основные этапы Playbook

1. **Install openLDAP packages:** Установка пакетов `slapd`, `ldap-utils`, `debconf-utils` и `python3-ldap`.
2. **Force set LDAP root pass:** Принудительная перезапись атрибутов `olcDatabase={1}mdb` для гарантии верного пароля.
3. **Generate LDIF from template:** Сборка финального LDIF-файла на основе списков пользователей и групп.
4. **Import ldif to openLDAP:** Импорт структуры.

---

## 🚀 Запуск

Для развертывания выполните:

```bash
ansible-playbook -i inventory.ini setup-openldap.yaml

```

## 🔍 Проверка результата

После выполнения можно убедиться в наличии записей командой:

```bash
ldapsearch -x -D "cn=admin,dc=mydomain,dc=org" -w SuperSecret123 -b "dc=mydomain,dc=org"
```
