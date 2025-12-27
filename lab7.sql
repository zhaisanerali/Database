
-- LABWORK 7: SQL Views and Roles 



DROP TABLE IF EXISTS employees, departments, projects CASCADE;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary NUMERIC(10,2),
    dept_id INT REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    budget NUMERIC(12,2),
    dept_id INT REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Almaty'),
(102, 'HR', 'Astana'),
(103, 'Finance', 'Shymkent');

INSERT INTO employees VALUES
(1, 'John Smith', 50000, 101),
(2, 'Jane Doe', 62000, 102),
(3, 'Mike Davis', 48000, 101),
(4, 'Sarah Lee', 70000, 103),
(5, 'Tom Brown', 45000, NULL);

INSERT INTO projects VALUES
(1, 'ERP System', 120000, 101),
(2, 'Recruitment Drive', 40000, 102),
(3, 'Budget Analysis', 90000, 103);

-- ========== PART 2: Creating Basic Views ==========

-- 2.1 Simple View
CREATE OR REPLACE VIEW employee_details AS
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- 2.2 View with Aggregation
CREATE OR REPLACE VIEW dept_statistics AS
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    COALESCE(AVG(e.salary),0) AS avg_salary,
    COALESCE(MAX(e.salary),0) AS max_salary,
    COALESCE(MIN(e.salary),0) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- 2.3 View with Multiple Joins
CREATE OR REPLACE VIEW project_overview AS
SELECT 
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name, d.location;

-- 2.4 View with Filtering
CREATE OR REPLACE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

-- ========== PART 3: Modifying and Managing Views ==========

-- 3.1 Replace View with Salary Grade
CREATE OR REPLACE VIEW employee_details AS
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- 3.2 Rename View
ALTER VIEW high_earners RENAME TO top_performers;

-- 3.3 Drop Temporary View
CREATE VIEW temp_view AS
SELECT emp_name, salary FROM employees WHERE salary < 50000;
DROP VIEW temp_view;

-- ========== PART 4: Updatable Views ==========

-- 4.1 Create Updatable View
CREATE OR REPLACE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

-- 4.2 Update Through View
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

-- 4.3 Insert Through View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

-- 4.4 View with CHECK OPTION
CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Следующая команда должна выдать ошибку (CHECK OPTION)
-- INSERT INTO it_employees VALUES (7, 'Bob Wilson', 103, 60000);

-- ========== PART 5: Materialized Views ==========

-- 5.1 Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT 
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary),0) AS total_salaries,
    COUNT(p.project_id) AS total_projects,
    COALESCE(SUM(p.budget),0) AS total_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

-- 5.2 Refresh Materialized View
INSERT INTO employees VALUES (8, 'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;

-- 5.3 Concurrent Refresh
CREATE UNIQUE INDEX ON dept_summary_mv(dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- 5.4 Materialized View WITH NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT 
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS emp_count
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY p.project_name, p.budget, d.dept_name
WITH NO DATA;

-- Чтобы исправить ошибку при SELECT:
-- REFRESH MATERIALIZED VIEW project_stats_mv;

-- ========== PART 6: Database Roles ==========

-- 6.1 Basic Roles
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user LOGIN PASSWORD 'report456';

-- 6.2 Roles with Attributes
CREATE ROLE db_creator LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user LOGIN SUPERUSER PASSWORD 'admin999';

-- 6.3 Grant Privileges
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- 6.4 Group Roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

-- 6.5 Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- 6.6 Modify Roles
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

-- ========== PART 7: Advanced Role Management ==========

-- 7.1 Role Hierarchies
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- 7.2 Object Ownership
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

-- 7.3 Reassign and Drop Roles
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table(id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

-- 7.4 Row-Level Security with Views
CREATE OR REPLACE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;

CREATE OR REPLACE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

-- ========== PART 8: Practical Scenarios ==========

-- 8.1 Department Dashboard View
CREATE OR REPLACE VIEW dept_dashboard AS
SELECT 
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS employee_count,
    ROUND(COALESCE(AVG(e.salary),0),2) AS avg_salary,
    COUNT(p.project_id) AS active_projects,
    COALESCE(SUM(p.budget),0) AS total_budget,
    ROUND(
        COALESCE(SUM(p.budget),0) / NULLIF(COUNT(e.emp_id),0),
        2
    ) AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
LEFT JOIN projects p ON p.dept_id = d.dept_id
GROUP BY d.dept_name, d.location;

-- 8.2 Audit View
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW high_budget_projects AS
SELECT 
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- 8.3 Access Control System
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;

-- ✅ Конец лабораторной работы №7
