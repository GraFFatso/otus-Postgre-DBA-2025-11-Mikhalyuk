## Занятие 20. резервное копирование и восстановление
### Преподаватель МИхаил Ржевский
### Проверяющий ДЗ Людмила Громницкая

## подготовительные работы, вводные

использую "стенд" с hyper-v, i7-3770, 30GB RAM\
создаю ВМ по необходимости\
к различным хостам подключаюсь через mobaxterm

### Подготовтительные работы
* для ВМ выделил 2 ядра, 8гб ОЗУ, статический MAC, чтобы не сбивался IP

* установил ubuntu-22.05.5 live -server без GUI

* установка доп. необходимго ПО в ubuntu

```sudo apt update && sudo apt upgrade```\
```sudo apt install mc openssh-server openssh-client unzip wget sysstat whiptail```

команда _iostat_ в пакете _sysstat_\
_whiptail_ необходим для диалогов установки postgresql\
команда _netstat_ в пакете _net-tools_\
установилось новое ядро Linux 5.15.0

* в ВМ ubuntu 22.04 установлены пакеты 15, 16 и 17 версий postgresql
* 2026-01-06 в ВМ ubuntu 22.04 установлены пакеты 18 версии postgresql

## Цель занятия

насттроить бэкапы;\
восстановить информацию после сбоя.\

## Выполнение ДЗ

из предудущего ДЗ используется ubuntu


*  согласно пошаговой инструкции создаю новый кластер командой (имя кластера содержит месяц занятий и номер занятия)
```
sudo pg_createcluster 18 003_020

```
т.к.  в предыдущих заданиях я задал параметры, с которыми будет инициализироваться новый кластер через содержимое файла
```
/etc/postgresql-common/createcluster.d/001.conf
```
файл "принимается в работу" согласно параметров по-умолчанию в файле
```
cat /etc/postgresql-common/createcluster.conf
```
содержимое настроечного файла
```
start_conf = 'manual'
initdb_options = '--encoding=UTF8 --data-checksums --icu-locale=ru --locale-provider=icu  --lc-collate=ru_RU.UTF-8  --lc-ctype=ru_RU.UTF-8'
```

создался необходимый кластер
```
Ver Cluster Port Status Owner    Data directory                Log file
18  003_020 5439 down   postgres /var/lib/pg_ext_10/18/002_020 /var/log/postgresql/postgresql-18-003_020.log
```

запуск кластера
```
sudo pg_ctlcluster 18 003_020
```

* подключение к СУБД
```
sudo -u postgres psql -p 5439
```

* создана БД
```
CREATE DATABASE test_db

```
* перекелючение на БД
```
\c test_db
```
* создание схемы в БД test_db
```
CREATE SCHEMA my_schema\g

```
* создание двух таблиц 

```
CREATE TABLE my_schema.table1  AS SELECT generate_series(1,100) AS id  \g
CREATE TABLE my_schema.table2 (id int) \g
 
```
* создание каталога для резервных копий
```
sudo -u postgres mkdir /var/lib/postgresql/backups
```
* сохранение дампа таблицы в файл в формате csv
```
COPY my_schema.table1 TO '/var/lib/postgresql/backups/001.table.csv' WITH (FORMAT csv )\g

```
* загрузка данных из файла дампа в table2
```
COPY my_schema.table2 FROM  '/var/lib/postgresql/backups/001.table.csv' WITH (FORMAT csv )\g
```
* бэкап через pg_dump только схемы my_schema
```
 sudo -u postgres pg_dump --create -Fc --schema=my_schema   -p 5439 -U postgres -f /var/lib/postgresql/backups/pg_dump.001.dump -d test_db
```

* создана БД и схема в этой БД
```
CREATE DATABASE restored_db \g
postgres=# \c restored_db
restored_db=# CREATE SCHEMA my_schema \g
```
* в новую БД restored_db восстановить только table2 из дампа.
```
sudo -u postgres pg_restore  -Fc --schema=my_schema   -p 5439 -U postgres  /var/lib/postgresql/backups/pg_dump.001.dump -d restored_db --table=table2
```

проверка существования таблиц в БД и данных
```
SELECT * FROM pg_catalog.pg_tables WHERE tablename LIKE '%tab%'\g
SELECT * FROM my_schema.table2 LIMIT 10\g
```