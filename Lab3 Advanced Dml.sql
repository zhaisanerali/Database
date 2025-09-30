PART A:


CREATE DATABASE advanced_lab;

-- Employees table
CREATE TABLE employees (
emp_id SERIAL PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
department VARCHAR(100), -- stores dept name (loosely coupled)
salary INTEGER DEFAULT 40000,
hire_date DATE DEFAULT CURRENT_DATE,
status VARCHAR(20) DEFAULT 'Active'
);

-- Departments table
CREATE TABLE departments (
dept_id SERIAL PRIMARY KEY,
dept_name VARCHAR(100) UNIQUE NOT NULL,
budget INTEGER DEFAULT 0,
manager_id INTEGER -- optional FK to employees.emp_id (added after data if desired)
);

-- Projects table
CREATE TABLE projects (
project_id SERIAL PRIMARY KEY,
project_name VARCHAR(150) NOT NULL,
dept_id INTEGER REFERENCES departments(dept_id) ON DELETE SET NULL,
start_date DATE,
end_date DATE,
budget INTEGER DEFAULT 0
);

-- Insert some sample data to test queries
INSERT INTO departments (dept_name, budget) VALUES
('IT', 120000),
('Sales', 90000),
('HR', 50000);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
('Ayan', 'K.', 'IT', 60000, '2019-06-15', 'Active'),
('Madina', 'S.', 'Sales', 45000, '2021-09-10', 'Active'),
('Daniyar', 'T.', 'IT', 80000, '2018-02-01', 'Active'),
('Zhanar', 'B.', 'HR', 38000, '2024-03-21', 'Active'),
('Erbol', 'M.', NULL, NULL, '2024-08-01', 'Inactive');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget) VALUES
('Portal Revamp', 1, '2024-01-01', '2024-06-30', 60000),
('Sales Campaign Q3', 2, '2023-07-01', '2023-10-01', 30000),
('Onboarding Automation', 3, '2022-05-01', '2022-12-01', 20000);











PART B:
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (999, 'Test', 'User', 'IT');



INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Default', 'Salary', 'HR', CURRENT_DATE);




INSERT INTO departments (dept_name, budget)
VALUES ('Marketing', 70000), ('R&D', 150000), ('Support', 40000);




INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Expression', 'Emp', 'IT', (50000 * 1.1)::INTEGER, CURRENT_DATE);




CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';






PART C:




UPDATE employees
SET salary = (salary * 1.10)::INTEGER
WHERE salary IS NOT NULL;




UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';




UPDATE employees
SET department = CASE
WHEN salary > 80000 THEN 'Management'
WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
ELSE 'Junior'
END
WHERE salary IS NOT NULL;


UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = GREATEST(0, (SELECT COALESCE(ROUND(AVG(e.salary) * 1.20), 0) FROM employees e WHERE e.department = d.dept_name))
WHERE EXISTS (SELECT 1 FROM employees e WHERE e.department = d.dept_name);


UPDATE employees
SET salary = (salary * 1.15)::INTEGER,
status = 'Promoted'
WHERE department = 'Sales';



PART D:
DELETE FROM employees WHERE status = 'Terminated';



DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;



DELETE FROM departments
WHERE dept_id NOT IN (
SELECT DISTINCT d.dept_id
FROM departments d
LEFT JOIN employees e ON e.department = d.dept_name
WHERE e.department IS NOT NULL
);



DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;





PART E:



INSERT INTO employees (first_name, last_name, salary, department, hire_date)
VALUES ('Null', 'Fields', NULL, NULL, CURRENT_DATE);




UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;
PART F:

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Return', 'Insert', 'R&D', 55000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;




WITH updated AS (
SELECT emp_id, salary AS old_salary
FROM employees
WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM updated u
WHERE e.emp_id = u.emp_id
RETURNING e.emp_id, u.old_salary, e.salary AS new_salary;



DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;



INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Unique', 'Person', 'Support', 42000
WHERE NOT EXISTS (
SELECT 1 FROM employees e WHERE e.first_name = 'Unique' AND e.last_name = 'Person'
);





UPDATE employees e
SET salary = CASE
WHEN d.budget > 100000 THEN (e.salary * 1.10)::INTEGER
ELSE (e.salary * 1.05)::INTEGER
END
FROM departments d
WHERE e.department = d.dept_name;







INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
('Bulk1','One','Sales',45000,CURRENT_DATE),
('Bulk2','Two','Sales',46000,CURRENT_DATE),
('Bulk3','Three','Sales',47000,CURRENT_DATE),
('Bulk4','Four','Sales',48000,CURRENT_DATE),
('Bulk5','Five','Sales',49000,CURRENT_DATE);



UPDATE employees
SET salary = (salary * 1.10)::INTEGER
WHERE first_name IN ('Bulk1','Bulk2','Bulk3','Bulk4','Bulk5');



CREATE TABLE employee_archive AS TABLE employees WITH NO DATA;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';






UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
FROM departments d
WHERE p.dept_id = d.dept_id
AND p.budget > 50000
AND (
SELECT COUNT(*) FROM employees e WHERE e.department = d.dept_name
) > 3;
