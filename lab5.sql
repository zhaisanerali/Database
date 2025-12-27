-- Жайсан, Student ID: [твой ID]

-- Part 1 Task 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES (1, 'John', 'Doe', 30, 2000);
INSERT INTO employees VALUES (2, 'Jane', 'Smith', 45, 3500);
-- INSERT INTO employees VALUES (3, 'Bob', 'Brown', 17, 1000); -- age < 18
-- INSERT INTO employees VALUES (4, 'Alice', 'Green', 70, 3000); -- age > 65
-- INSERT INTO employees VALUES (5, 'Tom', 'White', 25, -500); -- salary <= 0

-- Part 1 Task 1.2
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000, 800);
INSERT INTO products_catalog VALUES (2, 'Phone', 500, 400);
-- INSERT INTO products_catalog VALUES (3, 'Tablet', 300, 350); -- discount_price > regular_price
-- INSERT INTO products_catalog VALUES (4, 'Monitor', -200, 150); -- regular_price <= 0

-- Part 1 Task 1.3
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES (1, '2025-10-01', '2025-10-05', 2);
INSERT INTO bookings VALUES (2, '2025-11-10', '2025-11-15', 4);
-- INSERT INTO bookings VALUES (3, '2025-12-01', '2025-11-30', 2); -- check_out_date <= check_in_date
-- INSERT INTO bookings VALUES (4, '2025-12-05', '2025-12-10', 15); -- num_guests > 10

-- Part 2 Task 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

INSERT INTO customers VALUES (1, 'a@example.com', '123456', '2025-01-01');
INSERT INTO customers VALUES (2, 'b@example.com', NULL, '2025-02-01');
-- INSERT INTO customers VALUES (3, NULL, '7891011', '2025-03-01'); -- email NULL
-- INSERT INTO customers VALUES (4, 'c@example.com', '111222', NULL); -- registration_date NULL

-- Part 2 Task 2.2
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO inventory VALUES (1, 'Pen', 100, 1.5, '2025-10-01 10:00:00');
INSERT INTO inventory VALUES (2, 'Notebook', 50, 2.5, '2025-10-02 11:00:00');
-- INSERT INTO inventory VALUES (3, 'Eraser', -5, 0.5, '2025-10-03 12:00:00'); -- quantity < 0
-- INSERT INTO inventory VALUES (4, 'Marker', 20, -2, '2025-10-04 13:00:00'); -- unit_price <= 0

-- Part 3 Task 3.1
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users VALUES (1, 'user1', 'user1@example.com', '2025-10-01 09:00:00');
INSERT INTO users VALUES (2, 'user2', 'user2@example.com', '2025-10-02 10:00:00');
-- INSERT INTO users VALUES (3, 'user1', 'user3@example.com', '2025-10-03 11:00:00'); -- duplicate username
-- INSERT INTO users VALUES (4, 'user4', 'user2@example.com', '2025-10-04 12:00:00'); -- duplicate email

-- Part 3 Task 3.2
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 101, 'CS101', 'Fall2025');
INSERT INTO course_enrollments VALUES (2, 102, 'CS101', 'Fall2025');
-- INSERT INTO course_enrollments VALUES (3, 101, 'CS101', 'Fall2025'); -- duplicate student-course-semester

-- Part 3 Task 3.3
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username),
    ADD CONSTRAINT unique_email UNIQUE (email);

-- Part 4 Task 4.1
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'HR', 'Building A');
INSERT INTO departments VALUES (2, 'IT', 'Building B');
INSERT INTO departments VALUES (3, 'Finance', 'Building C');
-- INSERT INTO departments VALUES (1, 'Marketing', 'Building D'); -- duplicate dept_id
-- INSERT INTO departments VALUES (NULL, 'Legal', 'Building E'); -- NULL dept_id

-- Part 4 Task 4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (101, 1, '2025-09-01', 'A');
INSERT INTO student_courses VALUES (102, 2, '2025-09-02', 'B');
-- INSERT INTO student_courses VALUES (101, 1, '2025-09-03', 'C'); -- duplicate PK

-- Part 5 Task 5.1
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'John Doe', 1, '2025-01-01');
INSERT INTO employees_dept VALUES (2, 'Jane Smith', 2, '2025-02-01');
-- INSERT INTO employees_dept VALUES (3, 'Bob Brown', 10, '2025-03-01'); -- invalid dept_id

-- Part 5 Task 5.2
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'Author A', 'USA');
INSERT INTO authors VALUES (2, 'Author B', 'UK');
INSERT INTO publishers VALUES (1, 'Publisher A', 'NY');
INSERT INTO publishers VALUES (2, 'Publisher B', 'London');
INSERT INTO books VALUES (1, 'Book A', 1, 1, 2020, 'ISBN001');
INSERT INTO books VALUES (2, 'Book B', 2, 2, 2021, 'ISBN002');
-- INSERT INTO books VALUES (3, 'Book C', 3, 1, 2022, 'ISBN003'); -- invalid author_id
-- INSERT INTO books VALUES (4, 'Book D', 1, 3, 2023, 'ISBN004'); -- invalid publisher_id

-- Part 5 Task 5.3
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Clothing');
INSERT INTO products_fk VALUES (1, 'Laptop', 1);
INSERT INTO products_fk VALUES (2, 'T-shirt', 2);
INSERT INTO orders VALUES (1, '2025-10-01');
INSERT INTO order_items VALUES (1, 1, 1, 1);
INSERT INTO order_items VALUES (2, 1, 2, 2);
-- DELETE FROM categories WHERE category_id = 1; -- should fail (RESTRICT)
-- INSERT INTO order_items VALUES (3, 2, 1, -1); -- invalid quantity

-- Part 6 Task 6.1
CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0),
    stock_quantity INTEGER CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES ecommerce_customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES ecommerce_orders(order_id),
    product_id INTEGER REFERENCES ecommerce_products(product_id),
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC CHECK (unit_price >= 0)
);

INSERT INTO ecommerce_customers VALUES (1, 'Alice', 'alice@example.com', '123456789', '2025-01-01');
INSERT INTO ecommerce_customers VALUES (2, 'Bob', 'bob@example.com', '987654321', '2025-02-01');
INSERT INTO ecommerce_products VALUES (1, 'Laptop', 'Gaming Laptop', 1500, 10);
INSERT INTO ecommerce_products VALUES (2, 'Phone', 'Smartphone', 500, 50);
INSERT INTO ecommerce_orders VALUES (1, 1, '2025-10-01', 1500, 'pending');
INSERT INTO ecommerce_orders VALUES (2, 2, '2025-10-02', 1000, 'processing');
INSERT INTO ecommerce_order_details VALUES (1, 1, 1, 1, 1500);
INSERT INTO ecommerce_order_details VALUES (2, 2, 2, 2, 500);
-- INSERT INTO ecommerce_orders VALUES (3, 1, '2025-10-03', 2000, 'invalid'); -- invalid status
-- INSERT INTO ecommerce_order_details VALUES (3, 1, 1, 0, 1500); -- invalid quantity
