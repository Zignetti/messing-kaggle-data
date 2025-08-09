# 🎟️ Tour Revenue Dataset Cleaning 

## 📌 Project Objective

This project focuses on cleaning a messy, semi-structured dataset sourced from Kaggle. 
The data contains world tour gross revenues for major music artists, but includes:
- Encoding issues (e.g., `â€`, `Ã©`)
- Inconsistent or missing ranks
- Unstructured text annotations (e.g., `[4]`, `[a]`, `¡`)
- Non-numeric values in financial and count columns

The goal is to produce a clean, structured SQL table suitable for analysis and visualization.

---

## 🗂️ Dataset Summary

- **Source**: Kaggle
- **Initial Table**: `kaggle.dirty`
- **Cleaned Table**: `cleanTable`
- **Row Count**: 18
- **Initial Columns**: 11 (including ranking, gross revenue, artist, tour title, year range, show count, references)

---

## 🧼 Cleaning Workflow Summary

### 1. Clone Original Table
``` sql
CREATE TABLE clean
LIKE dirty;
```


INSERT INTO clean
``` sql
SELECT *
FROM dirty;
```

---


### 2. Inspect Table Structure
- count the number of rows and columns


### 3. Check for Missing Values
Used conditional counts to detect empty or NULL values in key columns.
Dropped peak and all_time_peak due to high missing rates.

### 4. Rank Column
Recalculated ranks based on descending adjustedGross2022 values using ROW_NUMBER().

### 5. Revenue Columns
Cleaned and cast to DECIMAL(15,2):
- actualGross
- adjustedGross2022

### 6. Text Cleaning
Removed corrupted encodings and bracketed annotations:
- artist: fixed Ã©, ©, etc.
- tourtitle: removed â€, [4], [a], ¡, *, [21]

### 7. Year Column
Split year into:
- start_year
- end_year

### 8. Show Counts
Trimmed and casted Shows to UNSIGNED INT after filtering numeric values.

### 9. Average Gross
Cleaned $, commas, and casted to DECIMAL(15,2).

### 10. Reference Column
Removed square brackets from ref. for clarity

## ✅ Final Clean Table: cleanTable
``` sql
SELECT
  ROW_NUMBER() OVER (ORDER BY CAST(REPLACE(REPLACE(adjustedGross2022, '$', ''), ',', '') AS DECIMAL) DESC) AS new_rank,
  CAST(REPLACE(REPLACE(actualGross,'$',''),',','') AS DECIMAL(15,2)) AS actual_gross,
  CAST(REPLACE(REPLACE(adjustedGross2022,'$',''),',','') AS DECIMAL(15,2)) AS adjusted_gross_2022,
  REPLACE(REPLACE(artist,'Ã','e'),'©','') AS artist_name,
  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tourtitle,'â',''),'€',''),'[4]',''),'[a]',''),'¡',''),'*',''),'[21]','') AS tour_title,
  REGEXP_SUBSTR(year, '[0-9]{4}') AS start_year,
  REGEXP_SUBSTR(year,'[0-9]{4}$') AS end_year,
  CAST(Shows AS UNSIGNED) AS countShows,
  CAST(REPLACE(REPLACE(averageGross,'$',''),',','') AS DECIMAL(15,2)) AS avg_gross,
  REPLACE(REPLACE(`ref.`,'[',''),']','') AS ref
FROM clean;
```


## 📌 Notes & Assumptions
- Encoding fixes targeted known corrupted characters only
- Bracketed footnote annotations assumed unnecessary
- New rank replaces original inconsistent values
- Final table focuses on analysis-ready numeric and text fields

## 📊 Next Steps
- Exploratory data analysis: Top grossing tours by artist/year
- Trend visualization
- Optional merging with external datasets (e.g. inflation rates, industry benchmarks)



