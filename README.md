# Дипломный практикум в Cloud: Amazon Web Services"

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера AWS.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

## Этапы выполнения:

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в облаке AWS при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:
- Для выполнения задания следует активировать купон AWS, полученный от координатора курса;
- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.
1. При помощи IAM создайте service account, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой.
1. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
   1. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)
   1. Альтернативный вариант: S3 bucket в созданном AWS аккаунте
1. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
   1. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.
   1. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создавайемый Terraform-ом по-умолчанию (*default*).
1. Создайте VPC при помощи готового [модуля](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) от AWS.
1. При помощи Terraform подготовьте как минимум 3 виртуальных машины EC2 для создания Kubernetes-кластера. Выберите тип виртуальной машины самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.
1. Во время выполнения также понадобится создать [security groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) и некоторые другие ресурсы.
1. Следует учитывать, что доступ к EC2 должен быть возможен через Интернет, а не только по локальной сети.
1. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
1. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.


Ожидаемые результаты:
1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
1. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфрастуктуры.

Это можно сделать двумя способами:
1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.
   1. подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)
   1. задеплоить Kubernetes на подготовленные ранее ec2 инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
1. Альтернативый вариант: воспользуйтесь сервисом [EKS](https://aws.amazon.com/eks/) (Amazon Elastic Kubernetes Service)
   1. воспользуйте модулем [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
   1. дополните уже существующую Terraform конфигурацию, новый проект создавать не нужно.

Ожидаемый результат:
1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:
1. Рекомендуемый вариант:
   1. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.
   2. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:
   1. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:
1. Git репозиторий с тестовым приложением и Dockerfile.
2. Dockerhub регистр с собранным docker image.

### Подготовка Kubernetes конфигурации

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортет](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
1. Задеплоить тестовое приложение, например [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемые способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
1. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

###  Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:
1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:
1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторий с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега в репозитории происходит деплой соответсвующего Docker образа.


###  Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстировать создание всех рессурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.


Выполнение работы.
===========
## Создание облачной инфраструктуры
1. Был создан репозиторий на GitHub с конфигурациями Terraform: [https://github.com/mikhail-pukhov/Diplom](https://github.com/mikhail-pukhov/Diplom)

2. Был создан проект в личном кабинете  Terraform cloud:
![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/5.png)

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/6.png)

### Создание Kubernetes кластера

4. Был развернут кластер кубернетис с помощью Kubespray файлы конфигурации в репозитории GitHub [https://github.com/mikhail-pukhov/kubespray](https://github.com/mikhail-pukhov/kubespray)

``` 
pip3 install -r requirements.txt
ansible-playbook -i kubespray/inventory/mycluster/inventory.ini  kubespray/cluster.yml -u ubuntu --ask-pass -b --ask-become-pass 
```

### Создание тестового приложения

5. Было подготовлено тестовое приложение в виде статической странички Nginx [https://github.com/mikhail-pukhov/test_app](https://github.com/mikhail-pukhov/test_app) 


6. Был подготовлен докер образ этого приложения и размещен на DockerHub [https://hub.docker.com/repository/docker/mikkovrov/test_app](https://hub.docker.com/repository/docker/mikkovrov/test_app)

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/4.png)


### Развертывание мониторинга и тестового приложения в кластере кубернетис

7.  В кластере был развернут пакет kube-prometeus ссылка на репозиторий с этим пакетом  [https://github.com/mikhail-pukhov/kube-prom](https://github.com/mikhail-pukhov/kube-prom)

```
git clone https://github.com/mikhail-pukhov/kube-prom.git
cd kube-prometheus
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/
```
![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/3.png)

Ссылка на веб интерфейс Grafana:

```
URL: http://3.141.37.253:30005/
user: admin
password: admin
```
![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/2.png)

8.  В кластере было развернуто тестовое приложение.

Ссылка на тестовое приложение:

URL: http://3.141.37.253:30003/

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/1.png)


### Установка и настройка CI/CD

9.  В качестве оркестратора был выбран инструмент TeamCity
Дистрибутив был скачен с оф сайта и установлен на Windows 11
Интерфейс доступен по адресу : http://localhost:8111 

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/11.png)

Был создан новый проект в качестве тригера любое изменение кода в репозитории с приложением 
на GitHab.
И 4 BuildStep:
1. Сборка образа по Docker файлу
2. Логин на Docker Hub
3. Push Docker образа в Docker Hub
4. Подключение по ssh к кубернетису удаление старой версии приложения установка новой.


Был изменен один из файлов приложения конвеер отработал без ошибок приложение в кластере обновилос.

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/15.png)

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/7.png)


### ДОПОЛНЕНИЯ

### Установка и настройка CI/CD 

В вебинтерфейсе TeamCity  был создан новый проект kot

В настройках версионирования была включена синхронизация и добавлен в качестве VCS root репозиторий 
GitLab [https://gitlab.com/mikhail-pukhov/kot](https://gitlab.com/mikhail-pukhov/kot)

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/21.png)

В этот репозиторий был сделан коммит пустого проекта kot c сервера TeamCity

далее файл конфигурации проекта 

[https://gitlab.com/mikhail-pukhov/kot/-/blob/main/.teamcity/settings.kts](https://gitlab.com/mikhail-pukhov/kot/-/blob/main/.teamcity/settings.kts)

был отредактирован в WED IDE GitLab 

![Image alt](https://github.com/mikhail-pukhov/skr/blob/main/17.png)

В него на языке Kotlin были добавлены параметры авторизации 
...
 params {
        password("dockerPassword", "123")
        password("sshkey", "zxx42be91b4740ef16f584d29f959bd40181917009da8036c30920328d46a060db952b1ce27b89596c45b6fa0ce43d8c3961adf93")
        password("dockerLogin", "mik")
    }
...

4 шага включающих в себя подключение к докерхабу сборка образа приложения пуш этого образа в докерхаб 
а также подключение к кубернетису и деплой новой версии приложения 
...
steps {
        dockerCommand {
            name = "docker img"
            commandType = build {
                source = file {
                    path = "Dockerfile"
                }
                namesAndTags = "mikkovrov/test_app:latest"
            }
        }
        dockerCommand {
            name = "docker login"
            commandType = other {
                subCommand = "login"
                commandArgs = "-u %dockerLogin% -p %dockerPassword%"
            }
        }
        dockerCommand {
            name = "docker push"
            commandType = push {
                namesAndTags = "mikkovrov/test_app:latest"
            }
        }
        sshExec {
            name = "deploy test_app"
            commands = "cd kube-prom/; kubectl delete -f manifests/test-app-dep.yaml; kubectl create -f manifests/test-app-dep.yaml"
            targetUrl = "3.141.37.253"
            authMethod = defaultPrivateKey {
                username = "ubuntu"
            }
            param("jetbrains.buildServer.sshexec.keyFile", "%sshkey%")
        }
    }
...

    и триггер срабатывания конвеера
    
...
     triggers {
        vcs {
        }
    }
})

object HttpsGithubComMikhailPukhovTestAppGitRefsHeadsMain : GitVcsRoot({
    name = "https://github.com/mikhail-pukhov/test_app.git#refs/heads/main"
    url = "https://github.com/mikhail-pukhov/test_app.git"
    branch = "refs/heads/main"
    branchSpec = "refs/heads/*"
    authMethod = password {
        userName = "mikhail-pukhov"
        password = "123"
    }
...    


Далее конфигурация была загружена из GitLab на сервер TeamCity 















