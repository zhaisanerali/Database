-- lab6_solutions.sql
-- Лабораторная работа №6: SQL JOINы — готовые решения

/* ------------------
   Часть 1: Подготовка базы данных
   ------------------ */

-- Создаём таблицы
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10,2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10,2)
);

-- Добавляем примерные данные
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

/* ------------------
   Часть 2: CROSS JOIN
   ------------------ */

-- Показываем все комбинации сотрудников и отделов
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;

-- Альтернативная запись через запятую
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- Пример с INNER JOIN и условием TRUE
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

-- Все сотрудники со всеми проектами
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;

/* ------------------
   Часть 3: INNER JOIN
   ------------------ */

-- Сотрудники с названиями отделов
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Вариант с USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);

-- NATURAL JOIN — соединение по одинаковым именам колонок
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

-- Соединяем сразу три таблицы
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

/* ------------------
   Часть 4: LEFT JOIN
   ------------------ */

-- Все сотрудники, даже те, у кого нет отдела
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Сокращённая версия с USING
SELECT emp_name, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- Сотрудники без отдела
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Количество сотрудников в каждом отделе (включая отделы без людей)
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

/* ------------------
   Часть 5: RIGHT JOIN
   ------------------ */

-- Все отделы с их сотрудниками (включая пустые)
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- То же самое, только через LEFT JOIN (если поменять порядок)
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;

-- Отделы без сотрудников
SELECT d.dept_name, d.location
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

/* ------------------
   Часть 6: FULL JOIN
   ------------------ */

-- Показываем всех сотрудников и все отделы, даже если не совпали
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

-- Отделы и проекты (включая несвязанные)
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Отдельно выводим записи без пары
SELECT 
    CASE 
        WHEN e.emp_id IS NULL THEN 'Отдел без сотрудников'
        WHEN d.dept_id IS NULL THEN 'Сотрудник без отдела'
        ELSE 'Совпадение'
    END AS status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

/* ------------------
   Часть 7: Разница между ON и WHERE
   ------------------ */

-- Фильтр в ON (оставляет всех сотрудников)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Фильтр в WHERE (исключает тех, у кого нет совпадения)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Для INNER JOIN оба способа дадут одинаковый результат
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

/* ------------------
   Часть 8: Сложные примеры
   ------------------ */

-- Все отделы с сотрудниками и проектами (если есть)
SELECT 
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Добавляем менеджеров (self join)
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id IN (1,2,4,5);
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Средняя зарплата по отделам больше 50 000
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

/* ------------------
   Коротко про JOINы
   ------------------ */
-- INNER JOIN — только совпавшие строки.
-- LEFT JOIN — всё из левой таблицы, справа NULL, если не совпало.
-- RIGHT JOIN — то же, но наоборот.
-- FULL JOIN — всё из обеих таблиц, даже если не совпали.
-- CROSS JOIN — делает все возможные комбинации.
-- NATURAL JOIN — соединяет по столбцам с одинаковыми именами (может быть опасно, если совпадения случайные).

/* ------------------
   Дополнительно (по желанию)
   ------------------ */

-- FULL JOIN через UNION (если в СУБД нет FULL JOIN)
SELECT a.*, b.* FROM A LEFT JOIN B ON A.id = B.id
UNION
SELECT a.*, b.* FROM A RIGHT JOIN B ON A.id = B.id;

-- Сотрудники, работающие в отделах с несколькими проектами
SELECT DISTINCT e.emp_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN (
    SELECT dept_id FROM projects
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
    HAVING COUNT(*) > 1
) multi ON d.dept_id = multi.dept_id;

-- Иерархия сотрудников: кто чей начальник
SELECT e1.emp_name AS employee, m.emp_name AS manager, mm.emp_name AS top_manager
FROM employees e1
LEFT JOIN employees m ON e1.manager_id = m.emp_id
LEFT JOIN employees mm ON m.manager_id = mm.emp_id;

-- Все пары сотрудников из одного отдела
SELECT e1.emp_name AS emp_a, e2.emp_name AS emp_b, e1.dept_id
FROM employees e1
JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id;

-- Конец файла
