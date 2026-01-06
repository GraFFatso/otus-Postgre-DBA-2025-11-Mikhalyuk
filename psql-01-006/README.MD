## Занятие 6. Настройка PostgreSQL
### Преподаватель Виктор Коробков
### Проверяющий ДЗ Игорь Тоескин

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

сделать нагрузочное тестирование PostgrSQL\
неастроить параметры PostgreSQL для достижения максимальной производительсности\

## Выполнение ДЗ

из предудущего ДЗ используется ubuntu


*  согласно пошаговой инструкции создаю новый кластер командой (имя кластера содержит месяц занятий и номер занятия)
```
sudo pg_createcluster 18 001-006

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
18  001-006 5438 down   postgres /var/lib/pg_ext_10/18/001-006 /var/log/postgresql/postgresql-18-001-006.log
```

запуск кластера
```
sudo pg_ctlcluster 18 001-006
```
получил ошибку Assertion Failed
ошибка из-за того, что в имени кластера существсует пробел
кластер пересоздал с именем task001_006

* подключение к СУБД
```
sudo -u postgres psql -p 5438
```

* создана БД
```
 CREATE DATABASE task_001_006 \g
 
```
* инициализировать pgbench

```
pgbench -i task_001_006 -p 5436 -U postgres -
```
прерывалось с ошибкой, т.к. тербовался пароль пользователя СУБД
задал пароль
ALTER USER postgres PASSWORD '123'\g

done in 0.90 s (drop tables 0.00 s, create tables 0.17 s, client-side generate 0.42 s, vacuum 0.13 s, primary keys 0.18 s).


т.к. создана БД, то инициализирую тест для созданной БД
так же задаю порт необходимого кластера, имя пользователя которым буду подключаться к БД кластера, 
* тест запущен тест командой
```
 pgbench -c 8 -P 6 -T 60   -p 5438 -U postgres -h 127.0.0.1 task_01_006
```
для этого кластера (2 ядра, 8гб ОЗУ, каталог PGDATA на HDD) с различными параметрами получались различные результаты в районе 40 tps
установка  synchronous_commit в off увеличила tps до 58 пунктов
т.к. отсутствует ожидание записи содержимого WAL  "из памяти на диск"

во время проведения теста посмотрел статистики, чем занят ввод/вывод запросом
```
SELECT * FROM pg_stat_io WHERE writes <> '0' ORDER by writes DESC \g
```
увидел, что больше всего пишут wal и чекпоинты в количестве записей и объеме записей
с ключом -r увидел детализацию, видно что UPDATE занимет больше всего времени
```
statement latencies in milliseconds and failures:
0.004           0 \set aid random(1, 100000 * :scale)
0.001           0 \set bid random(1, 1 * :scale)
0.001           0 \set tid random(1, 10 * :scale)
0.001           0 \set delta random(-5000, 5000)
1.432           0 BEGIN;
8.439           0 UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
1.492           0 SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
3156.035        0 UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
240.953         0 UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
0.328           0 INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
26.913          0 END;
```
перенос кластера с HDD на SSD дает в тесте те же 58 пунктов, даже если synchronous_commit=on (дисковая подсистема справляется со своими задачами)


* настроить кластер PostgreSQL, чтобы при выполнении теста процесс postgresql завершился аварийно

для ВМ уменьшил колво ОЗУ с 8ГБ до 2 ГБ, параметры кластера остались без изменений

содержимое aotuconf
```
shared_buffers = '2GB'
max_parallel_workers_per_gather = '16'
effective_io_concurrency = '1'
effective_cache_size = '4GB'
work_mem = '512MB'
maintenance_work_mem = '1GB'
random_page_cost = '100'
seq_page_cost = '100'
fsync = 'on'
autovacuum = 'on'
checkpoint_timeout = '60min'
wal_level = 'minimal'
max_wal_senders = '0'
synchronous_commit = 'local'
```
создал доп. скрипт для для pgbench, чтобы обеспечить переполнение памяти
```
 SELECT * FROM pgbench_accounts a JOIN pgbench_tellers t ON a.bid = t.bid ;
```

команда, приведшая к падению кластера
```
pgbench -c 128  -j 64  -P 10 -T 100  -p 5438 -U postgres -h localhost -d task_001_006 -r  -f /var/lib/pg_ext_10/pgbench_001

```

