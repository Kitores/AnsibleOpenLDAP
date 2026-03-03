Задача:
написать ansible скрипт реализующий следующее:

1. на ОС ubuntu LTS установить openldap сервер
2. установить в ldap пароль администратора
3. установить в ldap domain и organization
4. добавить 2 пользователя в ldap
5. добавить 2 группы в ldap


Для подготовки тестового стенда настроено ssh соединение от WSL Ubuntu к запущенной локально виртуальной машине VBox Ubuntu LTS. 

Далее создан файл inventory.ini для регистрации хоста в ansible:

[openLDAP_server]
ubuntuLTS ansible_host=192.168.56.1 ansible_user=mihail

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_port=2222

Проверим доступность хоста командой ansible -i inventory.ini all -m ping. Должно вернуть "ping": "pong".


