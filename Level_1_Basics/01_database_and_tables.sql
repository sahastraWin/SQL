-- ============================================================

-- LEVEL 1: SQL BASICS - Database & Table Operations

-- ============================================================

-- This file covers the very first steps in SQL:

--   1. Creating a Database

--   2. Using a Database

--   3. Creating Tables with constraints

--   4. Inserting Data

--   5. Viewing Data

--   6. Updating Data

--   7. Deleting Data

--   8. Dropping Tables & Columns

-- ============================================================



-- ------------------------------------------------------------

-- STEP 1: CREATE A DATABASE

-- A database is a container that holds all your tables.

-- ------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS LearnSQL;



-- ------------------------------------------------------------

-- STEP 2: USE THE DATABASE

-- Before doing anything, tell MySQL which database to work in.

-- ------------------------------------------------------------

USE LearnSQL;



-- ------------------------------------------------------------

-- STEP 3: CREATE A TABLE

-- A table holds data in rows and columns, like a spreadsheet.

--

-- Data Types used here:

--   INT          = whole numbers (1, 2, 100)

--   VARCHAR(n)   = text up to n characters

--   CHAR(n)      = fixed-length text

--   DATE         = date values (YYYY-MM-DD)

--

-- Constraints used here:

--   PRIMARY KEY  = uniquely identifies each row

--   NOT NULL     = this column cannot be empty

--   UNIQUE       = no two rows can have the same value

--   CHECK        = value must meet a condition

--   DEFAULT      = use this value if none is given

-- ------------------------------------------------------------



CREATE TABLE IF NOT EXISTS Customer (

    CustomerID    INT AUTO_INCREMENT PRIMARY KEY,   -- Auto-increments: 1, 2, 3...

    CustomerNumber INT NOT NULL UNIQUE CHECK (CustomerNumber > 0), -- Must be positive & unique

    LastName      VARCHAR(30) NOT NULL,              -- Cannot be empty

    FirstName     VARCHAR(30) NOT NULL,

    AreaCode      INT DEFAULT 71000,                 -- Uses 71000 if not provided

    Address       VARCHAR(50),                       -- Optional field

    Country       VARCHAR(50) DEFAULT 'Malaysia'     -- Default country

);



-- ------------------------------------------------------------

-- STEP 4: INSERT DATA INTO THE TABLE

-- We add rows of data using INSERT INTO.

-- 'DEFAULT' uses the default value defined in the table.

-- ------------------------------------------------------------



INSERT INTO Customer (CustomerNumber, LastName, FirstName, AreaCode, Address, Country)

VALUES

    (100, 'Ying',   'Fang',   418999, '123 Main St',   'Malaysia'),

    (200, 'Mei',    'Tan',    71000,  '456 Oak Ave',   'Thailand'),

    (300, 'John',   'Albert', 71000,  '789 Pine Rd',   'Malaysia'),

    (400, 'Brown',  'James',  20000,  '321 Elm St',    'Australia'),

    (500, 'Michael','Sarah',  30000,  '654 Maple Dr',  'Malaysia');



-- ------------------------------------------------------------

-- STEP 5: VIEW / SELECT DATA FROM TABLE

-- SELECT is how we read data from a table.

-- ------------------------------------------------------------



-- View ALL columns and ALL rows

SELECT * FROM Customer;



-- View SPECIFIC columns only

SELECT CustomerID, CustomerNumber, LastName, FirstName

FROM Customer;



-- View only the first 2 rows (useful for large tables)

SELECT * FROM Customer LIMIT 2;



-- ------------------------------------------------------------

-- STEP 6: ADD A NEW COLUMN TO EXISTING TABLE

-- ALTER TABLE lets you modify a table after it's created.

-- ------------------------------------------------------------



ALTER TABLE Customer

ADD PhoneNumber VARCHAR(20);



-- ------------------------------------------------------------

-- STEP 7: UPDATE / MODIFY DATA IN THE TABLE

-- UPDATE changes existing data. Always use WHERE to target specific rows!

-- Without WHERE, ALL rows get updated.

-- ------------------------------------------------------------



UPDATE Customer SET PhoneNumber = '1234567890' WHERE CustomerID = 1;

UPDATE Customer SET PhoneNumber = '0987654321' WHERE CustomerID = 2;

UPDATE Customer SET PhoneNumber = '1122334455' WHERE CustomerID = 3;



-- Verify the updates

SELECT CustomerID, FirstName, LastName, PhoneNumber FROM Customer;



-- ------------------------------------------------------------

-- STEP 8: DELETE A COLUMN FROM THE TABLE

-- DROP COLUMN removes a column permanently.

-- ------------------------------------------------------------



ALTER TABLE Customer

DROP COLUMN PhoneNumber;



-- ------------------------------------------------------------

-- STEP 9: DELETE SPECIFIC ROWS FROM TABLE

-- DELETE removes rows. Use WHERE to avoid deleting everything!

-- ------------------------------------------------------------



-- Delete only customers from Thailand

-- If you specifically want to delete by Country, you can temporarily turn off the safety restriction for your current session.  Run this command in your SQL tab:

-- for good practice SET SQL_SAFE_UPDATES = 1;

-- If you use the Menu path instead of code, go to Edit > Preferences > SQL Editor and uncheck "Safe Updates." You will need to reconnect to your database (close and reopen the connection) for this change to take effect.

-- The error occurs because Safe Update Mode is enabled. This is a safety feature that prevents you from accidentally updating or deleting a large amount of data by mistake.

-- It requires that any UPDATE or DELETE statement includes a WHERE clause that uses a Key Column (usually the PRIMARY KEY, which is CustomerID in your table).

-- Since you are trying to delete based on Country, which is not a key, MySQL is blocking the execution.

-- Use DELETE FROM Customer WHERE CustomerID = 2 instead of 

-- -- If you still want to use DELETE FROM Customer WHERE Country = 'Thailand'; then SET SQL_SAFE_UPDATES = 0; and then run the command



DELETE FROM Customer WHERE CustomerID = 2;



SELECT * FROM Customer;



-- ------------------------------------------------------------

-- STEP 10: CHANGE DATA TYPE OF A COLUMN

-- MODIFY COLUMN lets you change a column's data type.

-- ------------------------------------------------------------



-- First add the column back for this demo

ALTER TABLE Customer ADD PhoneNumber VARCHAR(20);



-- Now change it to a shorter size

ALTER TABLE Customer MODIFY COLUMN PhoneNumber VARCHAR(15);



-- ------------------------------------------------------------

-- STEP 11: DROP (customerDELETE) AN ENTIRE TABLE

-- WARNING: This permanently deletes the table and all its data!

-- ------------------------------------------------------------



-- DROP TABLE Customer;  

-- (Commented out so we can keep using this table in further levels)



-- ------------------------------------------------------------

-- QUICK REVIEW: SQL Command Categories

-- DDL (Data Definition Language):  CREATE, DROP, ALTER, TRUNCATE

-- DML (Data Manipulation Language): INSERT, UPDATE, DELETE

-- DQL (Data Query Language):        SELECT

-- DCL (Data Control Language):      GRANT, REVOKE

-- TCL (Transaction Control Language): COMMIT, ROLLBACK

-- ------------------------------------------------------------



SELECT * FROM Customer;  -- Final check to see all data

