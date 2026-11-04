
-- Задание 1. Выборка всех записей из таблицы
SELECT *
FROM student;

-- Задание 2. Выборка отдельных столбцов
SELECT surname, first_name, group_number
FROM student;

-- Задание 3. Сортировка дисциплин по названию
SELECT discipline_id, discipline_name
FROM discipline
ORDER BY discipline_name ASC;

-- Задание 4. Ограничение количества строк
SELECT student_id, surname, first_name
FROM student
ORDER BY student_id
LIMIT 1 OFFSET 0;

-- Задание 5. Фильтрация с WHERE и BETWEEN
SELECT course_id, discipline_id, semester, academic_year
FROM discipline_course
WHERE semester BETWEEN 3 AND 5
  AND academic_year = '2026/2027'
ORDER BY semester ASC;



-- Задание 6. IN с подзапросом
SELECT student_id, surname, first_name, group_number
FROM student
WHERE student_id IN (
    SELECT student_id
    FROM control_result
    WHERE grade = '5'
);


-- Задание 7. Поиск по шаблону LIKE
SELECT student_id, surname, first_name, group_number
FROM student
WHERE surname LIKE 'П%';



-- Задание 8. Поиск отсутствующих значений IS NULL
SELECT student_id, surname, first_name, patronymic
FROM student
WHERE patronymic IS NULL;



-- Задание 9. Агрегатные функции
SELECT
    COUNT(*) AS total_courses,
    SUM(semester) AS sum_semesters,
    AVG(semester) AS avg_semester,
    MIN(semester) AS min_semester,
    MAX(semester) AS max_semester
FROM discipline_course;



-- Задание 10. Группировка и фильтрация групп
SELECT
    semester,
    COUNT(*) AS course_count
FROM discipline_course
GROUP BY semester
HAVING COUNT(*) > 2
ORDER BY course_count DESC;


-- Задание 11. Соединение таблиц INNER JOIN
SELECT
    s.student_id,
    s.surname,
    s.first_name,
    g.group_number,
    g.admission_year
FROM student AS s
INNER JOIN study_group AS g
    ON s.group_number = g.group_number
ORDER BY g.group_number, s.surname;



-- Задание 12. Выборка уникальных значений DISTINCT
SELECT DISTINCT group_number
FROM student
ORDER BY group_number;



-- Задание 13. Проверка существования связанных записей EXISTS
SELECT
    t.teacher_id,
    t.surname,
    t.first_name,
    t.position
FROM teacher AS t
WHERE EXISTS (
    SELECT 1
    FROM discipline_course AS dc
    WHERE dc.teacher_id = t.teacher_id
)
ORDER BY t.teacher_id;


-- Задание 14. Условный вывод с CASE
SELECT
    result_id,
    student_id,
    grade,
    CASE
        WHEN grade IN ('4', '5', 'зачтено') THEN 'Успешно'
        WHEN grade IN ('2', '3', 'не зачтено') THEN 'Требует улучшения'
        ELSE 'Нет оценки'
    END AS result_status
FROM control_result
ORDER BY result_id;


-- Вариант 13. Задание 1.
-- Студенты, имеющие хотя бы один результат контроля
SELECT
    s.student_id,
    s.surname,
    s.first_name,
    s.group_number
FROM student AS s
WHERE EXISTS (
    SELECT 1
    FROM control_result AS cr
    WHERE cr.student_id = s.student_id
)
ORDER BY s.student_id;



-- Вариант 13. Задание 2.
-- Учебные группы, в которых отсутствуют студенты
SELECT
    g.group_number,
    g.admission_year
FROM study_group AS g
WHERE NOT EXISTS (
    SELECT 1
    FROM student AS s
    WHERE s.group_number = g.group_number
)
ORDER BY g.group_number;

