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
    Последующий лог команды `docker images`, а также отличия образа от контейнера, записаны в файл [docker-1.log](./docker/docker-monolith/docker-1.log)

  - В новом GCP проекте [docker-276915](https://console.cloud.google.com/compute/instances?project=docker-276915)
    c помощью docker-machine создан хост для Monolith Reddit app.
    С помощью [Dockerfile](./docker/docker-monolith/Dockerfile) собран docker образ с установленными MongoDB, Ruby и задеплоенным приложением,
    из него запущен контейнер.
    См. подробнее [здесь](./docker/docker-monolith/create_docker_machine.sh)

  - Образ приложения загружен в docker hub: [gvashchenko/otus-reddit](https://hub.docker.com/r/gvashchenko/otus-reddit)

  - (⭐) Автоматизация поднятия докеризованного приложения в GCP

    - Packer-шаблон для создания образов инстансов с предустановленным Docker [docker-host](./docker/docker-monolith/infra/packer/docker-host.json).
      Установка Docker осуществляется Ansible-плэйбуком [packer_docker.yml](./docker/docker-monolith/infra/ansible/playbooks/packer_docker.yml)

    - Поднятие инстансов осуществляется [Terraform-проектом](./docker/docker-monolith/infra/terraform).
      Количество поднимаемых инстансов задается переменной `instance_count`

    - Подготовка и запуск docker-контейнера с приложением осуществляется Ansible-плэйбуком [site.yml](./docker/docker-monolith/infra/ansible/playbooks/site.yml)

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

    См. подробнее в [create_docker_machine.sh](./docker/docker-monolith/create_docker_machine.sh)
    Потребуется также создать правило файрвола для доступа на порт Puma (9292), напр. с помощью [gcloud_add_firewall_rule_puma.sh](./docker/docker-monolith/gcloud_add_firewall_rule_puma.sh)

  - Для использования автоматизированного поднятия докерезированного приложения на GCP инстансах требуется

    - Создать образ с предустановленным Docker
      ```
      cd ./docker-monolith/infra
      packer build -var-file ./packer/variables.json ./packer/docker-host.json
      ```

    - В [terraform.tfvars](./docker/docker-monolith/infra/terraform/terraform.tfvars)
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
    Если ошибка `This site can't be reached`, значит не добавлено правило файрвола (исп. [gcloud_add_firewall_rule_puma.sh](./docker/docker-monolith/gcloud_add_firewall_rule_puma.sh)).

  - Проверить приложения, развернутые проектом [infra](./docker/docker-monolith/infra),
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
    См. подробнее в [docker_run_with_new_envvars_and_aliases.sh](./docker/docker_run_with_new_envvars_and_aliases.sh)

  - (⭐) Произведена оптимизация (минимизация размера) образов ui и comment сервисов
    путём их сборки на основе Ubuntu или Alpine-Linux, см.
    - [post/Dockerfile](./src/post-py/Dockerfile)
    - [comment/Dockerfile](./src/comment/Dockerfile)
    - [ui/Dockerfile](./src/ui/Dockerfile)
    - [ui/Dockerfile.3](./src/ui/Dockerfile.3)

    Сравнение размеров получающихся образов см. в [image_size_diff](./docker/image_size_diff)

## Как запустить проект:

  - Создать _docker-host_ и подключиться к нему (см. [create_docker_machine](./docker/docker-monolith/create_docker_machine.sh))

  - Выполнить необходимые команды создания bridge-сети, volume, сборки образов, запуска контейнера и т.п.
    (см. в [docker_build_run.sh](./docker/docker_build_run.sh)
    или [docker_run_with_new_envvars_and_aliases.sh](./docker/docker_run_with_new_envvars_and_aliases.sh))

## Как проверить работоспособность:

  - Каждая конфигурация запущенных сервисов проверяется обращением к http://`docker-host-ip`:9292



---

# ДЗ-14 "Docker: сети, docker-compose"

## В процессе сделано:

  - Выполнены эксперименты с запуском docker-контейнеров в сети под драйверами none, host, bridge

  - Запуск больше одного контейнера nginx с `--network host` не возможен
    из-за ошибки уже занятости пота,
    в отличие от запуска nginx с `--network none`, когда каждый раз создаётся отдельный network namespace.

  - Сервисы reddit_microservices запущены через `docker run` с использование двух сетей _front_net_ и _back_net_,
    так чтобы ui не имел доступа к mongodb.
    Для этого подсоединять контейнеры ко вторых сетям необходимо вручную.

  - Проведены исследования bridge-интерфейсов и сетей на docker-machine.

  - Добавлен [docker-compose.yml](./docker/docker-compose.yml),
    адаптирован под случай двух сетей (front_net, back_net),
    и параметризован с использованием файла [.env](./docker/.env.example).

  - Базовое имя проекта в docker-compose по-умолчанию - имя каталога, т.е. [src](./src).
    Чтобы изменить это можно:
      - задать переменную [`COMPOSE_PROJECT_NAME`](https://docs.docker.com/compose/reference/envvars/#compose_project_name) в _.env_
      - или передавать через ключ [`-p, --project-name`](https://docs.docker.com/compose/reference/overview/#use--p-to-specify-a-project-name) команды `docker compose`:

            docker-compose -p reddit up -d

      _Замечание: Второй способ (через ключ команды) имеет приоритет перед переменной_

  - (⭐) Создан [docker-compose.override.yml](./docker/docker-compose.override.yml)
    для запуска puma в режиме _debug_ с двумя воркерами,
    а также с возможностью динамического редактирования кода

## Как запустить проект:

  - Создать _docker-host_ и подключиться к нему (см. [create_docker_machine](./docker/docker-monolith/create_docker_machine.sh))

  - Выполнить необходимые команды создания сетей, volume, сборки образов, запуска контейнера и т.п.
    (см. в [docker_build_run.sh](./docker/docker_build_run.sh))
    или docker-compose команды

        docker-compose up -d
        docker-compose down

## Как проверить работоспособность:

  - Каждая конфигурация запущенных сервисов проверяется обращением к http://`docker-host-ip`:9292



---

# ДЗ-15 "Устройство Gitlab CI. Построение процесса непрерывной поставки"

## В процессе сделано:

  - С помощью docker-machine поднимается GCP-инстанс (см. [docker-machine/create.sh](./gitlab-ci/docker-machine/create.sh))

  - Установлен Gitlab CI и запущены Runner-ы.
    Два способа:

    - с помощью docker-machine ssh-команд (см. скрипты в [docker-machine](./gitlab-ci/docker-machine))
      Этот способ не очень удобен, т.к. ssh-команды разрастаются,
      как например в случае автоматизированного запуска и регистрации runner'а.

    - с помощью [Ansible плэйбуков](./gitlab-ci/ansible) и динамического docker-machine инвентори.
      См. подробнее в [ansible/README.md](./gitlab-ci/ansible/README.md)

  - Создан Gitlab-проект и настроен для использования CI/CD.
    Этот репозиторий запушен в него как в дополнительный remote.

  - CI/CD сконфигурирован запускать тесты, поднимать динамические окружения
    с учетом требований к веткам и других ограничений (тэги, ручной запуск).

  - (⭐) В шаг build попробовал добавить сборку образа reddit-приложения.
    **!!! Оставлен *TODO*, т.к. не работают bundle и ruby !!!**

  - (⭐) Для автоматизации добавления раннера создана Ansible роль [gitlab](./gitlab-ci/ansible/roles/gitlab)

  - (⭐) Настроена интеграция со Slack-каналом [#georgy-vashchenko](https://devops-team-otus.slack.com/messages/georgy_vashchenko)

## Как запустить проект:

  - Создать _docker-host_ и подключиться к нему (см. [create_docker_machine](./gitlab-ci/docker-machine/create.sh)

  - Выполнить подготовку хоста

        ansible-playbook ./playbooks/base.yml
        ansible-playbook ./playbooks/docker.yml

  - Установить Gitlab

        ansible-playbook ./playbooks/gitlab.yml --tags install,debug

  - Добавить раннер

        ansible-playbook ./playbooks/gitlab.yml --tags runner,debug

  - Запушить коммит с `.gitlab-ci.yml` в репозитории в Gitlab как remote

## Как проверить работоспособность:

  - После установки Gitlab на VM можно перейти по http://VM_PUBLIC_IP.
    _(Начальная инициализация Gitlab может занять несколько минут)_

  - Добавленные для проекта раннеры видны тут: http://VM_PUBLIC_IP/group/project/-/settings/ci_cd

  - Зайти в Slack-канал для просмотра уведомлений о пушах и сборках



---

# ДЗ-16 "Введение в мониторинг. Системы мониторинга."

## В процессе сделано:

  - Prometheus поднят в докер-контейнере на GCP-инстансе через docker-machine

  - Образ Prometheus собирается из [Dockerfile](./monitoring/prometheus/Dockerfile)
    добавлением файла настроек [prometheus.yml](./monitoring/prometheus/prometheus.yml)
    с мониторингом всех сервисов reddit-приложения (ui, comment, post)

  - Проведены эксперименты с отключением сервисов и мониторингом их хелхчеков в Prometheus

  - В [docker-compose.yml](./docker/docker-compose.yml), помимо Prometheus,
    добавлены экспортёры:

    - Node exporter ( [github](https://github.com/prometheus/node_exporter), [dockerhub](https://hub.docker.com/r/prom/node-exporter/) )

    - (⭐) Экспортера для MongoDB ( [github](https://github.com/percona/mongodb_exporter), [dockerhub](https://hub.docker.com/r/bitnami/mongodb-exporter) )

    - (⭐) Blackbox exporter ( [github](https://github.com/prometheus/blackbox_exporter), [dockerhub](https://hub.docker.com/r/prom/blackbox-exporter/) )

    - (⭐) Cloudprober ( [github](https://github.com/google/cloudprober), [dockerhub](https://hub.docker.com/r/cloudprober/cloudprober) )

     _В случае последних двух собираются собственные образы, куда добавляется файл настроек_
     _Версия родительского образа при этом зафиксирована на стабильную_

  - (⭐) Добавлен простой [Makefile](./Makefile) для автоматизации процесса сборки
    всех или любого из образов и загрузки в докер хаб

  - Собранные обазы запушены в [Docker Hub](https://hub.docker.com/repository/docker/gvashchenko/)

## Как запустить проект:

  - Созадть GCP-инстанс скриптом [create_docker_machine.sh](./monitoring/prometheus/create_docker_machine.sh)

  - Создать правила файервола скриптами [gcloud_add_firewall_rules_prometheus_puma.sh](./monitoring/prometheus/gcloud_add_firewall_rules_prometheus_puma.sh).

    В целях отладки также можно добавить правила файервола для экспортеров:
    [gcloud_add_firewall_rules_blackbox.sh](./monitoring/blackbox-exporter/gcloud_add_firewall_rules_blackbox.sh)
    и [gcloud_add_firewall_rules_cloudprober.sh](./monitoring/cloudprober/gcloud_add_firewall_rules_cloudprober.sh)

  - Переключиться на докер-окружение (см. подробнее в [здесь](./monitoring/maintain_monitoring.sh)))

        eval $(docker-machine env docker-host)
        export USER_NAME=gvashchenko

  - Собрать все необходимые образы

        `make b_all`

  - Запустить докер-инфраструктуру

        cd ./docker
        docker-compose -f docker-compose.yml up -d

## Как проверить работоспособность:

  - Получить IP адрес VM с запущенными сервисами

        docker-machine ip docker-host

  - Приложение должно быть доступно по http://docker-host-ip:9292

  - Prometheus должен быть доступен по http://docker-host-ip:9000

  - Метрики cloudbox-exporter'а должы быть доступны по http://docker-host-ip:9115

  - Метрики cloudprober'а должны быть доступны по http://docker-host-ip:9313
