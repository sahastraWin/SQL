-- ============================================================
-- LEVEL 7: VIEWS & TEMPORARY TABLES
-- ============================================================
-- Topics covered:
--   1. VIEW        - virtual table based on a SELECT query
--   2. TEMP TABLE  - real table that lives temporarily
--   3. Differences between View vs Temp Table vs CTE
-- ============================================================

USE LearnSQL;

-- ============================================================
-- 1. VIEW - A Virtual Table
--
-- A VIEW is a saved SELECT query that looks and behaves like a table.
-- It does NOT store data itself — it always shows LIVE data from
-- the underlying tables.
-- When the base table changes, the view reflects that change.
--
-- USE CASES:
--   - Simplify complex queries you run often
--   - Show only certain columns to certain users (security)
--   - Provide a stable interface even if table structure changes
-- ============================================================

-- Create a view combining Customer, Sale, and Inventory
CREATE OR REPLACE VIEW CustomerSalesView AS
SELECT
    s.SaleID,
    s.SaleDate,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    es.JobTitle,
    i.InventoryName,
    s.SaleQuantity,
    s.SaleUnitPrice,
    (s.SaleQuantity * s.SaleUnitPrice)   AS TotalAmount
FROM Sale s
INNER JOIN Employee  e  ON s.EmployeeID  = e.EmployeeID
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
INNER JOIN Inventory i  ON s.InventoryID = i.InventoryID;

-- Use the view just like a regular table!
SELECT * FROM CustomerSalesView;

-- Filter the view
SELECT * FROM CustomerSalesView WHERE TotalAmount > 100;

-- Sort the view
SELECT * FROM CustomerSalesView ORDER BY SaleDate DESC;

-- --------------------------------------------------------
-- Create another view: Employee salary summary
-- --------------------------------------------------------
CREATE OR REPLACE VIEW EmployeeSalarySummary AS
SELECT
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    e.Gender,
    e.Country,
    es.JobTitle,
    es.Salary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID;

-- Use this view
SELECT * FROM EmployeeSalarySummary;
SELECT * FROM EmployeeSalarySummary WHERE Salary > 45000;
SELECT JobTitle, AVG(Salary) AS AvgSalary FROM EmployeeSalarySummary GROUP BY JobTitle;

-- --------------------------------------------------------
-- View management commands
-- --------------------------------------------------------

-- Show all views in current database
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- See the SQL behind a view
SHOW CREATE VIEW CustomerSalesView;

-- Drop (delete) a view
-- DROP VIEW IF EXISTS CustomerSalesView;

-- ============================================================
-- 2. TEMPORARY TABLE
--
-- A Temp Table is a REAL table that stores actual data,
-- but it only exists during your current session.
-- It disappears when you close the connection.
--
-- USE CASES:
--   - Store intermediate results for complex calculations
--   - Process data in steps before inserting into final table
--   - Better performance for repeated access to the same derived data
--
-- In MySQL: prefix with nothing (just use regular CREATE TABLE
-- with a # sign isn't MySQL style — just use CREATE TEMPORARY TABLE)
-- ============================================================

-- Create a temporary table (auto-deleted when session ends)
DROP TEMPORARY TABLE IF EXISTS TempEmployeeStats;

CREATE TEMPORARY TABLE TempEmployeeStats (
    JobTitle        VARCHAR(100),
    EmployeesPerJob INT,
    AvgAge          DECIMAL(5,1),
    AvgSalary       DECIMAL(10,2)
);

-- Insert data into the temp table
INSERT INTO TempEmployeeStats (JobTitle, EmployeesPerJob, AvgAge, AvgSalary)
SELECT
    es.JobTitle,
    COUNT(e.EmployeeID)  AS EmployeesPerJob,
    AVG(e.Age)           AS AvgAge,
    AVG(es.Salary)       AS AvgSalary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE e.Age IS NOT NULL AND es.Salary IS NOT NULL
GROUP BY es.JobTitle;

-- Use the temp table just like any regular table
SELECT * FROM TempEmployeeStats;

-- Order by average salary
SELECT * FROM TempEmployeeStats ORDER BY AvgSalary DESC;

-- Find jobs with below-average salary
SELECT * FROM TempEmployeeStats
WHERE AvgSalary < (SELECT AVG(AvgSalary) FROM TempEmployeeStats);

-- You can even JOIN temp tables with real tables
SELECT
    tms.JobTitle,
    tms.AvgSalary,
    es.Salary AS IndividualSalary,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName
FROM TempEmployeeStats tms
INNER JOIN EmployeeSalary es ON tms.JobTitle = es.JobTitle
INNER JOIN Employee e ON es.EmployeeID = e.EmployeeID
ORDER BY tms.JobTitle;

-- ============================================================
-- 3. DUPLICATE TABLE (copying data to a new permanent table)
-- Use SELECT ... INTO in SQL Server, or CREATE TABLE ... SELECT in MySQL
-- ============================================================

-- Create a permanent backup/copy of CustomerSalesView data
DROP TABLE IF EXISTS CustomerSalesArchive;

CREATE TABLE CustomerSalesArchive AS
SELECT * FROM CustomerSalesView
ORDER BY SaleDate;

-- Verify it was created with data
SELECT * FROM CustomerSalesArchive;

-- ============================================================
-- 4. COMPARISON: VIEW vs TEMP TABLE vs CTE
--
-- +------------------+----------+-----------+-----------+
-- | Feature          | VIEW     | TEMP TABLE| CTE       |
-- +------------------+----------+-----------+-----------+
-- | Stores data?     | No (live)| Yes       | No (live) |
-- | Persists?        | Yes*     | Session   | Query only|
-- | Indexable?       | No**     | Yes       | No        |
-- | Use in multiple  |          |           |           |
-- |   queries?       | Yes      | Yes       | No***     |
-- | DML operations?  | Limited  | Yes       | No        |
-- +------------------+----------+-----------+-----------+
-- * Views persist until dropped
-- ** Indexed views are possible but complex
-- *** CTE only valid within the single query it's defined in
-- ============================================================

-- ============================================================
-- 5. WHEN TO USE EACH
--
-- USE VIEW when:
--   - You want a reusable, simplified version of complex queries
--   - You need security (hide certain columns)
--   - Data must always be current/live
--
-- USE TEMP TABLE when:
--   - You need to store intermediate results
--   - You'll access the same derived data multiple times
--   - You need to add indexes for performance
--   - Working with very large datasets step-by-step
--
-- USE CTE when:
--   - You want to organize a single complex query
--   - Recursive queries (hierarchies, like org charts)
--   - Making code readable — name sub-parts of a query
-- ============================================================

-- Cleanup: remove the archive table
-- DROP TABLE IF EXISTS CustomerSalesArchive;
