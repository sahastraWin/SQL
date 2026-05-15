-- ============================================================
-- LEVEL 3: AGGREGATE FUNCTIONS & GROUP BY
-- ============================================================
-- Aggregate functions perform calculations on a group of rows
-- and return a single result value.
--
-- Functions covered:
--   COUNT()  - count rows
--   SUM()    - add up values
--   AVG()    - calculate average
--   MAX()    - find the maximum value
--   MIN()    - find the minimum value
--   GROUP BY - group rows with same value
--   HAVING   - filter groups (like WHERE, but for groups)
-- ============================================================

USE LearnSQL;

-- Make sure our tables exist with data from Level 1 & 2
-- (Run Level_1 and Level_2 files first if you haven't already)

-- ============================================================
-- 1. COUNT() - Count the number of rows
-- COUNT(*) counts ALL rows including NULLs
-- COUNT(column) counts only NON-NULL values in that column
-- ============================================================

-- How many employees are there in total?
SELECT COUNT(*) AS TotalEmployees FROM Employee;

-- How many employees have a country listed? (ignores NULL)
SELECT COUNT(Country) AS EmployeesWithCountry FROM Employee;

-- How many DISTINCT countries do we have?
SELECT COUNT(DISTINCT Country) AS UniqueCountries FROM Employee;

-- How many employees have first name starting with 'M'?
SELECT COUNT(*) AS StartsWithM
FROM Employee
WHERE FirstName LIKE 'M%';

-- ============================================================
-- 2. SUM() - Add up numeric values
-- ============================================================

-- What is the total payroll (sum of all salaries)?
SELECT SUM(Salary) AS TotalPayroll FROM EmployeeSalary;

-- Total salary of only Salesmen
SELECT SUM(Salary) AS SalesmanPayroll
FROM EmployeeSalary
WHERE JobTitle = 'Salesman';

-- ============================================================
-- 3. AVG() - Calculate the average
-- ============================================================

-- What is the average salary?
SELECT AVG(Salary) AS AverageSalary FROM EmployeeSalary;

-- Average age of employees
SELECT AVG(Age) AS AverageAge FROM Employee;

-- Average salary of Accountants
SELECT AVG(Salary) AS AvgAccountantSalary
FROM EmployeeSalary
WHERE JobTitle = 'Accountant';

-- ============================================================
-- 4. MAX() and MIN() - Find highest and lowest values
-- ============================================================

-- Highest salary
SELECT MAX(Salary) AS HighestSalary FROM EmployeeSalary;

-- Lowest salary (ignores NULLs automatically)
SELECT MIN(Salary) AS LowestSalary FROM EmployeeSalary;

-- Oldest and youngest employee
SELECT MAX(Age) AS OldestAge, MIN(Age) AS YoungestAge FROM Employee;

-- ============================================================
-- 5. GROUP BY - Group rows with the same value
-- GROUP BY is used WITH aggregate functions to calculate
-- per-group summaries (e.g., average salary per job title)
-- ============================================================

-- Count employees per country
SELECT Country, COUNT(*) AS NumberOfEmployees
FROM Employee
GROUP BY Country;

-- Average salary per job title
SELECT JobTitle, AVG(Salary) AS AvgSalary
FROM EmployeeSalary
GROUP BY JobTitle;

-- Total salary cost per job title
SELECT JobTitle, SUM(Salary) AS TotalSalaryCost, COUNT(*) AS NumberOfPeople
FROM EmployeeSalary
GROUP BY JobTitle;

-- Count employees by gender
SELECT Gender, COUNT(*) AS Count
FROM Employee
GROUP BY Gender;

-- Max and Min salary per job title
SELECT JobTitle, MAX(Salary) AS MaxSalary, MIN(Salary) AS MinSalary
FROM EmployeeSalary
GROUP BY JobTitle;

-- ============================================================
-- 6. HAVING - Filter groups (like WHERE but for aggregates)
-- 
-- IMPORTANT DIFFERENCE:
--   WHERE  filters individual ROWS (before grouping)
--   HAVING filters GROUPS (after grouping)
-- You CANNOT use aggregate functions in WHERE clause.
-- ============================================================

-- Show only job titles with MORE than 1 employee
SELECT JobTitle, COUNT(*) AS NumberOfEmployees
FROM EmployeeSalary
GROUP BY JobTitle
HAVING COUNT(*) > 1;

-- Show job titles where AVERAGE salary is above 45000
SELECT JobTitle, AVG(Salary) AS AvgSalary
FROM EmployeeSalary
GROUP BY JobTitle
HAVING AVG(Salary) > 45000
ORDER BY AVG(Salary);

-- Show countries with more than 1 employee
SELECT Country, COUNT(*) AS EmployeeCount
FROM Employee
WHERE Country IS NOT NULL      -- WHERE filters rows first
GROUP BY Country
HAVING COUNT(*) > 1;           -- HAVING filters groups after

-- ============================================================
-- 7. AS - Aliasing (giving columns/tables temporary names)
-- Aliases make results easier to read
-- ============================================================

-- Without alias (column name is ugly: AVG(Salary))
SELECT AVG(Salary) FROM EmployeeSalary;

-- With alias (column name is clean: AverageSalary)
SELECT AVG(Salary) AS AverageSalary FROM EmployeeSalary;

-- Alias a table name too (shortens code)
SELECT e.FirstName, e.LastName, es.JobTitle, es.Salary
FROM Employee e
JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID;

-- ============================================================
-- 8. Combining Everything: Multi-level aggregation example
-- ============================================================

-- Per job title: how many people, total salary, avg salary, max, min
-- Only show groups with avg salary > 40000
-- Sort by avg salary descending
SELECT
    JobTitle,
    COUNT(*)        AS NumberOfPeople,
    SUM(Salary)     AS TotalSalary,
    AVG(Salary)     AS AvgSalary,
    MAX(Salary)     AS MaxSalary,
    MIN(Salary)     AS MinSalary
FROM EmployeeSalary
WHERE Salary IS NOT NULL         -- exclude NULLs before grouping
GROUP BY JobTitle
HAVING AVG(Salary) > 40000
ORDER BY AvgSalary DESC;

-- ============================================================
-- 9. CASE Statement - Conditional logic inside SELECT
-- Works like IF-THEN-ELSE
-- ============================================================

-- Categorize employees by age group
SELECT
    FirstName,
    LastName,
    Age,
    CASE
        WHEN Age > 50              THEN 'Senior'
        WHEN Age BETWEEN 35 AND 50 THEN 'Mid-Level'
        WHEN Age BETWEEN 25 AND 34 THEN 'Junior'
        ELSE                            'Entry Level'
    END AS AgeGroup
FROM Employee
WHERE Age IS NOT NULL
ORDER BY Age;

-- Calculate raise amount based on job title
SELECT
    es.JobTitle,
    es.Salary,
    CASE
        WHEN es.JobTitle = 'Regional Manager' THEN es.Salary * 1.10  -- 10% raise
        WHEN es.JobTitle = 'Salesman'         THEN es.Salary * 1.08  -- 8% raise
        WHEN es.JobTitle = 'Accountant'       THEN es.Salary * 1.05  -- 5% raise
        ELSE                                       es.Salary * 1.03  -- 3% for others
    END AS SalaryAfterRaise
FROM EmployeeSalary es
WHERE es.Salary IS NOT NULL;
