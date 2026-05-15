-- ============================================================
-- LEVEL 10: ADVANCED SQL TOPICS
-- ============================================================
-- Topics covered:
--   1. Stored Procedures
--   2. Data Type Conversion (CAST / CONVERT)
--   3. Date Functions
--   4. ISNULL / COALESCE / NULLIF
--   5. Removing Duplicate Records
--   6. Indexes (concept + syntax)
--   7. Transactions (BEGIN, COMMIT, ROLLBACK)
--   8. Normalization examples
-- ============================================================

USE LearnSQL;

-- ============================================================
-- 1. STORED PROCEDURES
-- A stored procedure is a saved, named SQL block.
-- You write it once and call it many times with EXEC or CALL.
-- It can accept parameters and return results.
-- ============================================================

-- Drop if exists first
DROP PROCEDURE IF EXISTS GetEmployeesByJobTitle;

-- Create a stored procedure that accepts a job title parameter
DELIMITER $$

CREATE PROCEDURE GetEmployeesByJobTitle(
    IN inputJobTitle VARCHAR(100)   -- IN = input parameter
)
BEGIN
    -- This query runs when you CALL the procedure
    SELECT
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        es.JobTitle,
        es.Salary,
        AVG(es.Salary) OVER () AS AvgSalaryAllJobs
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.JobTitle = inputJobTitle
      AND es.Salary IS NOT NULL
    ORDER BY es.Salary DESC;
END$$

DELIMITER ;

-- Call the stored procedure (like running the query)
CALL GetEmployeesByJobTitle('Salesman');
CALL GetEmployeesByJobTitle('Accountant');

-- --------------------------------------------------------
-- Stored Procedure with OUTPUT parameter
-- --------------------------------------------------------
DROP PROCEDURE IF EXISTS GetJobStats;

DELIMITER $$

CREATE PROCEDURE GetJobStats(
    IN  inputJobTitle VARCHAR(100),
    OUT totalCount    INT,
    OUT avgSalary     DECIMAL(10,2)
)
BEGIN
    SELECT COUNT(*), AVG(Salary)
    INTO totalCount, avgSalary      -- Store results in output params
    FROM EmployeeSalary
    WHERE JobTitle = inputJobTitle
      AND Salary IS NOT NULL;
END$$

DELIMITER ;

-- Call it and read the output parameters
CALL GetJobStats('Salesman', @count, @avg);
SELECT @count AS SalesmanCount, @avg AS SalesmanAvgSalary;

-- ============================================================
-- 2. DATA TYPE CONVERSION - CAST and CONVERT
-- ============================================================

-- CAST: convert one data type to another
-- CAST(value AS target_type)
SELECT CAST('2024-03-15' AS DATE)          AS CastedDate;
SELECT CAST(42.7 AS SIGNED)                AS CastedInt;       -- 42 (truncated)
SELECT CAST(42 AS DECIMAL(10,2))           AS CastedDecimal;   -- 42.00
SELECT CAST('123' AS UNSIGNED)             AS CastedNumber;

-- CONVERT: similar to CAST but different syntax
-- CONVERT(value, target_type)
SELECT CONVERT('2024-03-15', DATE)         AS ConvertedDate;
SELECT CONVERT(3.99, SIGNED)               AS ConvertedInt;

-- Practical example: format salary as string for display
SELECT
    e.FirstName,
    es.Salary,
    CONCAT('$', FORMAT(es.Salary, 2))      AS FormattedSalary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL;

-- ============================================================
-- 3. DATE FUNCTIONS
-- ============================================================

-- Get current date and time
SELECT NOW()           AS CurrentDateTime;
SELECT CURDATE()       AS CurrentDate;
SELECT CURTIME()       AS CurrentTime;

-- Extract parts of a date
SELECT
    SaleDate,
    YEAR(SaleDate)     AS SaleYear,
    MONTH(SaleDate)    AS SaleMonth,
    DAY(SaleDate)      AS SaleDay,
    DAYNAME(SaleDate)  AS DayOfWeek,
    MONTHNAME(SaleDate) AS MonthName
FROM Sale
ORDER BY SaleDate;

-- Add/subtract time from dates
SELECT
    SaleDate,
    DATE_ADD(SaleDate, INTERVAL 30 DAY)    AS Plus30Days,
    DATE_ADD(SaleDate, INTERVAL 1 MONTH)   AS NextMonth,
    DATE_ADD(SaleDate, INTERVAL 1 YEAR)    AS NextYear,
    DATE_SUB(SaleDate, INTERVAL 7 DAY)     AS Minus7Days
FROM Sale;

-- Calculate difference between dates
SELECT
    SaleDate,
    CURDATE()                              AS Today,
    DATEDIFF(CURDATE(), SaleDate)          AS DaysSinceSale
FROM Sale;

-- Sales grouped by month (very useful for reports!)
SELECT
    YEAR(SaleDate)   AS SaleYear,
    MONTH(SaleDate)  AS SaleMonth,
    MONTHNAME(SaleDate) AS MonthName,
    COUNT(*)         AS NumberOfSales,
    SUM(SaleQuantity * SaleUnitPrice) AS TotalRevenue
FROM Sale
GROUP BY YEAR(SaleDate), MONTH(SaleDate), MONTHNAME(SaleDate)
ORDER BY SaleYear, SaleMonth;

-- ============================================================
-- 4. ISNULL / COALESCE / NULLIF
-- ============================================================

-- IFNULL(value, default): if value is NULL, return default
SELECT
    e.FirstName,
    e.Country,
    IFNULL(e.Country, 'Unknown')           AS SafeCountry
FROM Employee e;

-- COALESCE: returns FIRST non-null value from the list
SELECT
    e.FirstName,
    e.Country,
    COALESCE(e.Country, 'Not provided', 'N/A') AS DisplayCountry
FROM Employee e;

-- NULLIF(a, b): returns NULL if a = b, otherwise returns a
-- Useful to avoid divide-by-zero errors
SELECT
    100 / NULLIF(0, 0)         AS SafeDivide,  -- Returns NULL instead of error
    100 / NULLIF(5, 0)         AS NormalDivide; -- Returns 20

-- Practical: mark employees with same job title as "N/A" for comparison
SELECT
    es.JobTitle,
    es.Salary,
    NULLIF(es.JobTitle, 'Intern') AS NonInternTitle  -- Returns NULL for Interns
FROM EmployeeSalary es;

-- ============================================================
-- 5. REMOVING DUPLICATE RECORDS
-- Use ROW_NUMBER() to identify duplicates, then delete them
-- ============================================================

-- First, let's create a table with duplicates
DROP TABLE IF EXISTS DuplicateTest;
CREATE TABLE DuplicateTest (
    ID          INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(30),
    LastName    VARCHAR(30),
    Department  VARCHAR(50),
    Salary      INT
);

INSERT INTO DuplicateTest (FirstName, LastName, Department, Salary) VALUES
    ('John', 'Doe',   'IT',      60000),
    ('John', 'Doe',   'IT',      60000),   -- Duplicate!
    ('Jane', 'Smith', 'HR',      50000),
    ('Jane', 'Smith', 'HR',      50000),   -- Duplicate!
    ('Jane', 'Smith', 'HR',      50000),   -- Another duplicate!
    ('Bob',  'Jones', 'Finance', 70000);   -- Unique

SELECT * FROM DuplicateTest;

-- STEP 1: Find duplicates using ROW_NUMBER()
WITH DuplicateFinder AS (
    SELECT
        ID,
        FirstName,
        LastName,
        Department,
        ROW_NUMBER() OVER (
            PARTITION BY FirstName, LastName, Department, Salary
            ORDER BY ID
        ) AS RowNum
        -- RowNum = 1 means FIRST occurrence (keep this)
        -- RowNum > 1 means DUPLICATE (delete these)
    FROM DuplicateTest
)
SELECT * FROM DuplicateFinder ORDER BY LastName, RowNum;

-- STEP 2: Delete the duplicates (rows where RowNum > 1)
-- MySQL workaround for deleting from CTE:
DELETE FROM DuplicateTest
WHERE ID IN (
    SELECT ID FROM (
        SELECT
            ID,
            ROW_NUMBER() OVER (
                PARTITION BY FirstName, LastName, Department, Salary
                ORDER BY ID
            ) AS RowNum
        FROM DuplicateTest
    ) ranked
    WHERE RowNum > 1    -- Delete all but the first occurrence
);

-- STEP 3: Verify duplicates are gone
SELECT * FROM DuplicateTest;

-- ============================================================
-- 6. INDEXES - Speed up queries on large tables
-- An index is like a book's index — helps find data fast.
-- Too many indexes slow down INSERT/UPDATE/DELETE.
-- ============================================================

-- Create a regular (non-clustered) index on LastName
CREATE INDEX idx_employee_lastname ON Employee(LastName);

-- Create a composite index on multiple columns
CREATE INDEX idx_employee_gender_country ON Employee(Gender, Country);

-- Create a UNIQUE index (prevents duplicate values)
CREATE UNIQUE INDEX idx_unique_email ON EmployeeErrors(Email);

-- View all indexes on a table
SHOW INDEX FROM Employee;

-- Drop an index
DROP INDEX idx_employee_lastname ON Employee;

-- ============================================================
-- 7. TRANSACTIONS - Ensuring data integrity
-- A transaction is a group of SQL statements that must ALL succeed
-- or ALL fail together (atomic operation).
--
-- ACID Properties:
--   Atomicity   - all or nothing
--   Consistency - data remains valid
--   Isolation   - transactions don't interfere
--   Durability  - committed data is saved permanently
-- ============================================================

-- EXAMPLE: Transfer salary budget from one employee to another
-- (Either BOTH changes happen, or NEITHER does)

START TRANSACTION;    -- Begin the transaction

    -- Reduce one employee's salary
    UPDATE EmployeeSalary SET Salary = Salary - 5000 WHERE EmployeeID = 3;

    -- Increase another employee's salary
    UPDATE EmployeeSalary SET Salary = Salary + 5000 WHERE EmployeeID = 1;

    -- Check the results before committing
    SELECT EmployeeID, Salary FROM EmployeeSalary WHERE EmployeeID IN (1, 3);

COMMIT;    -- Save the changes permanently

-- ROLLBACK example (undoing changes)
START TRANSACTION;

    -- Make a mistake
    UPDATE EmployeeSalary SET Salary = 0 WHERE EmployeeID = 1;  -- Oops!
    
    -- Check it happened
    SELECT EmployeeID, Salary FROM EmployeeSalary WHERE EmployeeID = 1;

ROLLBACK;   -- Undo everything since START TRANSACTION

-- Verify it was undone
SELECT EmployeeID, Salary FROM EmployeeSalary WHERE EmployeeID = 1;

-- ============================================================
-- 8. NORMALIZATION EXAMPLES
-- Breaking a big flat table into smaller related tables
-- to reduce redundancy and improve data integrity
-- ============================================================

-- BEFORE Normalization (bad - data repeated everywhere):
DROP TABLE IF EXISTS OrdersFlat;
CREATE TABLE OrdersFlat (
    OrderID       INT,
    CustomerName  VARCHAR(50),   -- Repeated for every order!
    CustomerEmail VARCHAR(100),  -- Repeated for every order!
    ProductName   VARCHAR(50),   -- Repeated for every order!
    ProductPrice  DECIMAL(10,2), -- Repeated for every order!
    Quantity      INT,
    OrderDate     DATE
);

INSERT INTO OrdersFlat VALUES
    (1, 'Alice Brown', 'alice@mail.com', 'Laptop',    999.99, 1, '2024-01-01'),
    (2, 'Alice Brown', 'alice@mail.com', 'Mouse',      29.99, 2, '2024-01-05'),
    (3, 'Bob Smith',   'bob@mail.com',   'Laptop',    999.99, 1, '2024-01-10'),
    (4, 'Bob Smith',   'bob@mail.com',   'Keyboard',   79.99, 1, '2024-01-12');

SELECT * FROM OrdersFlat;
-- Problem: If Alice changes email, you'd need to update MULTIPLE rows!

-- AFTER Normalization (better - data stored only once):
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    CustomerID  INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(50),
    CustomerEmail VARCHAR(100) UNIQUE
);

CREATE TABLE Products (
    ProductID   INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(50),
    ProductPrice DECIMAL(10,2)
);

CREATE TABLE Orders (
    OrderID     INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID  INT,
    ProductID   INT,
    Quantity    INT,
    OrderDate   DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID)  REFERENCES Products(ProductID)
);

INSERT INTO Customers (CustomerName, CustomerEmail) VALUES
    ('Alice Brown', 'alice@mail.com'),
    ('Bob Smith',   'bob@mail.com');

INSERT INTO Products (ProductName, ProductPrice) VALUES
    ('Laptop',   999.99),
    ('Mouse',     29.99),
    ('Keyboard',  79.99);

INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderDate) VALUES
    (1, 1, 1, '2024-01-01'),
    (1, 2, 2, '2024-01-05'),
    (2, 1, 1, '2024-01-10'),
    (2, 3, 1, '2024-01-12');

-- Now get all order details using JOIN (same result, better structure!)
SELECT
    o.OrderID,
    c.CustomerName,
    c.CustomerEmail,
    p.ProductName,
    p.ProductPrice,
    o.Quantity,
    (p.ProductPrice * o.Quantity) AS TotalAmount,
    o.OrderDate
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Products  p ON o.ProductID  = p.ProductID
ORDER BY o.OrderDate;

-- Now if Alice changes email, only ONE row needs updating:
-- UPDATE Customers SET CustomerEmail = 'alice.new@mail.com' WHERE CustomerID = 1;

-- ============================================================
-- FINAL: Query Execution Order (how MySQL reads your query)
-- This is the LOGICAL order SQL processes your clauses:
--
-- 1. FROM       → choose table(s)
-- 2. JOIN       → combine tables
-- 3. WHERE      → filter rows (before grouping)
-- 4. GROUP BY   → group rows
-- 5. HAVING     → filter groups (after grouping)
-- 6. SELECT     → choose columns & compute expressions
-- 7. DISTINCT   → remove duplicates
-- 8. ORDER BY   → sort results
-- 9. LIMIT      → restrict number of rows returned
--
-- This is why you CANNOT use a SELECT alias in WHERE:
-- the WHERE runs BEFORE SELECT creates the alias!
-- ============================================================

-- Demonstration of execution order issue:
-- This FAILS because 'HighSalary' alias is created in SELECT
-- but WHERE runs before SELECT:
-- SELECT Salary AS HighSalary FROM EmployeeSalary WHERE HighSalary > 45000;

-- This WORKS - use the original column name in WHERE:
SELECT Salary AS HighSalary FROM EmployeeSalary WHERE Salary > 45000;

-- But aliases ARE allowed in ORDER BY and HAVING
SELECT JobTitle, AVG(Salary) AS AvgSalary
FROM EmployeeSalary
WHERE Salary IS NOT NULL
GROUP BY JobTitle
HAVING AvgSalary > 44000      -- alias works here!
ORDER BY AvgSalary DESC;      -- alias works here too!
