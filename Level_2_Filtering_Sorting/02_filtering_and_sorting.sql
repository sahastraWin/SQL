-- ============================================================
-- LEVEL 2: FILTERING & SORTING DATA
-- ============================================================
-- This file covers how to filter and sort query results:
--   1. WHERE clause with operators
--   2. LIKE (pattern matching)
--   3. IN (multiple values)
--   4. BETWEEN (range)
--   5. IS NULL / IS NOT NULL
--   6. ORDER BY (sorting)
--   7. DISTINCT (unique values)
--   8. LIMIT / TOP (limiting rows)
-- ============================================================

USE LearnSQL;

-- ------------------------------------------------------------
-- SETUP: Create sample tables for practice
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Employee (
    EmployeeID   INT PRIMARY KEY AUTO_INCREMENT,
    FirstName    VARCHAR(30) NOT NULL,
    LastName     VARCHAR(30) NOT NULL,
    Age          INT,
    Gender       VARCHAR(10),
    Country      VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS EmployeeSalary (
    EmployeeID   INT,
    JobTitle     VARCHAR(50),
    Salary       INT,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Insert sample data
INSERT INTO Employee (FirstName, LastName, Age, Gender, Country) VALUES
    ('Jim',      'Halpert',  30, 'Male',   'USA'),
    ('Pam',      'Beasley',  28, 'Female', 'USA'),
    ('Michael',  'Scott',    45, 'Male',   'USA'),
    ('Dwight',   'Schrute',  35, 'Male',   'USA'),
    ('Angela',   'Martin',   32, 'Female', 'UK'),
    ('Kevin',    'Malone',   38, 'Male',   'USA'),
    ('Meredith', 'Palmer',   48, 'Female', 'Canada'),
    ('Stanley',  'Hudson',   55, 'Male',   'USA'),
    ('Ryan',     'Howard',   25, 'Male',   NULL);   -- NULL means no country entered

INSERT INTO EmployeeSalary (EmployeeID, JobTitle, Salary) VALUES
    (1, 'Salesman',          45000),
    (2, 'Receptionist',      36000),
    (3, 'Regional Manager',  65000),
    (4, 'Salesman',          48000),
    (5, 'Accountant',        47000),
    (6, 'Accountant',        42000),
    (7, 'HR',                50000),
    (8, 'Salesman',          43000),
    (9, 'Intern',            NULL); -- NULL salary means not yet assigned

-- ============================================================
-- 1. BASIC WHERE CLAUSE
-- WHERE filters rows based on a condition.
-- ============================================================

-- Get all male employees
SELECT * FROM Employee WHERE Gender = 'Male';

-- Get employees older than 35
SELECT * FROM Employee WHERE Age > 35;

-- Get employees who are NOT from USA
SELECT * FROM Employee WHERE Country <> 'USA';   -- <> means "not equal"
-- Alternative: 
SELECT * FROM Employee WHERE Country != 'USA';

-- Combine conditions with AND (both must be true)
SELECT * FROM Employee WHERE Gender = 'Male' AND Age > 35;

-- Combine conditions with OR (at least one must be true)
SELECT * FROM Employee WHERE Country = 'UK' OR Country = 'Canada';

-- ============================================================
-- 2. LIKE - PATTERN MATCHING
-- % = any number of characters (wildcard)
-- _ = exactly ONE character
-- ============================================================

-- Find employees whose last name STARTS with 'H'
SELECT * FROM Employee WHERE LastName LIKE 'H%';

-- Find employees whose last name ENDS with 'n'
SELECT * FROM Employee WHERE LastName LIKE '%n';

-- Find employees whose last name CONTAINS 'al'
SELECT * FROM Employee WHERE LastName LIKE '%al%';

-- Find employees where last name has exactly 5 characters
SELECT * FROM Employee WHERE LastName LIKE '_____';

-- Find employees where 2nd character of FirstName is 'i'
SELECT * FROM Employee WHERE FirstName LIKE '_i%';

-- ============================================================
-- 3. IN - CHECK AGAINST MULTIPLE VALUES
-- IN is a shortcut for multiple OR conditions
-- ============================================================

-- Get employees from USA, UK, or Canada
SELECT * FROM Employee WHERE Country IN ('USA', 'UK', 'Canada');

-- Get employees NOT from those countries
SELECT * FROM Employee WHERE Country NOT IN ('USA', 'UK', 'Canada');

-- Get employees with job titles of Salesman or Accountant
SELECT * FROM EmployeeSalary WHERE JobTitle IN ('Salesman', 'Accountant');

-- ============================================================
-- 4. BETWEEN - SELECT VALUES IN A RANGE
-- Note: BETWEEN is INCLUSIVE (includes the boundary values)
-- ============================================================

-- Employees aged between 30 and 40 (includes 30 and 40)
SELECT * FROM Employee WHERE Age BETWEEN 30 AND 40;

-- Salaries between 40000 and 50000
SELECT * FROM EmployeeSalary WHERE Salary BETWEEN 40000 AND 50000;

-- Employees NOT in that age range
SELECT * FROM Employee WHERE Age NOT BETWEEN 30 AND 40;

-- ============================================================
-- 5. IS NULL / IS NOT NULL
-- NULL means "no value / unknown". You CANNOT use = NULL.
-- You must use IS NULL or IS NOT NULL.
-- ============================================================

-- Find employees with no country listed
SELECT * FROM Employee WHERE Country IS NULL;

-- Find employees who DO have a country listed
SELECT * FROM Employee WHERE Country IS NOT NULL;

-- Find employees with no salary assigned
SELECT * FROM EmployeeSalary WHERE Salary IS NULL;

-- ============================================================
-- 6. ORDER BY - SORTING RESULTS
-- ASC  = Ascending order (A-Z, 1-9) — this is the DEFAULT
-- DESC = Descending order (Z-A, 9-1)
-- ============================================================

-- Sort by Last Name A to Z (ascending = default)
SELECT * FROM Employee ORDER BY LastName;

-- Sort by Last Name Z to A (descending)
SELECT * FROM Employee ORDER BY LastName DESC;

-- Sort by Age youngest to oldest
SELECT * FROM Employee ORDER BY Age ASC;

-- Sort by multiple columns: first by Gender, then by Age within each gender
SELECT * FROM Employee ORDER BY Gender, Age;

-- Sort salaries from highest to lowest
SELECT * FROM EmployeeSalary ORDER BY Salary DESC;

-- ============================================================
-- 7. DISTINCT - SHOW ONLY UNIQUE VALUES
-- Removes duplicate values from the result
-- ============================================================

-- See all unique countries (no duplicates)
SELECT DISTINCT Country FROM Employee;

-- See all unique job titles
SELECT DISTINCT JobTitle FROM EmployeeSalary;

-- See unique gender values
SELECT DISTINCT Gender FROM Employee;

-- ============================================================
-- 8. LIMIT - RESTRICT NUMBER OF ROWS RETURNED
-- Useful when you only need a few rows from a large table
-- ============================================================

-- Get only the first 3 employees
SELECT * FROM Employee LIMIT 3;

-- Get the top 5 highest-paid employees
SELECT * FROM EmployeeSalary ORDER BY Salary DESC LIMIT 5;

-- OFFSET: Skip rows before starting (useful for pagination)
-- Skip first 2, then show next 3
SELECT * FROM Employee LIMIT 3 OFFSET 2;

-- ============================================================
-- 9. SAVING RESULTS TO A NEW TABLE (SELECT INTO equivalent)
-- In MySQL, use CREATE TABLE ... SELECT
-- ============================================================

-- Save unique last names into a new table
CREATE TABLE IF NOT EXISTS TempLastNames AS
SELECT DISTINCT LastName FROM Employee ORDER BY LastName;

-- View the new table
SELECT * FROM TempLastNames;

-- ============================================================
-- COMBINED EXAMPLE: Real-world style query
-- Get all male employees from USA aged between 25-40,
-- whose last name contains 'a', sorted by age
-- ============================================================
SELECT FirstName, LastName, Age, Gender, Country
FROM Employee
WHERE Gender = 'Male'
  AND Country = 'USA'
  AND Age BETWEEN 25 AND 40
  AND LastName LIKE '%a%'
ORDER BY Age ASC;
