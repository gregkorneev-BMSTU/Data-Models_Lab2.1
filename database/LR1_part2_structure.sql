CREATE TABLE "discipline" (
    discipline_id INTEGER NOT NULL,
    discipline_name TEXT NOT NULL,

    CONSTRAINT discipline_pk
        PRIMARY KEY (discipline_id),

    CONSTRAINT discipline_id_check
        CHECK (discipline_id > 0),

    CONSTRAINT discipline_name_check
        CHECK (
            length(trim(discipline_name)) BETWEEN 1 AND 150
        )
);

CREATE TABLE study_group (
    group_number TEXT NOT NULL,
    admission_year INTEGER,

    CONSTRAINT study_group_pk
        PRIMARY KEY (group_number),

    CONSTRAINT study_group_number_check
        CHECK (
            length(trim(group_number)) BETWEEN 1 AND 20
        ),

    CONSTRAINT study_group_year_check
        CHECK (
            admission_year IS NULL
            OR admission_year BETWEEN 1000 AND 9999
        )
);

CREATE TABLE teacher (
    teacher_id INTEGER NOT NULL,
    surname TEXT NOT NULL,
    first_name TEXT NOT NULL,
    patronymic TEXT,
    position TEXT NOT NULL,

    CONSTRAINT teacher_pk
        PRIMARY KEY (teacher_id),

    CONSTRAINT teacher_id_check
        CHECK (teacher_id > 0),

    CONSTRAINT teacher_surname_check
        CHECK (
            length(trim(surname)) BETWEEN 1 AND 50
        ),

    CONSTRAINT teacher_first_name_check
        CHECK (
            length(trim(first_name)) BETWEEN 1 AND 50
        ),

    CONSTRAINT teacher_patronymic_check
        CHECK (
            patronymic IS NULL
            OR length(trim(patronymic)) BETWEEN 1 AND 50
        ),

    CONSTRAINT teacher_position_check
        CHECK (
            length(trim(position)) > 0
        )
);


CREATE TABLE discipline_course (
    course_id INTEGER NOT NULL,
    semester INTEGER,
    academic_year TEXT,

    discipline_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,
    group_number TEXT NOT NULL,

    CONSTRAINT discipline_course_pk
        PRIMARY KEY (course_id),

    CONSTRAINT discipline_course_id_check
        CHECK (course_id > 0),

    CONSTRAINT discipline_course_semester_check
        CHECK (
            semester IS NULL
            OR semester BETWEEN 1 AND 12
        ),

    CONSTRAINT discipline_course_year_check
        CHECK (
            academic_year IS NULL
            OR (
                academic_year GLOB
                '[0-9][0-9][0-9][0-9]/[0-9][0-9][0-9][0-9]'

                AND CAST(substr(academic_year, 6, 4) AS INTEGER)
                    =
                    CAST(substr(academic_year, 1, 4) AS INTEGER) + 1
            )
        ),

    CONSTRAINT discipline_course_discipline_fk
        FOREIGN KEY (discipline_id)
        REFERENCES discipline(discipline_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT discipline_course_teacher_fk
        FOREIGN KEY (teacher_id)
        REFERENCES teacher(teacher_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT discipline_course_group_fk
        FOREIGN KEY (group_number)
        REFERENCES study_group(group_number)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE discipline_teacher (
    discipline_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,

    CONSTRAINT discipline_teacher_pk
        PRIMARY KEY (discipline_id, teacher_id),

    CONSTRAINT discipline_teacher_discipline_fk
        FOREIGN KEY (discipline_id)
        REFERENCES discipline(discipline_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT discipline_teacher_teacher_fk
        FOREIGN KEY (teacher_id)
        REFERENCES teacher(teacher_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE lesson (
    lesson_id INTEGER NOT NULL,
    lesson_date TEXT,
    topic TEXT NOT NULL,
    lesson_type TEXT,
    room TEXT,
    course_id INTEGER NOT NULL,

    CONSTRAINT lesson_pk
        PRIMARY KEY (lesson_id),

    CONSTRAINT lesson_id_check
        CHECK (lesson_id > 0),

    CONSTRAINT lesson_date_check
        CHECK (
            lesson_date IS NULL
            OR (
                date(lesson_date) IS NOT NULL
                AND date(lesson_date) = lesson_date
            )
        ),

    CONSTRAINT lesson_topic_check
        CHECK (
            length(trim(topic)) BETWEEN 1 AND 200
        ),

    CONSTRAINT lesson_type_check
        CHECK (
            lesson_type IS NULL
            OR lesson_type IN (
                'лекция',
                'семинар',
                'лабораторная работа'
            )
        ),

    CONSTRAINT lesson_room_check
        CHECK (
            room IS NULL
            OR length(room) <= 30
        ),

    CONSTRAINT lesson_course_fk
        FOREIGN KEY (course_id)
        REFERENCES discipline_course(course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE student (
    student_id INTEGER NOT NULL,
    surname TEXT NOT NULL,
    first_name TEXT NOT NULL,
    patronymic TEXT,
    birth_date TEXT,
    email TEXT,
    group_number TEXT NOT NULL,

    CONSTRAINT student_pk
        PRIMARY KEY (student_id),

    CONSTRAINT student_id_check
        CHECK (student_id > 0),

    CONSTRAINT student_surname_check
        CHECK (
            length(trim(surname)) BETWEEN 1 AND 50
        ),

    CONSTRAINT student_first_name_check
        CHECK (
            length(trim(first_name)) BETWEEN 1 AND 50
        ),

    CONSTRAINT student_patronymic_check
        CHECK (
            patronymic IS NULL
            OR length(trim(patronymic)) BETWEEN 1 AND 50
        ),

    CONSTRAINT student_birth_date_check
        CHECK (
            birth_date IS NULL
            OR (
                date(birth_date) IS NOT NULL
                AND date(birth_date) = birth_date
            )
        ),

    CONSTRAINT student_email_unique
        UNIQUE (email),

    CONSTRAINT student_group_fk
        FOREIGN KEY (group_number)
        REFERENCES study_group(group_number)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE control_result (
    result_id INTEGER NOT NULL,
    grade TEXT,
    control_type TEXT NOT NULL,
    control_date TEXT DEFAULT CURRENT_DATE,

    student_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,

    CONSTRAINT control_result_pk
        PRIMARY KEY (result_id),

    CONSTRAINT control_result_id_check
        CHECK (result_id > 0),

    CONSTRAINT control_result_grade_check
        CHECK (
            grade IS NULL
            OR grade IN (
                '2',
                '3',
                '4',
                '5',
                'зачтено',
                'не зачтено'
            )
        ),

    CONSTRAINT control_result_type_check
        CHECK (
            length(trim(control_type)) > 0
        ),

    CONSTRAINT control_result_date_check
        CHECK (
            control_date IS NULL
            OR (
                date(control_date) IS NOT NULL
                AND date(control_date) = control_date
            )
        ),

    CONSTRAINT control_result_student_fk
        FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT control_result_lesson_fk
        FOREIGN KEY (lesson_id)
        REFERENCES lesson(lesson_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
