-- ============================================================
-- LEVEL 9: WINDOW FUNCTIONS & RANKING FUNCTIONS
-- ============================================================
-- Window functions perform calculations ACROSS rows related
-- to the current row — without collapsing rows like GROUP BY does.
--
-- Key difference:
--   GROUP BY: returns ONE row per group
--   Window:   returns ONE row per ORIGINAL row (no collapsing)
--
-- Syntax: function() OVER (PARTITION BY ... ORDER BY ...)
--   PARTITION BY = like GROUP BY but keeps all rows
--   ORDER BY     = determines calculation order within partition
--
-- Functions covered:
--   ROW_NUMBER()   - unique sequential number
--   RANK()         - same rank for ties, gaps in sequence
--   DENSE_RANK()   - same rank for ties, NO gaps
--   NTILE(n)       - divide rows into n equal groups
--   PARTITION BY   - calculate per-group
--   LAG()          - access previous row's value
--   LEAD()         - access next row's value
--   FIRST_VALUE()  - first value in the window
--   LAST_VALUE()   - last value in the window
-- ============================================================

USE LearnSQL;

-- ============================================================
-- SETUP: Recreate EmployeeSalary with more complete data
-- ============================================================

-- First clean up and add more records
INSERT IGNORE INTO Employee (FirstName, LastName, Age, Gender, Country) VALUES
    ('Oscar',  'Martinez', 40, 'Male', 'USA'),
    ('Toby',   'Flenderson', 45, 'Male', 'USA');

-- Check current max EmployeeID
SELECT MAX(EmployeeID) FROM Employee;

-- Add salary data for any employees missing it
INSERT IGNORE INTO EmployeeSalary (EmployeeID, JobTitle, Salary)
SELECT EmployeeID, 'HR', 41000
FROM Employee
WHERE EmployeeID NOT IN (SELECT EmployeeID FROM EmployeeSalary);

-- View all data for reference
SELECT e.EmployeeID, e.FirstName, e.LastName, es.JobTitle, es.Salary
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary DESC;

-- ============================================================
-- 1. ROW_NUMBER() - Assigns a unique number to each row
-- Even if salaries are the same, each row gets a DIFFERENT number.
-- No ties — always unique.
-- ============================================================

SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    ROW_NUMBER() OVER (ORDER BY es.Salary DESC) AS SalaryRank
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY SalaryRank;

-- ============================================================
-- 2. RANK() - Assigns rank with GAPS for ties
-- If two people share rank 2, the next rank is 4 (skips 3).
-- ============================================================

SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    RANK() OVER (ORDER BY es.Salary DESC) AS SalaryRank
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY SalaryRank;

-- ============================================================
-- 3. DENSE_RANK() - Assigns rank WITHOUT gaps for ties
-- If two people share rank 2, the next rank is 3 (no gaps).
-- ============================================================

SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    DENSE_RANK() OVER (ORDER BY es.Salary DESC) AS SalaryRank
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY SalaryRank;

-- ============================================================
-- COMPARISON: ROW_NUMBER vs RANK vs DENSE_RANK side by side
-- Easiest way to see the differences with tied values
-- ============================================================

SELECT
    e.FirstName,
    e.LastName,
    es.Salary,
    ROW_NUMBER()  OVER (ORDER BY es.Salary DESC) AS RowNum,
    RANK()        OVER (ORDER BY es.Salary DESC) AS RankNum,
    DENSE_RANK()  OVER (ORDER BY es.Salary DESC) AS DenseRankNum
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary DESC;

-- ============================================================
-- 4. PARTITION BY - Rank WITHIN groups
-- Like having a separate ranking for each department/category.
-- ============================================================

-- Rank employees by salary WITHIN each job title
-- (Each job title gets its own 1st, 2nd, 3rd place)
SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    RANK() OVER (
        PARTITION BY es.JobTitle   -- Reset ranking for each job title
        ORDER BY es.Salary DESC
    ) AS RankWithinJob
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.JobTitle, RankWithinJob;

-- ROW_NUMBER with PARTITION BY (find top earner per job)
SELECT *
FROM (
    SELECT
        e.FirstName,
        e.LastName,
        es.JobTitle,
        es.Salary,
        ROW_NUMBER() OVER (
            PARTITION BY es.JobTitle
            ORDER BY es.Salary DESC
        ) AS RankInJob
    FROM Employee e
    INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
    WHERE es.Salary IS NOT NULL
) ranked
WHERE RankInJob = 1;  -- Only the TOP earner per job title

-- ============================================================
-- 5. NTILE(n) - Divide rows into n equal buckets/groups
-- Useful for percentile analysis (top 25%, bottom 25%, etc.)
-- ============================================================

-- Divide all employees into 4 quartiles by salary
SELECT
    e.FirstName,
    e.LastName,
    es.Salary,
    NTILE(4) OVER (ORDER BY es.Salary DESC) AS SalaryQuartile
    -- Quartile 1 = top 25% earners
    -- Quartile 4 = bottom 25% earners
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary DESC;

-- Divide into 3 groups (thirds / terciles)
SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    NTILE(3) OVER (
        PARTITION BY es.JobTitle
        ORDER BY es.Salary DESC
    ) AS SalaryGroup
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.JobTitle, SalaryGroup;

-- ============================================================
-- 6. COUNT/SUM/AVG with OVER() - Running/Cumulative calculations
-- Using aggregate functions as window functions!
-- ============================================================

-- Show each employee's salary AND the total company salary alongside
SELECT
    e.FirstName,
    e.LastName,
    es.Salary,
    SUM(es.Salary)   OVER ()                            AS TotalPayroll,
    AVG(es.Salary)   OVER ()                            AS AvgSalary,
    COUNT(*)         OVER ()                            AS TotalEmployees,
    -- Percentage of total payroll this employee represents
    ROUND(es.Salary * 100.0 / SUM(es.Salary) OVER (), 2) AS PctOfPayroll
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary DESC;

-- Count of employees per gender shown alongside each row
-- (Unlike GROUP BY, all rows are preserved)
SELECT
    e.FirstName,
    e.LastName,
    e.Gender,
    es.Salary,
    COUNT(e.Gender) OVER (PARTITION BY e.Gender) AS TotalInGender
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL;

-- Cumulative (running) sum of salary when sorted by salary
SELECT
    e.FirstName,
    e.LastName,
    es.Salary,
    SUM(es.Salary) OVER (
        ORDER BY es.Salary    -- Running total: adds each row in order
    ) AS RunningTotal
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary;

-- ============================================================
-- 7. LAG() and LEAD() - Access adjacent rows' values
-- LAG(column, n)  = look BACK n rows (previous row)
-- LEAD(column, n) = look FORWARD n rows (next row)
-- ============================================================

-- Show each sale with the PREVIOUS sale amount
SELECT
    s.SaleID,
    s.SaleDate,
    s.SaleUnitPrice * s.SaleQuantity                        AS SaleAmount,
    LAG(s.SaleUnitPrice * s.SaleQuantity, 1) OVER (
        ORDER BY s.SaleDate
    )                                                       AS PreviousSaleAmount,
    -- Difference from previous sale
    (s.SaleUnitPrice * s.SaleQuantity) -
    LAG(s.SaleUnitPrice * s.SaleQuantity, 1, 0) OVER (
        ORDER BY s.SaleDate
    )                                                       AS ChangeSincePrevious
FROM Sale s
ORDER BY s.SaleDate;

-- Show salary compared to next higher salary (LEAD)
SELECT
    e.FirstName,
    e.LastName,
    es.Salary,
    LEAD(es.Salary, 1) OVER (ORDER BY es.Salary DESC)       AS NextLowerSalary,
    es.Salary - LEAD(es.Salary, 1, 0) OVER (
        ORDER BY es.Salary DESC
    )                                                       AS SalaryGap
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.Salary DESC;

-- ============================================================
-- 8. FIRST_VALUE() and LAST_VALUE()
-- Get the first or last value in the window
-- ============================================================

-- Show each employee with the highest salary in their job title
SELECT
    e.FirstName,
    e.LastName,
    es.JobTitle,
    es.Salary,
    FIRST_VALUE(es.Salary) OVER (
        PARTITION BY es.JobTitle
        ORDER BY es.Salary DESC
    )                                                       AS TopSalaryInRole,
    es.Salary - FIRST_VALUE(es.Salary) OVER (
        PARTITION BY es.JobTitle
        ORDER BY es.Salary DESC
    )                                                       AS GapFromTop
FROM Employee e
INNER JOIN EmployeeSalary es ON e.EmployeeID = es.EmployeeID
WHERE es.Salary IS NOT NULL
ORDER BY es.JobTitle, es.Salary DESC;

-- ============================================================
-- SUMMARY: When to use which ranking function
--
-- ROW_NUMBER()  → When you need a UNIQUE number per row
--                 Use for: pagination, deduplication
--
-- RANK()        → When TIES should get same rank, with GAPS
--                 Use for: sports leaderboards
--
-- DENSE_RANK()  → When TIES should get same rank, WITHOUT gaps
--                 Use for: grade/tier assignments
--
-- NTILE(n)      → When you want to split into n equal groups
--                 Use for: percentile buckets, A/B/C/D grading
--
-- LAG()/LEAD()  → When you need to compare to adjacent rows
--                 Use for: month-over-month, YoY comparisons
-- ============================================================
