-- ============================================================
-- LEVEL 6: SUBQUERIES & CTEs (Common Table Expressions)
-- ============================================================
-- A subquery is a query INSIDE another query.
-- A CTE is a named temporary result set (cleaner than subqueries).
--
-- Topics covered:
--   1. Subquery in SELECT
--   2. Subquery in FROM (Derived Table)
--   3. Subquery in WHERE
--   4. Correlated Subquery
--   5. CTE (WITH clause)
--   6. Multiple CTEs
-- ============================================================

USE LearnSQL;

-- ============================================================
-- 1. SUBQUERY IN SELECT CLAUSE
-- The inner query runs once and its result is used as a column value.
-- ============================================================

-- Show each employee's salary AND the company-wide average salary
-- next to each other for easy comparison
SELECT
    e.FirstName,
    e.LastName,
    es.Salary,
    (SELECT AVG(Salary) FROM EmployeeSalary) AS CompanyAvgSalary,
    es.Salary - (SELECT AVG(Salary) FROM EmployeeSalary) AS DiffFromAvg
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary DESC;

-- ============================================================
-- 2. SUBQUERY IN FROM CLAUSE (Derived Table)
-- The inner query creates a temporary table.
-- You MUST give it an alias.
-- ============================================================

-- Find employees earning more than the average salary
-- using a derived table (subquery in FROM)
SELECT emp.FirstName, emp.LastName, emp.Salary, emp.CompanyAvgSalary
FROM (
    -- This inner query becomes a "temporary table" called 'emp'
    SELECT
        e.FirstName,
        e.LastName,
        es.Salary,
        AVG(es.Salary) OVER () AS CompanyAvgSalary  -- Window function (covered in Level 9)
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.Salary IS NOT NULL
) AS emp
WHERE emp.Salary > emp.CompanyAvgSalary
ORDER BY emp.Salary DESC;

-- ============================================================
-- 3. SUBQUERY IN WHERE CLAUSE
-- The inner query returns value(s) used to filter the outer query.
-- ============================================================

-- Find employees who earn the MAX salary
SELECT e.FirstName, e.LastName, es.Salary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary = (SELECT MAX(Salary) FROM EmployeeSalary);

-- Find employees who are older than the AVERAGE age
SELECT FirstName, LastName, Age
FROM Employee
WHERE Age > (SELECT AVG(Age) FROM Employee)
ORDER BY Age DESC;

-- Find employees whose job titles are in a specific group
-- Using IN with a subquery
SELECT e.FirstName, e.LastName, es.JobTitle
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.JobTitle IN (
    -- Inner query: find job titles with average salary above 45000
    SELECT JobTitle
    FROM EmployeeSalary
    GROUP BY JobTitle
    HAVING AVG(Salary) > 45000
);

-- Find employees from countries that appear in both Employee tables
-- (Using subquery with NOT IN)
SELECT FirstName, LastName, Country
FROM Employee
WHERE Country NOT IN (
    SELECT DISTINCT Country
    FROM Customer_2023
    WHERE Country IS NOT NULL
);

-- ============================================================
-- 4. CORRELATED SUBQUERY
-- The inner query references the OUTER query's table.
-- It runs ONCE PER ROW of the outer query (can be slow!).
-- ============================================================

-- Find employees earning more than the AVERAGE salary
-- of their specific job title
SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary > (
    -- This inner query runs for EACH row, using the outer row's JobTitle
    SELECT AVG(es2.Salary)
    FROM EmployeeSalary es2
    WHERE es2.JobTitle = es.JobTitle  -- Reference to outer query!
)
ORDER BY es.JobTitle, es.Salary DESC;

-- EXISTS / NOT EXISTS - Correlated subquery checking existence
-- Find employees who HAVE made a sale
SELECT e.FirstName, e.LastName
FROM Employee e
WHERE EXISTS (
    SELECT 1   -- We just check if any row exists, '1' is just a placeholder
    FROM Sale s
    WHERE s.EmployeeID = e.EmployeeID  -- Correlation: links to outer query
);

-- Find employees who have NOT made any sale
SELECT e.FirstName, e.LastName
FROM Employee e
WHERE NOT EXISTS (
    SELECT 1
    FROM Sale s
    WHERE s.EmployeeID = e.EmployeeID
);

-- ============================================================
-- 5. CTE - Common Table Expression (WITH clause)
-- CTEs are like named subqueries, but written at the TOP.
-- They make complex queries MUCH easier to read and understand.
-- Syntax: WITH cte_name AS (SELECT ...)
-- ============================================================

-- Example 1: Simple CTE - find high earners
WITH HighEarners AS (
    -- Define the CTE: employees with salary > 45000
    SELECT
        e.FirstName,
        e.LastName,
        es.JobTitle,
        es.Salary
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.Salary > 45000
)
-- Use the CTE just like a regular table
SELECT * FROM HighEarners
ORDER BY Salary DESC;

-- Example 2: CTE with gender count analysis
WITH GenderStats AS (
    SELECT
        e.FirstName,
        e.LastName,
        e.Gender,
        es.Salary,
        COUNT(e.Gender) OVER (PARTITION BY e.Gender) AS TotalInGender
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.Salary IS NOT NULL
)
-- Find people in the gender group with the FEWEST members
SELECT FirstName, LastName, Gender, TotalInGender
FROM GenderStats
WHERE TotalInGender = (SELECT MIN(TotalInGender) FROM GenderStats);

-- ============================================================
-- 6. MULTIPLE CTEs
-- You can chain multiple CTEs separated by commas.
-- Each CTE can reference the ones defined before it.
-- ============================================================

WITH
-- CTE 1: Calculate average salary per job title
JobAvgSalary AS (
    SELECT JobTitle, AVG(Salary) AS AvgSalary
    FROM EmployeeSalary
    WHERE Salary IS NOT NULL
    GROUP BY JobTitle
),
-- CTE 2: Find job titles where avg salary exceeds 44000
HighPayingJobs AS (
    SELECT JobTitle, AvgSalary
    FROM JobAvgSalary
    WHERE AvgSalary > 44000
)
-- Final query: list employees in high-paying jobs
SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    hpj.AvgSalary AS JobAverage
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
INNER JOIN HighPayingJobs hpj ON es.JobTitle = hpj.JobTitle
ORDER BY es.Salary DESC;

-- ============================================================
-- COMPARISON: Same query written 3 ways
-- (Subquery vs Derived Table vs CTE)
-- All produce the same result — CTEs are usually most readable
-- ============================================================

-- Goal: Find employees earning above the company average

-- WAY 1: Subquery in WHERE
SELECT e.FirstName, e.LastName, es.Salary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary > (SELECT AVG(Salary) FROM EmployeeSalary)
  AND es.Salary IS NOT NULL;

-- WAY 2: Derived Table (subquery in FROM)
SELECT a.FirstName, a.LastName, a.Salary
FROM (
    SELECT e.FirstName, e.LastName, es.Salary
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.Salary IS NOT NULL
) AS a
WHERE a.Salary > (SELECT AVG(Salary) FROM EmployeeSalary);

-- WAY 3: CTE (most readable for complex logic)
WITH EmployeeData AS (
    SELECT e.FirstName, e.LastName, es.Salary
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.Salary IS NOT NULL
),
CompanyAvg AS (
    SELECT AVG(Salary) AS AvgSalary FROM EmployeeSalary
)
SELECT ed.FirstName, ed.LastName, ed.Salary
FROM EmployeeData ed, CompanyAvg ca
WHERE ed.Salary > ca.AvgSalary;
