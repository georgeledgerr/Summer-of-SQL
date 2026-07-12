/* =====================================================================
   Summer of SQL — Week 02 — Challenge 04
   ---------------------------------------------------------------------
   Title      : Preppin' Data 2023 Week 4 — New Customers
   Link       : https://preppindata.blogspot.com/2023/01/2023-week-4-new-customers.html
   Date       : 2026-07-11
   Tests      : UNION ALL stacking, chained CTEs, DATE_FROM_PARTS, PIVOT,
                ROW_NUMBER + QUALIFY deduplication, type casting
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Stack the 12 monthly tables with UNION ALL, tagging each row with the
-- month its table represents (SQL has no wildcard union, so the label is
-- added by hand). Build the joining date from the day, month and year
-- parts, pivot the demographic rows into one column per demographic,
-- cast the types, then keep each repeat customer's earliest joining date
-- with a window function.

/* ----------------------------------------------------------------------------
   INPUT: pd2023_wk04_january ... pd2023_wk04_december — one table per
   month of 2023, each holding id, joining_day, demographic and value,
   with one row per customer per demographic. The joining month exists
   only in the table name. (Challenge by Carl Allchin.)

   Requirements
     1. Stack the 12 monthly tables into one.
     2. Create a Joining Date from the Joining Day, the table's month and
        the year 2023.
     3. Reshape so each demographic (Account Type, Date of Birth,
        Ethnicity) becomes its own field per customer.
     4. Make sure the data types are correct for each field.
     5. Remove duplicates: a customer appearing in several months keeps
        their earliest joining date.
     6. Output: id, joining date and the three demographics — 989 rows.
   ---------------------------------------------------------------------------- */

-- Req 1: no wildcard union in SQL, so each monthly table is selected and
-- tagged with its month by hand.
WITH cte AS (
    SELECT *, 'January'   AS joining_month, '2023' AS joining_year FROM pd2023_wk04_january
    UNION ALL
    SELECT *, 'February'  AS joining_month, '2023' AS joining_year FROM pd2023_wk04_february
    UNION ALL
    SELECT *, 'March'     AS joining_month, '2023' AS joining_year FROM pd2023_wk04_march
    UNION ALL
    SELECT *, 'April'     AS joining_month, '2023' AS joining_year FROM pd2023_wk04_april
    UNION ALL
    SELECT *, 'May'       AS joining_month, '2023' AS joining_year FROM pd2023_wk04_may
    UNION ALL
    SELECT *, 'June'      AS joining_month, '2023' AS joining_year FROM pd2023_wk04_june
    UNION ALL
    SELECT *, 'July'      AS joining_month, '2023' AS joining_year FROM pd2023_wk04_july
    UNION ALL
    SELECT *, 'August'    AS joining_month, '2023' AS joining_year FROM pd2023_wk04_august
    UNION ALL
    SELECT *, 'September' AS joining_month, '2023' AS joining_year FROM pd2023_wk04_september
    UNION ALL
    SELECT *, 'October'   AS joining_month, '2023' AS joining_year FROM pd2023_wk04_october
    UNION ALL
    SELECT *, 'November'  AS joining_month, '2023' AS joining_year FROM pd2023_wk04_november
    UNION ALL
    SELECT *, 'December'  AS joining_month, '2023' AS joining_year FROM pd2023_wk04_december
),

-- Req 2, plus prep for the pivot: PIVOT treats every column it isn't
-- told to consume as row identity, so this trims the table down to
-- exactly (identity) + (pivot column) + (value column).
prepared AS (
    SELECT
        id,
        -- TO_DATE with the 'MMMM' mask parses the month name, MONTH
        -- pulls the 1-12 out, and DATE_FROM_PARTS assembles the date
        -- from the three numeric parts.
        DATE_FROM_PARTS(joining_year, MONTH(TO_DATE(joining_month, 'MMMM')), joining_day) AS joining_date,
        demographic,
        value
    FROM cte
)

SELECT
    id,
    joining_date,
    account_type,
    -- Req 4: value held all three demographics, so everything came out
    -- of the pivot as text; date of birth needs to be a real date.
    TO_DATE(date_of_birth) AS date_of_birth,
    ethnicity

-- Req 3: PIVOT consumes the demographic column (values become the new
-- column headers) and the value column (contents fill them). MAX is
-- only there because PIVOT requires an aggregate — one value per
-- customer per demographic means it passes straight through. The alias
-- list renames the output columns.
FROM prepared
    PIVOT (MAX(value) FOR demographic IN ('Account Type', 'Date of Birth', 'Ethnicity'))
        AS p (id, joining_date, account_type, date_of_birth, ethnicity)

-- Req 5: number each customer's rows earliest joining date first, keep
-- only row 1.
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY joining_date ASC) = 1
;
