=======================================================
  SQL BASICS TO ADVANCED - COMPLETE LEARNING PACKAGE
=======================================================

FILES INCLUDED (run in this order):
-------------------------------------
Level_1_Basics/              01_database_and_tables.sql
Level_2_Filtering_Sorting/   02_filtering_and_sorting.sql
Level_3_Aggregate_Functions/ 03_aggregate_functions.sql
Level_4_Joins/               04_joins.sql
Level_5_Set_Operations/      05_set_operations.sql
Level_6_Subqueries_CTEs/     06_subqueries_and_ctes.sql
Level_7_Views_Temp_Tables/   07_views_and_temp_tables.sql
Level_8_String_Functions/    08_string_functions.sql
Level_9_Window_Ranking/      09_window_ranking_functions.sql
Level_10_Advanced_Topics/    10_advanced_topics.sql

=======================================================
HOW TO IMPORT & USE IN MySQL Workbench
=======================================================

STEP 1: Open MySQL Workbench
  - Launch MySQL Workbench on your computer.
  - Click your local connection (usually "Local instance MySQL").
  - Enter your password if asked.

STEP 2: Open a SQL File
  - Go to the top menu: File > Open SQL Script
  - Browse to this folder and open:
      Level_1_Basics/01_database_and_tables.sql
  - The file opens in a new tab inside Workbench.

STEP 3: Run the Entire File
  - Press Ctrl + Shift + Enter  (Windows/Linux)
    OR  Cmd  + Shift + Enter   (Mac)
  - This runs ALL statements in the file at once.
  - Results appear in the Output panel at the bottom.

STEP 4: Run ONE Statement at a Time (recommended for learning)
  - Click anywhere inside a single SQL statement.
  - Press Ctrl + Enter  (Windows/Linux)
    OR  Cmd  + Enter   (Mac)
  - Only that one statement runs — great for seeing step-by-step output.

STEP 5: Move to the next level
  - After finishing Level 1, open Level 2 the same way.
  - IMPORTANT: Always run Level 1 first before Level 2,
    because later files depend on tables created in earlier files.

=======================================================
TIPS FOR BEGINNERS
=======================================================

- Read ALL the comments (lines starting with --) carefully.
  They explain WHAT and WHY each piece of code does.

- Don't rush. Run one section at a time and look at the output.

- If you see an error, check:
    a) Did you run the earlier level files first?
    b) Is your cursor inside the right statement?
    c) Is the LearnSQL database selected? (run: USE LearnSQL;)

- In Workbench, you can see your database in the left panel
  under "SCHEMAS". Click the arrow next to "LearnSQL" to expand
  and see your tables.

- To see table data anytime, right-click any table name in the
  left panel and choose "Select Rows - Limit 1000".

=======================================================
LEARNING PATH SUMMARY
=======================================================

Level 1  - CREATE database, CREATE TABLE, INSERT, SELECT, UPDATE, DELETE
Level 2  - WHERE, LIKE, IN, BETWEEN, IS NULL, ORDER BY, DISTINCT, LIMIT
Level 3  - COUNT, SUM, AVG, MAX, MIN, GROUP BY, HAVING, CASE
Level 4  - INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN, SELF JOIN, CROSS JOIN
Level 5  - UNION, UNION ALL, INTERSECT, EXCEPT
Level 6  - Subqueries, Derived Tables, Correlated Subqueries, CTEs (WITH)
Level 7  - CREATE VIEW, TEMPORARY TABLE, table copying
Level 8  - TRIM, UPPER, LOWER, LENGTH, SUBSTRING, REPLACE, CONCAT, INSTR
Level 9  - ROW_NUMBER, RANK, DENSE_RANK, NTILE, PARTITION BY, LAG, LEAD
Level 10 - Stored Procedures, CAST/CONVERT, Date Functions, Transactions,
           Indexes, Removing Duplicates, Normalization

Good luck and happy learning!
