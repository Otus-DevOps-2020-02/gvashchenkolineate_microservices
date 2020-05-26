# Gitlab-CI

Установка Gitlab и запуск раннеров

## Инвентори

Предполагается, что серве для Gitlab - это поднятый с помощью docker-machine инстанс в GCP.
Используется динамическое docker-machine инвентори - [inventory.docker_machine.yml](inventory.docker_machine.yml)
Для его работоспособности необходим [форкнутый docker_machine плагин](https://github.com/benroose/ansible-docker-machine-inventory-plugin/blob/ansible_host_from_ip/docker_machine.py)

 - Установка плагина:

       git clone --branch ansible_host_from_ip https://github.com/benroose/ansible-docker-machine-inventory-plugin.git ./inventory_plugins

 - Проверка, что используется именно локальный форкнутый плагин.
   См. вывод команды:

       ansible-doc -t inventory docker_machine

Включение плагина в [ansible.cfg](./ansible.cfg):

    [inventory]
    enable_plugins = docker_machine

    [defaults]
    inventory_plugins = ./inventory_plugins
    inventory = ./inventory.docker_machine.yml
    remote_user = docker-user
    private_key_file = ~/.docker/machine/machines/gitlab-ci/id_rsa

## Установка

Подготовка хоста

    ansible-playbook ./playbooks/base.yml
    ansible-playbook ./playbooks/docker.yml

Установка и запуск Gitlab

    ansible-playbook ./playbooks/gitlab.yml --tags install,debug

Запуск и регистрация раннера

    ansible-playbook ./playbooks/gitlab.yml --tags runner,debug

Токен для регистрации раннера должен быть взять из Gitlab Web UI
и проставлен в `runner_token` зашифрованного [vars/runner.yml](./roles/gitlab/vars/runner.yml)
