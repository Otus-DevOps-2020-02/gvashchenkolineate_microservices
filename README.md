# gvashchenkolineate_microservices
gvashchenkolineate microservices repository

---

# ДЗ-12 "Технология контейнеризации. Введение в Docker"

## В процессе сделано:

  - Настройка репозитория

    - Добавлены pre-commit хуки и PR шаблон
    - Настроена интеграция с TravisCI
    - Настроены Github- и TravixCI- уведомления в [Slack-канал](https://devops-team-otus.slack.com/messages/georgy_vashchenko)

  - Создан docker image из запущенного из образа Ubuntu:16.04 "измененного" контейнера.
    Последующий лог команды `docker images`, а также отличия образа от контейнера, записаны в файл [docker-1.log](./docker-monolith/docker-1.log)

  - В новом GCP проекте [docker-276915](https://console.cloud.google.com/compute/instances?project=docker-276915)
    c помощью docker-machine создан хост для Monolith Reddit app.
    С помощью [Dockerfile](./docker-monolith/Dockerfile) собран docker образ с установленными MongoDB, Ruby и задеплоенным приложением,
    из него запущен контейнер.
    См. подробнее [здесь](./docker-monolith/create_docker_machine.sh)

  - Образ приложения загружен в docker hub: [gvashchenko/otus-reddit](https://hub.docker.com/r/gvashchenko/otus-reddit)

  - (⭐) Автоматизация поднятия докеризованного приложения в GCP

    - Packer-шаблон для создания образов инстансов с предустановленным Docker [docker-host](./docker-monolith/infra/packer/docker-host.json).
      Установка Docker осуществляется Ansible-плэйбуком [packer_docker.yml](./docker-monolith/infra/ansible/playbooks/packer_docker.yml)

    - Поднятие инстансов осуществляется [Terraform-проектом](./docker-monolith/infra/terraform).
      Количество поднимаемых инстансов задается переменной `instance_count`

    - Подготовка и запуск docker-контейнера с приложением осуществляется Ansible-плэйбуком [site.yml](./docker-monolith/infra/ansible/playbooks/site.yml)

## Как запустить проект:

  - Для создания docker-хоста в GCP с помощью docker-machine и запуска контэйнера из docker-hub образа требуется выполнить команды

    ```
    export GOOGLE_PROJECT=docker-276915

    docker-machine create --driver google \
      --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
      --google-machine-type n1-standard-1 \
      --google-zone europe-west1-b \
      docker-host

    eval $(docker-machine env docker-host)

    docker run --name reddit -d -p 9292:9292 gvashchenko/otus-reddit:1.0
    ```

    См. подробнее в [create_docker_machine.sh](./docker-monolith/create_docker_machine.sh)
    Потребуется также создать правило файрвола для доступа на порт Puma (9292), напр. с помощью [gcloud_add_firewall_rule_puma.sh](./docker-monolith/gcloud_add_firewall_rule_puma.sh)

  - Для использования автоматизированного поднятия докерезированного приложения на GCP инстансах требуется

    - Создать образ с предустановленным Docker
      ```
      cd ./docker-monolith/infra
      packer build -var-file ./packer/variables.json ./packer/docker-host.json
      ```

    - В [terraform.tfvars](./docker-monolith/infra/terraform/terraform.tfvars)
      указать имя созданного образа `docker_disk_image`,
      а также количество поднимаемых инстансов `instance_count`.
      Поднять инфраструктуру:
      ```
      cd ./docker-monolith/infra/terraform
      terraform init
      terraform apply
      ```

    - Запустить на поднятых хостах docker-контейнеры из docker-hub образа приложения с помощью:
      ```
      cd ./docker-monolith/infra/ansible
      ansible-playbook ./playbooks/site.yml
      ```

## Как проверить работоспособность:

  - Проверить приложение, запущенное на docker-machine хосте, можно,
    перейдя по адресу `http://<ip>:9292`, где `ip` - адрес хоста (можно получить из вывода команды `docker-machine ls`).
    Если ошибка `This site can't be reached`, значит не добавлено правило файрвола (исп. [gcloud_add_firewall_rule_puma.sh](./docker-monolith/gcloud_add_firewall_rule_puma.sh)).

  - Проверить приложения, развернутые проектом [infra](./docker-monolith/infra),
    можно перейдя по адресам `http://<ip>:9292`,
    где `ip` - адреса `docker-host-external-ip` из вывода команды `terraform output`



---

# ДЗ-13 "Docker-образы. Микросервисы"

## В процессе сделано:

  - Проект _reddit-microservices_ скачан как [src](./src)

  - Последующие docker-команды выполняются на созданной в GCE docker-machine
    _docker-host_ c внешним ip `docker-host-ip`

  - Для каждого сервиса (post, comment, ui) создан Dockerfile и собран образ

  - Также созданы bridge-сеть `reddit` и volume для MongoDB `reddit_db`

  - (⭐) Контейнеры запущены с сетевыми алиасами, отличными от тех, что задаются в самих Dockerfile-ах.
    Dns сервисов передаются другим сервисам через `--env` аргументы команды `docker run`.
    См. подробнее в [docker_run_with_new_envvars_and_aliases.sh](./src/docker_run_with_new_envvars_and_aliases.sh)

  - (⭐) Произведена оптимизация (минимизация размера) образов ui и comment сервисов
    путём их сборки на основе Ubuntu или Alpine-Linux, см.
    - [post/Dockerfile](./src/post-py/Dockerfile)
    - [comment/Dockerfile](./src/comment/Dockerfile)
    - [ui/Dockerfile](./src/ui/Dockerfile)
    - [ui/Dockerfile.3](./src/ui/Dockerfile.3)

    Сравнение размеров получающихся образов см. в [image_size_diff](./src/image_size_diff)

## Как запустить проект:

  - Создать _docker-host_ и подключиться к нему (см. [create_docker_machine](./docker-monolith/create_docker_machine.sh))

  - Выполнить необходимые команды создания bridge-сети, volume, сборки образов, запуска контейнера и т.п.
    (см. в [docker_build_run.sh](./src/docker_build_run.sh)
    или [docker_run_with_new_envvars_and_aliases.sh](./src/docker_run_with_new_envvars_and_aliases.sh))

## Как проверить работоспособность:

  - Каждая конфигурация запущенных сервисов проверяется обращением к http://`docker-host-ip`:9292
