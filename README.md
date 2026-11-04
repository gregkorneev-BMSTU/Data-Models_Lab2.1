# ЛР №2 (часть 1)

## Цель работы

Освоить выборку данных с помощью SQL: сортировку и ограничение результатов, фильтрацию, подзапросы, агрегатные функции, группировку, соединения таблиц и условный вывод.

ЛР №2 (часть 1) выполняется **на базе данных, созданной в ЛР №1 (часть 2)**. Структура таблиц и связи сохранены, а для демонстрации запросов добавлены тестовые записи.

## Структура репозитория

```text
Data-Models_Lab2.1/
├── README.md
├── report/
│   └── ЛР2_ч1_КорнеевГИ_ИУ5-34Б.docx # итоговый Word-отчёт
├── database/
│   ├── LR1_part2.sqlite         # база данных SQLite
│   ├── LR1_part2_structure.sql  # исходная DDL-структура из ЛР №1.2
│   └── LR2_part1_seed.sql       # добавление тестовых записей
├── models/
│   ├── ER.png                   # ER-диаграмма
│   └── infological_model.pdf    # инфологическая модель
├── queries/
│   └── LR2_part1_queries.sql    # 14 общих + 2 индивидуальных SELECT-запроса
└── screenshots/
    └── queries/                # 16 скриншотов выполнения запросов в DBeaver
```

## Структура базы данных

Используются **8 таблиц**:

| Таблица | Назначение |
| --- | --- |
| `study_group` | учебные группы |
| `student` | студенты и принадлежность к группам |
| `teacher` | преподаватели |
| `discipline` | учебные дисциплины |
| `discipline_course` | проведение дисциплин для групп |
| `discipline_teacher` | связь дисциплин и преподавателей |
| `lesson` | занятия в рамках курсов |
| `control_result` | результаты контроля знаний студентов |

Исходная схема задаёт **9 внешних ключей** и ограничения целостности; описание структуры находится в [DDL-файле](database/LR1_part2_structure.sql). Связь «дисциплина — преподаватель» представлена отдельной таблицей `discipline_teacher`.

## Выполненные задания

### Общая часть — 14 запросов

| № | Тема | Использованные конструкции | Скриншот |
| ---: | --- | --- | --- |
| 1 | Выбор всех записей | `SELECT *` | [01](screenshots/queries/task_01_select_all.png) |
| 2 | Выбор отдельных столбцов | `SELECT col1, col2` | [02](screenshots/queries/task_02_select_columns.png) |
| 3 | Сортировка данных | `ORDER BY ... ASC` | [03](screenshots/queries/task_03_order_by.png) |
| 4 | Ограничение результата | `LIMIT`, `OFFSET` | [04](screenshots/queries/task_04_limit_offset.png) |
| 5 | Фильтрация по значениям и диапазону | `WHERE`, `BETWEEN` | [05](screenshots/queries/task_05_where_between.png) |
| 6 | Подзапрос для отбора студентов | `IN (SELECT ...)` | [06](screenshots/queries/task_06_in_subquery.png) |
| 7 | Поиск фамилии по шаблону | `LIKE` | [07](screenshots/queries/task_07_like.png) |
| 8 | Поиск отсутствующего значения | `IS NULL` | [08](screenshots/queries/task_08_is_null.png) |
| 9 | Статистика по семестрам | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` | [09](screenshots/queries/task_09_aggregate.png) |
| 10 | Отбор сгруппированных данных | `GROUP BY`, `HAVING` | [10](screenshots/queries/task_10_group_by_having.png) |
| 11 | Соединение студентов и групп | `INNER JOIN` | [11](screenshots/queries/task_11_inner_join.png) |
| 12 | Уникальные учебные группы | `DISTINCT` | [12](screenshots/queries/task_12_distinct.png) |
| 13 | Преподаватели, у которых есть курсы | `EXISTS` | [13](screenshots/queries/task_13_exists.png) |
| 14 | Условная классификация результатов | `CASE WHEN ... THEN ... ELSE ... END` | [14](screenshots/queries/task_14_case.png) |

### Индивидуальная часть — вариант №13

1. **Получить список объектов, для которых существует хотя бы одна связанная запись в другой таблице.** Реализация: найти студентов, у которых есть хотя бы один результат контроля (`EXISTS`). [Скриншот](screenshots/queries/variant_13_task_01_exists.png).
2. **Определить категории, для которых отсутствуют связанные объекты.** В данной предметной области в качестве категорий рассматриваются учебные группы: найти группы без студентов (`NOT EXISTS`). [Скриншот](screenshots/queries/variant_13_task_02_not_exists.png).

Все запросы находятся в одном файле: **[LR2_part1_queries.sql](queries/LR2_part1_queries.sql)**.

## Запуск в DBeaver

1. Клонировать репозиторий:

   ```bash
   git clone https://github.com/gregkorneev-BMSTU/Data-Models_Lab2.1.git
   ```

2. Создать в DBeaver подключение **SQLite**, выбрав файл `database/LR1_part2.sqlite` **из склонированного репозитория**.
3. Открыть [`queries/LR2_part1_queries.sql`](queries/LR2_part1_queries.sql) и выбрать подключение к этой базе.
4. Выполнять нужный `SELECT` (в DBeaver — **Execute SQL Statement**, `Ctrl+Enter` / `Cmd+Enter` в зависимости от платформы).
5. Сверить результат со скриншотами в папке [`screenshots/queries/`](screenshots/queries/).

### Тестовые данные

В репозитории уже хранится база, использованная при выполнении запросов. Файл [`database/LR2_part1_seed.sql`](database/LR2_part1_seed.sql) служит для **воспроизведения тестового наполнения** на исходной базе из ЛР №1.2. При необходимости его следует выполнять целиком на резервной копии базы, а не повторно запускать команды `CREATE TABLE` из DDL поверх существующих таблиц.

Для проверки ссылочной целостности можно выполнить:

```sql
PRAGMA foreign_keys = ON;
PRAGMA foreign_key_check;
```

При отсутствии нарушений `PRAGMA foreign_key_check` возвращает **0 строк**.

## Результат

Подготовлены и проверены в DBeaver **16 SELECT-запросов**: 14 общих заданий по методичке и 2 задания варианта №13. SQL-код и скриншоты выполнения сохранены в репозитории.

**Отчёт:** [ЛР2_ч1_КорнеевГИ_ИУ5-34Б.docx](report/ЛР2_ч1_КорнеевГИ_ИУ5-34Б.docx) — итоговый Word-документ по образцу отчёта, включающий титульный лист, 14 общих заданий, 2 задания варианта №13 и вывод.
