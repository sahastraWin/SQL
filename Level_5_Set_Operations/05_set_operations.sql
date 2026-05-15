-- ============================================================
-- LEVEL 5: SET OPERATIONS
-- ============================================================
-- Set operations combine results from TWO SELECT statements.
-- Both SELECT statements must have:
--   1. The SAME number of columns
--   2. Columns with COMPATIBLE data types
--
-- Operations covered:
--   1. UNION     - combine results, remove duplicates
--   2. UNION ALL - combine results, KEEP duplicates
--   3. INTERSECT - only common rows (MySQL 8.0+)
--   4. EXCEPT    - rows only in first set (MySQL 8.0+)
-- ============================================================

USE LearnSQL;

-- ============================================================
-- SETUP: Two similar customer tables
-- ============================================================

DROP TABLE IF EXISTS Customer_2024;
DROP TABLE IF EXISTS Customer_2023;

CREATE TABLE IF NOT EXISTS Customer_2024 (
    CustomerID  INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(30),
    LastName    VARCHAR(30),
    Country     VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Customer_2023 (
    CustomerID  INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(30),
    LastName    VARCHAR(30),
    Country     VARCHAR(50)
);

-- 2024 customers
INSERT INTO Customer_2024 (FirstName, LastName, Country) VALUES
    ('Alice',   'Brown',   'USA'),
    ('Bob',     'Smith',   'UK'),
    ('Carol',   'Johnson', 'USA'),
    ('David',   'Wilson',  'Canada'),
    ('Emma',    'Davis',   'Australia');   -- New in 2024 only

-- 2023 customers (some same, some different)
INSERT INTO Customer_2023 (FirstName, LastName, Country) VALUES
    ('Alice',   'Brown',   'USA'),     -- Same as 2024
    ('Bob',     'Smith',   'UK'),      -- Same as 2024
    ('Carol',   'Johnson', 'USA'),     -- Same as 2024
    ('Frank',   'Taylor',  'USA'),     -- 2023 only, not in 2024
    ('Grace',   'Anderson','Japan');   -- 2023 only, not in 2024

-- View both tables
SELECT * FROM Customer_2024;
SELECT * FROM Customer_2023;

-- ============================================================
-- 1. UNION - Combine results and REMOVE duplicates
-- Like a Venn diagram: all unique values from both circles
-- ============================================================

-- All unique customers across BOTH years (no duplicates)
SELECT FirstName, LastName, Country FROM Customer_2024
UNION
SELECT FirstName, LastName, Country FROM Customer_2023
ORDER BY LastName;

-- ============================================================
-- 2. UNION ALL - Combine results and KEEP duplicates
-- Faster than UNION because it doesn't check for duplicates
-- Use UNION ALL when you KNOW data is distinct, or want all rows
-- ============================================================

-- All customers from both years INCLUDING duplicates
-- (Alice, Bob, Carol will appear TWICE)
SELECT FirstName, LastName, Country FROM Customer_2024
UNION ALL
SELECT FirstName, LastName, Country FROM Customer_2023
ORDER BY LastName;

-- Practical use: combining sales from different regions into one result
-- (Even if the same sale appears in both tables, we want all rows)

-- ============================================================
-- 3. INTERSECT - Only rows common to BOTH queries
-- MySQL 8.0+ supports this natively.
-- ============================================================

-- Customers who appear in BOTH 2024 AND 2023 (returning customers)
SELECT FirstName, LastName FROM Customer_2024
INTERSECT
SELECT FirstName, LastName FROM Customer_2023;

-- Alternative using INNER JOIN (works on all MySQL versions):
SELECT DISTINCT c24.FirstName, c24.LastName
FROM Customer_2024 c24
INNER JOIN Customer_2023 c23
    ON c24.FirstName = c23.FirstName
    AND c24.LastName = c23.LastName;

-- ============================================================
-- 4. EXCEPT (or MINUS in some databases)
-- Returns rows from FIRST query that do NOT appear in SECOND.
-- MySQL 8.0+ supports EXCEPT.
-- ============================================================

-- Customers in 2024 but NOT in 2023 (brand new customers)
SELECT FirstName, LastName FROM Customer_2024
EXCEPT
SELECT FirstName, LastName FROM Customer_2023;

-- Customers in 2023 but NOT in 2024 (lost customers / churned)
SELECT FirstName, LastName FROM Customer_2023
EXCEPT
SELECT FirstName, LastName FROM Customer_2024;

-- Alternative using LEFT JOIN + NULL check (works on all MySQL versions):
-- New 2024 customers (not in 2023)
SELECT c24.FirstName, c24.LastName
FROM Customer_2024 c24
LEFT JOIN Customer_2023 c23
    ON c24.FirstName = c23.FirstName
    AND c24.LastName = c23.LastName
WHERE c23.FirstName IS NULL;  -- No match in 2023 means they're new

-- ============================================================
-- 5. PRACTICAL EXAMPLES
-- ============================================================

-- Combine employee names and customer names into one list
-- (Useful for sending newsletters to all people in the system)
SELECT FirstName, LastName, 'Employee' AS PersonType FROM Employee
UNION
SELECT FirstName, LastName, 'Customer 2024' AS PersonType FROM Customer_2024
ORDER BY LastName;

-- Count total unique people using UNION
SELECT COUNT(*) AS TotalUniquePeople FROM (
    SELECT FirstName, LastName FROM Employee
    UNION
    SELECT FirstName, LastName FROM Customer_2024
) AS CombinedPeople;

-- ============================================================
-- SUMMARY TABLE: Comparing Set Operations
-- ============================================================
--
--  Operation   | Duplicates | Result
--  ------------|------------|---------------------------------------
--  UNION       | Removed    | All unique rows from both queries
--  UNION ALL   | Kept       | All rows from both queries (inc. dups)
--  INTERSECT   | Removed    | Only rows in BOTH queries
--  EXCEPT      | Removed    | Rows in first query NOT in second
--
-- ============================================================
