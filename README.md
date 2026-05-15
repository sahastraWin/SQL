<div align="center">

# 🗄️ SQL Mastery
### From Zero to Query Hero — 10 Levels of Structured Learning

![MySQL](https://img.shields.io/badge/SQL-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Levels](https://img.shields.io/badge/Levels-10-blueviolet?style=for-the-badge&logo=databricks&logoColor=white)
![Difficulty](https://img.shields.io/badge/Difficulty-Beginner%20%E2%86%92%20Advanced-orange?style=for-the-badge&logo=codewars&logoColor=white)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge&logo=github&logoColor=white)

**A complete, self-paced SQL curriculum** — from absolute beginner to writing complex, production-level queries.

</div>

---

## 🗺️ Table of Contents

- [📖 About This Course](#-about-this-course)
- [⚡ Quick Start](#-quick-start)
- [🎯 Learning Path](#-learning-path)
- [📂 Repository Structure](#-repository-structure)
- [🛠️ Setup Guide](#️-setup-guide)
- [💡 Pro Tips for Beginners](#-pro-tips-for-beginners)
- [🤝 Contributing](#-contributing)

---

## 📖 About This Course

> **A complete, self-paced SQL curriculum** designed to take you from absolute beginner to writing complex, production-level queries — step by step, level by level.

Whether you're a data analyst, backend developer, or just curious about databases — this course has you covered. Every file is filled with **inline comments** that explain the *what* and the *why* of every query.

---

## ⚡ Quick Start

```sql
-- 1. Open MySQL Workbench
-- 2. Open: Level_1_Basics/01_database_and_tables.sql
-- 3. Press Ctrl + Shift + Enter to run the whole file
-- 4. Profit. 🎉
```

> ⚠️ **Always run levels in order** — later files depend on tables created in earlier ones!

---

## 🎯 Learning Path

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   🟢 BEGINNER         🟡 INTERMEDIATE          🔴 ADVANCED          │
│                                                                     │
│  Level 1 ──► Level 2 ──► Level 3 ──► Level 4 ──► Level 5           │
│     │             │            │            │            │           │
│   CREATE        WHERE &      COUNT &       JOINs       UNION &      │
│   TABLE        SORTING      GROUP BY                  SET OPS       │
│                                                                     │
│  Level 6 ──► Level 7 ──► Level 8 ──► Level 9 ──► Level 10          │
│     │             │            │            │            │           │
│  Subqueries    Views &      String       Window       Advanced      │
│   & CTEs     Temp Tables   Functions    Functions      Topics       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| # | Level | Topics Covered | Skill Unlocked |
|:-:|-------|----------------|----------------|
| 🟢 **1** | **Basics** | `CREATE` · `INSERT` · `SELECT` · `UPDATE` · `DELETE` | Build & populate tables |
| 🟢 **2** | **Filtering & Sorting** | `WHERE` · `LIKE` · `IN` · `BETWEEN` · `IS NULL` · `ORDER BY` · `DISTINCT` · `LIMIT` | Slice & dice data |
| 🟢 **3** | **Aggregate Functions** | `COUNT` · `SUM` · `AVG` · `MAX` · `MIN` · `GROUP BY` · `HAVING` · `CASE` | Summarize datasets |
| 🟡 **4** | **Joins** | `INNER` · `LEFT` · `RIGHT` · `FULL` · `SELF` · `CROSS JOIN` | Combine multiple tables |
| 🟡 **5** | **Set Operations** | `UNION` · `UNION ALL` · `INTERSECT` · `EXCEPT` | Merge query results |
| 🟡 **6** | **Subqueries & CTEs** | Subqueries · Derived Tables · Correlated · `WITH` | Nest & reuse logic |
| 🔴 **7** | **Views & Temp Tables** | `CREATE VIEW` · Temporary Tables · Table Copying | Reusable query objects |
| 🔴 **8** | **String Functions** | `TRIM` · `UPPER` · `LOWER` · `LENGTH` · `SUBSTRING` · `REPLACE` · `CONCAT` | Manipulate text data |
| 🔴 **9** | **Window & Ranking** | `ROW_NUMBER` · `RANK` · `DENSE_RANK` · `NTILE` · `LAG` · `LEAD` · `PARTITION BY` | Analytical power queries |
| 🔴 **10** | **Advanced Topics** | Stored Procedures · `CAST/CONVERT` · Dates · Transactions · Indexes · Normalization | Production-grade SQL |

---

## 📂 Repository Structure

```
📦 SQL-Basics-to-Advanced/
│
├── 📁 Level_1_Basics/
│   └── 01_database_and_tables.sql
├── 📁 Level_2_Filtering_Sorting/
│   └── 02_filtering_and_sorting.sql
├── 📁 Level_3_Aggregate_Functions/
│   └── 03_aggregate_functions.sql
├── 📁 Level_4_Joins/
│   └── 04_joins.sql
├── 📁 Level_5_Set_Operations/
│   └── 05_set_operations.sql
├── 📁 Level_6_Subqueries_CTEs/
│   └── 06_subqueries_and_ctes.sql
├── 📁 Level_7_Views_Temp_Tables/
│   └── 07_views_and_temp_tables.sql
├── 📁 Level_8_String_Functions/
│   └── 08_string_functions.sql
├── 📁 Level_9_Window_Ranking/
│   └── 09_window_ranking_functions.sql
├── 📁 Level_10_Advanced_Topics/
│   └── 10_advanced_topics.sql
│
└── 📄 README.md
```

---

## 🛠️ Setup Guide

### Step 1 — Open MySQL Workbench

Launch MySQL Workbench and click your local connection *(usually "Local instance MySQL")*. Enter your password if prompted.

### Step 2 — Open a SQL File

```
File > Open SQL Script
```

Browse to this folder and open `Level_1_Basics/01_database_and_tables.sql`

### Step 3 — Run the File

| Action | Windows / Linux | Mac |
|--------|:--------------:|:---:|
| Run **entire** file | `Ctrl + Shift + Enter` | `Cmd + Shift + Enter` |
| Run **one** statement | `Ctrl + Enter` | `Cmd + Enter` |

> 💡 Running **one statement at a time** is recommended for learning — great for seeing step-by-step output.

### Step 4 — Check Your Output

Results appear in the **Output panel** at the bottom. In the left **SCHEMAS** panel, expand `LearnSQL` to see your tables appear in real time.

> 📋 To inspect any table: **right-click** its name → **"Select Rows – Limit 1000"**

### Step 5 — Level Up 🚀

Complete each level before moving to the next. Always run `USE LearnSQL;` if you see schema errors.

---

## 💡 Pro Tips for Beginners

```sql
-- 💬 READ THE COMMENTS — lines starting with "--" explain everything
-- 🐢 DON'T RUSH — run one section at a time and study the output

-- 🔎 IF YOU SEE AN ERROR, check:
--     a) Did you run the earlier level files first?
--     b) Is your cursor inside the correct statement?
--     c) Is LearnSQL selected?  →  USE LearnSQL;

-- 📋 TO VIEW TABLE DATA ANYTIME:
--    Right-click any table in left panel → "Select Rows - Limit 1000"
```

> 🔑 **The secret to SQL mastery?** Write every query yourself. Don't just read — **type it, break it, fix it.**

---

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome!

1. **Fork** the repository
2. **Create** your branch: `git checkout -b feature/my-improvement`
3. **Commit** your changes: `git commit -m "Add: new SQL example for Level 4"`
4. **Push** to the branch: `git push origin feature/my-improvement`
5. **Open a Pull Request** 🎉

---

<div align="center">

**Made with ❤️ for SQL learners everywhere** · *Happy querying! 🎯*

</div>
