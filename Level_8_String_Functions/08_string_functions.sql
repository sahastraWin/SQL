-- ============================================================
-- LEVEL 8: STRING FUNCTIONS
-- ============================================================
-- String functions let you manipulate text data.
--
-- Functions covered:
--   TRIM, LTRIM, RTRIM  - remove whitespace
--   UPPER, LOWER        - change case
--   LENGTH              - string length
--   SUBSTRING           - extract part of string
--   REPLACE             - replace text in a string
--   CONCAT              - join strings together
--   LEFT, RIGHT         - extract from left/right
--   CHARINDEX / INSTR   - find position of substring
--   REVERSE             - reverse a string
--   ISNULL / COALESCE   - handle NULL values
-- ============================================================

USE LearnSQL;

-- ============================================================
-- SETUP: Create a table with messy data (real world scenario!)
-- ============================================================

DROP TABLE IF EXISTS EmployeeErrors;

CREATE TABLE EmployeeErrors (
    EmployeeID   VARCHAR(20),    -- Has extra spaces on purpose (messy data)
    FirstName    VARCHAR(30),
    LastName     VARCHAR(30),
    Email        VARCHAR(100)
);

-- Insert data with intentional errors: spaces, wrong case, etc.
INSERT INTO EmployeeErrors VALUES
    (' 1001',  'jim',    'Halpert- Fired',  'jim.halpert@office.COM'),
    ('1002 ',  'PAM',    'Beasley',         'pam.Beasley@Office.com'),
    (' 1003',  'MICHAEL','Scott',           ' michael.scott@office.com '),
    ('1004  ', 'dwight', 'Schrute',         'DWIGHT.SCHRUTE@OFFICE.COM'),
    ('1005',   'Angela', 'Martin',          'angela.martin@office.com');

-- See the messy data
SELECT * FROM EmployeeErrors;

-- ============================================================
-- 1. TRIM, LTRIM, RTRIM - Remove spaces
-- ============================================================

-- TRIM removes spaces from BOTH sides
SELECT
    EmployeeID,
    TRIM(EmployeeID)  AS CleanID_TRIM
FROM EmployeeErrors;

-- LTRIM removes spaces from the LEFT (leading spaces)
SELECT
    EmployeeID,
    LTRIM(EmployeeID) AS CleanID_LTRIM
FROM EmployeeErrors;

-- RTRIM removes spaces from the RIGHT (trailing spaces)
SELECT
    EmployeeID,
    RTRIM(EmployeeID) AS CleanID_RTRIM
FROM EmployeeErrors;

-- ============================================================
-- 2. UPPER and LOWER - Change text case
-- ============================================================

-- Convert FirstName to proper case (first upper, rest lower)
-- MySQL doesn't have PROPER() like Excel, but we can simulate:
SELECT
    FirstName,
    LOWER(FirstName)                            AS AllLowercase,
    UPPER(FirstName)                            AS AllUppercase,
    -- Make first letter uppercase, rest lowercase:
    CONCAT(UPPER(LEFT(FirstName, 1)), LOWER(SUBSTRING(FirstName, 2))) AS ProperCase
FROM EmployeeErrors;

-- Normalize email to all lowercase
SELECT
    Email,
    LOWER(TRIM(Email)) AS CleanEmail
FROM EmployeeErrors;

-- ============================================================
-- 3. LENGTH - Get the length of a string
-- ============================================================

SELECT
    FirstName,
    LENGTH(FirstName)       AS NameLength,
    LastName,
    LENGTH(TRIM(LastName))  AS LastNameLength
FROM EmployeeErrors;

-- Find employees with long email addresses
SELECT Email, LENGTH(TRIM(Email)) AS EmailLength
FROM EmployeeErrors
ORDER BY EmailLength DESC;

-- ============================================================
-- 4. SUBSTRING - Extract part of a string
-- SUBSTRING(string, start_position, length)
-- Positions start from 1 (not 0!)
-- ============================================================

-- Extract first 3 characters of FirstName
SELECT
    FirstName,
    SUBSTRING(FirstName, 1, 3) AS First3Letters
FROM EmployeeErrors;

-- Get last 4 characters of EmployeeID (after trimming)
SELECT
    TRIM(EmployeeID) AS CleanID,
    SUBSTRING(TRIM(EmployeeID), 2, 4) AS LastPart
FROM EmployeeErrors;

-- ============================================================
-- 5. REPLACE - Substitute text within a string
-- REPLACE(string, old_text, new_text)
-- ============================================================

-- Remove "- Fired" from LastName
SELECT
    LastName,
    REPLACE(LastName, '- Fired', '') AS CleanLastName
FROM EmployeeErrors;

-- Replace .COM with .com in emails (case cleanup)
SELECT
    Email,
    REPLACE(LOWER(TRIM(Email)), ' ', '') AS CleanEmail
FROM EmployeeErrors;

-- Replace '@office.com' with '@company.com' (domain change)
SELECT
    Email,
    REPLACE(LOWER(TRIM(Email)), '@office.com', '@company.com') AS NewEmail
FROM EmployeeErrors;

-- ============================================================
-- 6. CONCAT - Join (concatenate) strings together
-- CONCAT(string1, string2, ...)
-- ============================================================

-- Combine FirstName and LastName into FullName
SELECT
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM EmployeeErrors;

-- Full name with title
SELECT
    CONCAT('Mr/Ms ', UPPER(LEFT(FirstName,1)), LOWER(SUBSTRING(FirstName,2)),
           ' ', LastName) AS FormalName
FROM EmployeeErrors;

-- Build a fake email address from name
SELECT
    FirstName,
    LastName,
    CONCAT(LOWER(FirstName), '.', LOWER(REPLACE(LastName, '- Fired', '')),
           '@company.com') AS GeneratedEmail
FROM EmployeeErrors;

-- ============================================================
-- 7. LEFT and RIGHT - Extract from beginning or end
-- LEFT(string, n)  = first n characters
-- RIGHT(string, n) = last n characters
-- ============================================================

SELECT
    Email,
    LEFT(Email, 5)                  AS First5Chars,
    RIGHT(TRIM(Email), 3)           AS Last3Chars,  -- e.g., 'com'
    LEFT(LOWER(TRIM(Email)),
         INSTR(LOWER(TRIM(Email)), '@') - 1) AS UsernameOnly
FROM EmployeeErrors;

-- ============================================================
-- 8. INSTR - Find position of a substring (MySQL equivalent of CHARINDEX)
-- INSTR(string, substring) returns the position (1-based)
-- Returns 0 if not found
-- ============================================================

-- Find position of '@' in email addresses
SELECT
    Email,
    INSTR(LOWER(TRIM(Email)), '@')  AS AtSignPosition
FROM EmployeeErrors;

-- Extract domain from email using INSTR + SUBSTRING
SELECT
    Email,
    SUBSTRING(
        LOWER(TRIM(Email)),
        INSTR(LOWER(TRIM(Email)), '@') + 1   -- start after '@'
    ) AS Domain
FROM EmployeeErrors;

-- ============================================================
-- 9. REVERSE - Reverse a string
-- ============================================================

SELECT
    FirstName,
    REVERSE(FirstName) AS ReversedName
FROM EmployeeErrors;

-- Trick: find if a string is a palindrome (reads same forwards/backwards)
SELECT
    'racecar' AS TestWord,
    CASE WHEN 'racecar' = REVERSE('racecar') THEN 'Yes, palindrome!'
         ELSE 'No, not a palindrome'
    END AS IsPalindrome;

-- ============================================================
-- 10. COALESCE and IFNULL - Handle NULL values in strings
-- IFNULL(value, replacement)  - if value is NULL, use replacement
-- COALESCE(val1, val2, ...)   - return first non-NULL value
-- ============================================================

-- Add a country column with some NULLs for demo
SELECT
    e.FirstName,
    e.LastName,
    e.Country,
    IFNULL(e.Country, 'Unknown')                AS CountryOrUnknown,
    COALESCE(e.Country, 'Not specified')        AS CountryCoalesce
FROM Employee e;

-- COALESCE picks first non-null from a list
SELECT
    e.FirstName,
    e.Country,
    -- Try Country first, then a default
    COALESCE(e.Country, 'N/A')                  AS DisplayCountry
FROM Employee e;

-- ============================================================
-- 11. COMPLETE DATA CLEANING EXAMPLE
-- Apply multiple string functions to clean up the messy table
-- ============================================================

SELECT
    TRIM(EmployeeID)                                            AS CleanID,
    CONCAT(
        UPPER(LEFT(TRIM(FirstName), 1)),
        LOWER(SUBSTRING(TRIM(FirstName), 2))
    )                                                           AS CleanFirstName,
    REPLACE(TRIM(LastName), '- Fired', '')                      AS CleanLastName,
    LOWER(TRIM(Email))                                          AS CleanEmail
FROM EmployeeErrors;

-- ============================================================
-- 12. SPLITTING A STRING BY DELIMITER
-- Extract parts from a string like "Street, City" or "USA-TX"
-- Uses SUBSTRING + INSTR together
-- ============================================================

-- Sample addresses with comma delimiter
DROP TABLE IF EXISTS AddressData;
CREATE TABLE AddressData (
    FullAddress VARCHAR(100)
);

INSERT INTO AddressData VALUES
    ('1808 Fox Chase DR, Goodlettsville'),
    ('1832 Fox Chase DR, Springfield'),
    ('456 Main St, Nashville'),
    ('789 Oak Ave, Memphis');

-- Extract the STREET part (everything before the comma)
SELECT
    FullAddress,
    SUBSTRING(FullAddress, 1, INSTR(FullAddress, ',') - 1) AS StreetAddress,
    TRIM(SUBSTRING(FullAddress, INSTR(FullAddress, ',') + 1)) AS City
FROM AddressData;
