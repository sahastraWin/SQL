-- ============================================================
-- LEVEL 4: SQL JOINS - Combining Data from Multiple Tables
-- ============================================================
-- JOIN connects two or more tables using a related column.
-- This is one of the MOST IMPORTANT topics in SQL!
--
-- Types covered:
--   1. INNER JOIN      - matching rows in BOTH tables
--   2. LEFT JOIN       - ALL rows from LEFT + matching from RIGHT
--   3. RIGHT JOIN      - ALL rows from RIGHT + matching from LEFT
--   4. FULL OUTER JOIN - ALL rows from BOTH tables
--   5. SELF JOIN       - joining a table to itself
--   6. CROSS JOIN      - every combination of rows
-- ============================================================

USE LearnSQL;

-- ============================================================
-- SETUP: Create a complete multi-table schema
-- We'll use: Customer, Inventory, Employee, Sale
-- ============================================================

-- Drop existing tables if they exist (careful in production!)
DROP TABLE IF EXISTS Sale;
DROP TABLE IF EXISTS Inventory;

-- Inventory table (products)
CREATE TABLE IF NOT EXISTS Inventory (
    InventoryID   INT PRIMARY KEY AUTO_INCREMENT,
    InventoryName VARCHAR(50) NOT NULL,
    InventoryDescription VARCHAR(255)
);

-- Sale table (links Customer + Inventory + Employee)
CREATE TABLE IF NOT EXISTS Sale (
    SaleID        INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID    INT NOT NULL,
    InventoryID   INT NOT NULL,
    EmployeeID    INT NOT NULL,
    SaleDate      DATE NOT NULL,
    SaleQuantity  INT NOT NULL,
    SaleUnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID),
    FOREIGN KEY (EmployeeID)  REFERENCES Employee(EmployeeID)
);

-- Insert Inventory data
INSERT INTO Inventory (InventoryName, InventoryDescription) VALUES
    ('Paper Ream',     'A4 white paper 500 sheets'),
    ('Stapler',        'Heavy duty stapler'),
    ('Printer Ink',    'Black ink cartridge'),
    ('Laptop',         'Business laptop 15 inch'),
    ('Desk Chair',     'Ergonomic office chair'),
    ('USB Hub',        'USB-C 4-port hub');  -- This item has NO sales (for demo)

-- Insert Sale data
INSERT INTO Sale (CustomerID, InventoryID, EmployeeID, SaleDate, SaleQuantity, SaleUnitPrice) VALUES
    (1, 1, 1, '2024-01-15', 10, 5.99),
    (1, 2, 2, '2024-01-20', 2,  12.50),
    (3, 3, 1, '2024-02-01', 5,  8.75),
    (3, 4, 3, '2024-02-15', 1,  899.00),
    (4, 5, 4, '2024-03-01', 3,  150.00),
    (4, 1, 2, '2024-03-10', 20, 5.99),
    (5, 3, 1, '2024-03-15', 8,  8.75);

-- ============================================================
-- 1. INNER JOIN - Returns ONLY rows that match in BOTH tables
-- Think of it as the INTERSECTION (overlap) of two sets.
-- ============================================================

-- Get all sales with product names (only matching rows returned)
SELECT
    s.SaleID,
    i.InventoryName,
    s.SaleDate,
    s.SaleQuantity,
    s.SaleUnitPrice,
    (s.SaleQuantity * s.SaleUnitPrice) AS TotalAmount  -- calculated column
FROM Sale s
INNER JOIN Inventory i ON s.InventoryID = i.InventoryID
ORDER BY i.InventoryName;

-- Join Employee + EmployeeSalary (get name + salary together)
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID;

-- ============================================================
-- 2. LEFT JOIN (LEFT OUTER JOIN)
-- Returns ALL rows from LEFT table + matching rows from RIGHT.
-- If no match on right side, right columns show NULL.
-- ============================================================

-- Show ALL inventory items, even those with no sales
-- (USB Hub has no sales, so it will show with NULL sale info)
SELECT
    i.InventoryID,
    i.InventoryName,
    s.SaleDate,
    s.SaleQuantity
FROM Inventory i
LEFT JOIN Sale s ON i.InventoryID = s.InventoryID
ORDER BY i.InventoryName;

-- Find inventory items that have NEVER been sold
-- (Filter for NULLs on the right side = only left-only records)
SELECT
    i.InventoryID,
    i.InventoryName
FROM Inventory i
LEFT JOIN Sale s ON i.InventoryID = s.InventoryID
WHERE s.InventoryID IS NULL;  -- NULL means no matching sale was found

-- ============================================================
-- 3. RIGHT JOIN (RIGHT OUTER JOIN)
-- Returns ALL rows from RIGHT table + matching from LEFT.
-- Less commonly used — most people prefer LEFT JOIN.
-- ============================================================

-- Show ALL sales with inventory info
-- (Even if inventory record is missing, sale row appears)
SELECT
    s.SaleID,
    s.SaleDate,
    i.InventoryName
FROM Inventory i
RIGHT JOIN Sale s ON i.InventoryID = s.InventoryID;

-- ============================================================
-- 4. FULL OUTER JOIN
-- Returns ALL rows from BOTH tables.
-- MySQL doesn't support FULL OUTER JOIN directly,
-- so we simulate it using UNION of LEFT + RIGHT join.
-- ============================================================

-- All inventory items AND all sales (even unmatched ones)
SELECT
    i.InventoryID,
    i.InventoryName,
    s.SaleID,
    s.SaleDate
FROM Inventory i
LEFT JOIN Sale s ON i.InventoryID = s.InventoryID

UNION

SELECT
    i.InventoryID,
    i.InventoryName,
    s.SaleID,
    s.SaleDate
FROM Inventory i
RIGHT JOIN Sale s ON i.InventoryID = s.InventoryID;

-- ============================================================
-- 5. SELF JOIN - A table joins with ITSELF
-- Common use case: Employee-Manager hierarchy
-- (One employee can be the manager of another employee)
-- ============================================================

-- Create a staff table with manager relationship
DROP TABLE IF EXISTS Staff;
CREATE TABLE IF NOT EXISTS Staff (
    EmployeeID        INT PRIMARY KEY,
    EmployeeFirstName VARCHAR(30),
    EmployeeLastName  VARCHAR(30),
    ManagerID         INT   -- Points to another EmployeeID (their manager)
);

INSERT INTO Staff VALUES
    (1001, 'Tan',    'Mei Ling', NULL),   -- Top manager, has no manager
    (1002, 'Kelvin', 'Koh',      1001),   -- Reports to Tan Mei Ling
    (1003, 'Amin',   'Wong',     1002),   -- Reports to Kelvin Koh
    (1004, 'Priya',  'Kumar',    1001),   -- Also reports to Tan Mei Ling
    (1005, 'Raj',    'Singh',    1002);   -- Also reports to Kelvin Koh

-- INNER SELF JOIN: Show employee + their manager name
-- (Top manager won't appear because they have no manager)
SELECT
    E.EmployeeID,
    CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS EmployeeName,
    E.ManagerID,
    CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS ManagerName
FROM Staff E
INNER JOIN Staff M ON E.ManagerID = M.EmployeeID;  -- Join staff to itself!

-- LEFT OUTER SELF JOIN: Show ALL employees including top manager
-- (Top manager appears with NULL as their manager name)
SELECT
    E.EmployeeID,
    CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS EmployeeName,
    CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS ManagerName
FROM Staff E
LEFT OUTER JOIN Staff M ON E.ManagerID = M.EmployeeID;

-- ============================================================
-- 6. CROSS JOIN - Every possible combination
-- Cartesian Product: table1 rows × table2 rows
-- If table A has 3 rows and table B has 4 rows = 12 result rows
-- ============================================================

CREATE TABLE IF NOT EXISTS Colors  (Color VARCHAR(20));
CREATE TABLE IF NOT EXISTS Sizes   (Size  VARCHAR(20));

INSERT INTO Colors VALUES ('Red'), ('Blue'), ('Green');
INSERT INTO Sizes  VALUES ('Small'), ('Medium'), ('Large');

-- Every color paired with every size = 3 × 3 = 9 combinations
SELECT c.Color, s.Size
FROM Colors c
CROSS JOIN Sizes s;

-- ============================================================
-- 7. JOINING 3 TABLES
-- You can chain multiple JOINs together
-- ============================================================

-- Get Sales with Customer name, Product name, and Employee name
SELECT
    s.SaleID,
    s.SaleDate,
    CONCAT(e.FirstName, ' ', e.LastName) AS SoldBy,
    i.InventoryName                       AS Product,
    s.SaleQuantity,
    s.SaleUnitPrice,
    (s.SaleQuantity * s.SaleUnitPrice)    AS TotalAmount
FROM Sale s
INNER JOIN Employee  e ON s.EmployeeID  = e.EmployeeID
INNER JOIN Inventory i ON s.InventoryID = i.InventoryID
ORDER BY s.SaleDate;

-- ============================================================
-- 8. OLD-STYLE JOIN (without JOIN keyword)
-- This uses comma-separated tables in FROM with WHERE condition.
-- The result is identical to INNER JOIN.
-- Modern style (with JOIN keyword) is preferred.
-- ============================================================

-- Old style (still works, but avoid in new code):
SELECT i.InventoryName, s.SaleDate, s.SaleQuantity
FROM Inventory i, Sale s
WHERE s.InventoryID = i.InventoryID;

-- Modern equivalent:
SELECT i.InventoryName, s.SaleDate, s.SaleQuantity
FROM Inventory i
INNER JOIN Sale s ON s.InventoryID = i.InventoryID;
