PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- 1. Учебные группы. Группа ИУ5-99Б специально оставлена без студентов.
INSERT INTO study_group (group_number, admission_year) VALUES
    ('ИУ5-42Б', 2024),
    ('ИУ5-52Б', 2025),
    ('ИУ5-99Б', 2026)
ON CONFLICT(group_number) DO NOTHING;

-- 2. Преподаватели.
INSERT INTO teacher (teacher_id, surname, first_name, patronymic, position) VALUES
    (101, 'Иванов', 'Алексей', 'Петрович', 'доцент'),
    (102, 'Смирнова', 'Елена', 'Сергеевна', 'старший преподаватель'),
    (103, 'Кузнецов', 'Дмитрий', 'Викторович', 'профессор')
ON CONFLICT(teacher_id) DO NOTHING;

-- 3. Дисциплины. Дисциплина 104 пока не включена в курсы.
INSERT INTO discipline (discipline_id, discipline_name) VALUES
    (101, 'Базы данных'),
    (102, 'Алгоритмы и структуры данных'),
    (103, 'Теория вероятностей'),
    (104, 'Информационная безопасность')
ON CONFLICT(discipline_id) DO NOTHING;

-- 4. Студенты.
INSERT INTO student (
    student_id, surname, first_name, patronymic, birth_date, email, group_number
) VALUES
    (101, 'Петров', 'Артём', 'Олегович', '2005-04-11', 'artem.petrov@example.test', 'ИУ5-42Б'),
    (102, 'Сидорова', 'Мария', 'Игоревна', '2005-08-29', 'maria.sidorova@example.test', 'ИУ5-42Б'),
    (103, 'Васильев', 'Никита', 'Андреевич', '2006-02-08', 'nikita.vasiliev@example.test', 'ИУ5-52Б'),
    (104, 'Фёдорова', 'Ольга', 'Павловна', '2006-11-17', 'olga.fedorova@example.test', 'ИУ5-52Б'),
    (105, 'Михайлов', 'Кирилл', 'Ильич', '2004-12-21', 'kirill.mikhailov@example.test', 'ИУ5-42Б'),
    (106, 'Орлова', 'Алина', 'Витальевна', '2006-04-03', 'alina.orlova@example.test', 'ИУ5-52Б')
ON CONFLICT(student_id) DO NOTHING;

-- 5. Соответствия дисциплин и преподавателей.
INSERT INTO discipline_teacher (discipline_id, teacher_id) VALUES
    (101, 101),
    (102, 102),
    (103, 103),
    (104, 101),
    (101, 103)
ON CONFLICT(discipline_id, teacher_id) DO NOTHING;

-- 6. Курсы дисциплин.
INSERT INTO discipline_course (
    course_id, semester, academic_year, discipline_id, teacher_id, group_number
) VALUES
    (101, 5, '2026/2027', 101, 101, 'ИУ5-42Б'),
    (102, 3, '2026/2027', 102, 102, 'ИУ5-52Б'),
    (103, 5, '2026/2027', 103, 103, 'ИУ5-42Б'),
    (104, 3, '2026/2027', 101, 103, 'ИУ5-52Б')
ON CONFLICT(course_id) DO NOTHING;

-- 7. Занятия.
INSERT INTO lesson (lesson_id, lesson_date, topic, lesson_type, room, course_id) VALUES
    (101, '2026-10-01', 'Введение в базы данных', 'лекция', 'ИУ5-401', 101),
    (102, '2026-10-08', 'Реляционная модель', 'семинар', 'ИУ5-404', 101),
    (103, '2026-10-15', 'SQL: SELECT', 'лабораторная работа', 'ИУ5-402', 101),
    (104, '2026-10-03', 'Сортировки и поиск', 'лекция', 'ИУ5-301', 102),
    (105, '2026-10-10', 'Оценка сложности алгоритмов', 'семинар', 'ИУ5-301', 102),
    (106, '2026-10-07', 'Случайные события', 'лекция', 'ИУ5-205', 103),
    (107, '2026-10-14', 'Вероятностные модели', 'семинар', 'ИУ5-205', 103),
    (108, '2026-10-22', 'SQL: фильтрация', 'лабораторная работа', 'ИУ5-402', 104)
ON CONFLICT(lesson_id) DO NOTHING;

-- 8. Результаты контроля.
INSERT INTO control_result (
    result_id, grade, control_type, control_date, student_id, lesson_id
) VALUES
    (101, '5', 'лабораторная работа', '2026-10-16', 101, 103),
    (102, '4', 'лабораторная работа', '2026-10-16', 102, 103),
    (103, '3', 'контрольная работа', '2026-10-12', 103, 105),
    (104, '5', 'практическая работа', '2026-10-15', 104, 107),
    (105, 'зачтено', 'зачёт', '2026-10-23', 105, 108),
    (106, '4', 'контрольная работа', '2026-10-17', 106, 103),
    (107, '2', 'контрольная работа', '2026-10-17', 103, 104),
    (108, 'не зачтено', 'зачёт', '2026-10-23', 104, 105)
ON CONFLICT(result_id) DO NOTHING;

COMMIT;

-- Проверка ссылочной целостности: при отсутствии проблем возвращает 0 строк.
PRAGMA foreign_key_check;
