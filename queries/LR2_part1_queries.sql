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


-- Проверка количества записей во всех таблицах
SELECT 'study_group' AS table_name, COUNT(*) AS row_count FROM study_group
UNION ALL
SELECT 'student', COUNT(*) FROM student
UNION ALL
SELECT 'teacher', COUNT(*) FROM teacher
UNION ALL
SELECT 'discipline', COUNT(*) FROM discipline
UNION ALL
SELECT 'discipline_course', COUNT(*) FROM discipline_course
UNION ALL
SELECT 'discipline_teacher', COUNT(*) FROM discipline_teacher
UNION ALL
SELECT 'lesson', COUNT(*) FROM lesson
UNION ALL
SELECT 'control_result', COUNT(*) FROM control_result;


