-- ==========================
-- Lab 2: Advanced DDL Operations
-- ==========================

-- ==========================
-- Part 1: Database Creation
-- ==========================

-- Создаём основные базы данных
CREATE DATABASE university_main
WITH OWNER = current_user
TEMPLATE = template0
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;

CREATE DATABASE university_archive
WITH OWNER = current_user
TEMPLATE = template0
ENCODING = 'UTF8'
CONNECTION LIMIT = 50;

CREATE DATABASE university_test
WITH OWNER = current_user
TEMPLATE = template0
ENCODING = 'UTF8'
IS_TEMPLATE = TRUE
CONNECTION LIMIT = 10;

-- ==========================
-- Part 1.2: Tablespace Creation
-- ==========================

CREATE TABLESPACE student_data LOCATION '"C:\pg_tablespaces\students"';
CREATE TABLESPACE course_data LOCATION '"C:\pg_tablespaces\courses"' OWNER current_user;

CREATE DATABASE university_distributed
WITH OWNER = current_user
TEMPLATE = template0
ENCODING = 'LATIN9'
TABLESPACE = student_data
CONNECTION LIMIT = -1;

-- ==========================
-- Part 2: Table Creation
-- ==========================

-- Таблица студентов
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(30),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(4,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT FALSE,
    graduation_year SMALLINT,
    student_status VARCHAR(20) DEFAULT 'ACTIVE',
    advisor_id INTEGER
);

-- Таблица преподавателей
CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12,2),
    is_tenured BOOLEAN DEFAULT FALSE,
    years_experience SMALLINT,
    department_code CHAR(5),
    research_area TEXT,
    last_promotion_date DATE,
    department_id INTEGER
);

-- Таблица курсов
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(10),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT DEFAULT 3,
    max_enrollment INTEGER,
    course_fee NUMERIC(8,2),
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    prerequisite_course_id INTEGER,
    difficulty_level SMALLINT,
    lab_required BOOLEAN DEFAULT FALSE,
    department_id INTEGER
);

-- Таблица расписания занятий
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(30),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    session_type VARCHAR(15),
    room_capacity INTEGER,
    equipment_needed TEXT
);

-- Таблица записей студентов
CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(student_id),
    course_id INTEGER NOT NULL REFERENCES courses(course_id),
    semester VARCHAR(20) NOT NULL,
    year INTEGER NOT NULL,
    grade VARCHAR(5),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    extra_credit_points NUMERIC(3,1) DEFAULT 0.0,
    final_exam_date DATE
);

-- ==========================
-- Part 4: Supporting Tables
-- ==========================

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget NUMERIC(12,2),
    established_year INTEGER
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price NUMERIC(8,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMERIC(6,2),
    loan_status VARCHAR(20)
);

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points NUMERIC(3,2),
    description TEXT
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN DEFAULT FALSE
);

-- ==========================
-- Part 5: Cleanup
-- ==========================

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;
DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points NUMERIC(3,2),
    description TEXT
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN DEFAULT FALSE
);

DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
WITH TEMPLATE = university_main
OWNER = current_user
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;
