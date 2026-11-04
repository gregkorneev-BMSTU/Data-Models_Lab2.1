
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
