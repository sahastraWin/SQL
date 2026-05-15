-- ============================================================
-- BONUS: PIVOT QUERIES IN MySQL
-- ============================================================
-- A PIVOT rotates rows into columns.
-- Example: Instead of showing each month as a row,
--          you show each month as its OWN COLUMN.
--
-- MySQL does NOT have a built-in PIVOT like SQL Server.
-- We simulate it using CASE + GROUP BY.
--
-- Topics covered:
--   1. Why Pivot? (before vs after)
--   2. Basic Pivot using CASE + GROUP BY
--   3. Pivot with SUM
--   4. Pivot with COUNT
--   5. Multi-level Pivot
-- ============================================================

USE LearnSQL;

-- ============================================================
-- SETUP: Create sales data with months
-- ============================================================

DROP TABLE IF EXISTS MonthlySales;
CREATE TABLE MonthlySales (
    SaleID      INT PRIMARY KEY AUTO_INCREMENT,
    SalesRep    VARCHAR(50),
    Product     VARCHAR(50),
    Month       VARCHAR(20),
    Revenue     DECIMAL(10,2)
);

INSERT INTO MonthlySales (SalesRep, Product, Month, Revenue) VALUES
    ('Jim',    'Paper',  'January',  5000),
    ('Jim',    'Paper',  'February', 4500),
    ('Jim',    'Paper',  'March',    6000),
    ('Jim',    'Ink',    'January',  1200),
    ('Jim',    'Ink',    'February', 900),
    ('Jim',    'Ink',    'March',    1500),
    ('Dwight', 'Paper',  'January',  7000),
    ('Dwight', 'Paper',  'February', 6500),
    ('Dwight', 'Paper',  'March',    8000),
    ('Dwight', 'Beet',   'January',  300),
    ('Dwight', 'Beet',   'February', 450),
    ('Dwight', 'Beet',   'March',    500),
    ('Pam',    'Paper',  'January',  3000),
    ('Pam',    'Paper',  'February', 3200),
    ('Pam',    'Paper',  'March',    2800);

-- ============================================================
-- 1. BEFORE PIVOT - Normal row format (hard to compare months)
-- ============================================================

-- Revenue per sales rep per month (rows stacked)
SELECT SalesRep, Month, SUM(Revenue) AS TotalRevenue
FROM MonthlySales
GROUP BY SalesRep, Month
ORDER BY SalesRep, Month;

-- ============================================================
-- 2. BASIC PIVOT - Using CASE + GROUP BY
-- Each month becomes its OWN COLUMN
-- ============================================================

-- After Pivot: One row per SalesRep, one column per month
SELECT
    SalesRep,
    -- For each month column: sum only the rows where Month matches
    SUM(CASE WHEN Month = 'January'  THEN Revenue ELSE 0 END) AS January,
    SUM(CASE WHEN Month = 'February' THEN Revenue ELSE 0 END) AS February,
    SUM(CASE WHEN Month = 'March'    THEN Revenue ELSE 0 END) AS March,
    -- Grand total for the row
    SUM(Revenue) AS Total
FROM MonthlySales
GROUP BY SalesRep
ORDER BY Total DESC;

-- ============================================================
-- 3. PIVOT WITH SUM - Revenue by Product per Month
-- ============================================================

SELECT
    Product,
    SUM(CASE WHEN Month = 'January'  THEN Revenue ELSE 0 END) AS January,
    SUM(CASE WHEN Month = 'February' THEN Revenue ELSE 0 END) AS February,
    SUM(CASE WHEN Month = 'March'    THEN Revenue ELSE 0 END) AS March,
    SUM(Revenue)                                               AS GrandTotal
FROM MonthlySales
GROUP BY Product
ORDER BY GrandTotal DESC;

-- ============================================================
-- 4. PIVOT WITH COUNT - How many sales per rep per month
-- ============================================================

SELECT
    SalesRep,
    COUNT(CASE WHEN Month = 'January'  THEN 1 END) AS Jan_Sales_Count,
    COUNT(CASE WHEN Month = 'February' THEN 1 END) AS Feb_Sales_Count,
    COUNT(CASE WHEN Month = 'March'    THEN 1 END) AS Mar_Sales_Count,
    COUNT(*)                                        AS Total_Transactions
FROM MonthlySales
GROUP BY SalesRep;

-- ============================================================
-- 5. MULTI-LEVEL PIVOT - Rep + Product as rows, months as columns
-- ============================================================

SELECT
    SalesRep,
    Product,
    SUM(CASE WHEN Month = 'January'  THEN Revenue ELSE 0 END) AS January,
    SUM(CASE WHEN Month = 'February' THEN Revenue ELSE 0 END) AS February,
    SUM(CASE WHEN Month = 'March'    THEN Revenue ELSE 0 END) AS March,
    SUM(Revenue)                                               AS Total
FROM MonthlySales
GROUP BY SalesRep, Product
ORDER BY SalesRep, Total DESC;

-- ============================================================
-- 6. REVERSE PIVOT (UNPIVOT) - Columns back into rows
-- Useful when someone gives you wide spreadsheet data
-- that you need to normalize for analysis
-- ============================================================

-- Suppose we have data stored in wide format (pivoted already)
DROP TABLE IF EXISTS WideSales;
CREATE TABLE WideSales (
    SalesRep VARCHAR(50),
    January  DECIMAL(10,2),
    February DECIMAL(10,2),
    March    DECIMAL(10,2)
);

INSERT INTO WideSales VALUES
    ('Jim',    5000, 4500, 6000),
    ('Dwight', 7000, 6500, 8000),
    ('Pam',    3000, 3200, 2800);

-- UNPIVOT: Convert columns back to rows using UNION ALL
SELECT SalesRep, 'January'  AS Month, January  AS Revenue FROM WideSales
UNION ALL
SELECT SalesRep, 'February' AS Month, February AS Revenue FROM WideSales
UNION ALL
SELECT SalesRep, 'March'    AS Month, March    AS Revenue FROM WideSales
ORDER BY SalesRep, Month;

-- ============================================================
-- 7. PRACTICAL PIVOT: Employee Job Title vs Gender count
-- How many Males/Females in each job?
-- ============================================================

SELECT
    es.JobTitle,
    COUNT(CASE WHEN e.Gender = 'Male'   THEN 1 END) AS Male_Count,
    COUNT(CASE WHEN e.Gender = 'Female' THEN 1 END) AS Female_Count,
    COUNT(*)                                         AS Total_Count
FROM EmployeeSalary es
INNER JOIN Employee e ON es.EmployeeID = e.EmployeeID
GROUP BY es.JobTitle
ORDER BY Total_Count DESC;

-- ============================================================
-- 8. AGGREGATE PIVOT - Salary analysis by Gender and Job Title
-- ============================================================

SELECT
    es.JobTitle,
    AVG(CASE WHEN e.Gender = 'Male'   THEN es.Salary END) AS Avg_Male_Salary,
    AVG(CASE WHEN e.Gender = 'Female' THEN es.Salary END) AS Avg_Female_Salary,
    AVG(es.Salary)                                         AS Overall_Avg_Salary
FROM EmployeeSalary es
INNER JOIN Employee e ON es.EmployeeID = e.EmployeeID
WHERE es.Salary IS NOT NULL
GROUP BY es.JobTitle
ORDER BY Overall_Avg_Salary DESC;
