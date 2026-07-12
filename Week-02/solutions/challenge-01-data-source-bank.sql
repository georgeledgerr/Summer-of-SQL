/* =====================================================================
   Summer of SQL — Week 02 — Challenge 01
   ---------------------------------------------------------------------
   Title      : Preppin' Data 2023 Week 1 — The Data Source Bank
   Link       : https://preppindata.blogspot.com/2023/01/2023-week-1-data-source-bank.html
   Date       : 2026-07-11
   Tests      : string splitting (SPLIT_PART), CASE recoding, date parsing
                with format masks, DAYNAME, multi-level GROUP BY
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Build the three derived fields once at row level (bank prefix, channel
-- label, weekday), then aggregate the same logic at three grains: by bank,
-- by bank/day/channel, and by bank/customer.

/* ----------------------------------------------------------------------------
   INPUT: pd2023_wk01 — one table of bank transactions, containing DSB's
   transactions mixed in with other banks'. (Challenge by Carl Allchin.)

   Requirements
     1. Split the Transaction Code to extract the bank prefix -> 'Bank'.
     2. Recode Online or In-person: 1 -> 'Online', 2 -> 'In-Person'.
     3. Change the transaction date to the day of the week.
     4. Aggregate transaction values at three levels of detail:
          Output 1 — Total value by Bank
          Output 2 — Total value by Bank, Day of Week and Transaction Type
          Output 3 — Total value by Bank and Customer Code
   ---------------------------------------------------------------------------- */


/* ----------------------------------------------------------------------------
   STEP 1 — DATA PREPARATION (Requirements 1–3)
   Row-level query that builds all three derived fields, keeping one row per
   transaction. This is the "cleaned" view of the data before any aggregation.
   ---------------------------------------------------------------------------- */
SELECT *,
       -- Req 1: transaction codes look like 'DSB-746-...'; everything before
       -- the first '-' identifies the processing bank.
       SPLIT_PART(transaction_code, '-', 1) AS Bank,

       -- Req 2: recode the numeric flag into readable labels.
       CASE
           WHEN online_or_in_person = 1 THEN 'Online'
           WHEN online_or_in_person = 2 THEN 'In-Person'
           ELSE ''                              -- catch-all for unexpected values
       END AS Channel,

       -- Req 3: transaction_date is stored as TEXT in 'DD/MM/YYYY HH24:MI:SS'
       -- format, so it must be parsed with an explicit format mask before
       -- DAYNAME can extract the weekday (e.g. 'Mon', 'Tue').
       DAYNAME(DATE(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) AS day_of_week
FROM pd2023_wk01;


/* ----------------------------------------------------------------------------
   OUTPUT 1 — Total Values of Transactions by each Bank  (3 rows)
   One row per bank; SUM(value) collapses every transaction into a bank total.
   ---------------------------------------------------------------------------- */
SELECT SPLIT_PART(transaction_code, '-', 1) AS Bank,   -- grouping dimension
       SUM(value)                           AS total_value
FROM pd2023_wk01
GROUP BY Bank;


/* ----------------------------------------------------------------------------
   OUTPUT 2 — Total Values by Bank, Day of Week and Transaction Type  (42 rows)
   Three grouping dimensions this time.
   ---------------------------------------------------------------------------- */
SELECT SPLIT_PART(transaction_code, '-', 1) AS Bank,
       CASE
           WHEN online_or_in_person = 1 THEN 'Online'
           WHEN online_or_in_person = 2 THEN 'In-Person'
           ELSE ''
       END                                  AS Channel,
       DAYNAME(DATE(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) AS DayOfWeek,
       SUM(value)                           AS total_value
FROM pd2023_wk01
GROUP BY Bank, Channel, DayOfWeek;          -- Snowflake allows grouping by alias


/* ----------------------------------------------------------------------------
   OUTPUT 3 — Total Values by Bank and Customer Code  (33 rows)
   GROUP BY 1, 2 groups by SELECT-list position (1 = Bank, 2 = customer_code).
   ---------------------------------------------------------------------------- */
SELECT SPLIT_PART(transaction_code, '-', 1) AS Bank,
       customer_code,
       SUM(value)                           AS total_value
FROM pd2023_wk01
GROUP BY 1, 2;

/* ============================================================================
   NOTES
   * The three outputs deliberately repeat the SPLIT_PART / CASE / DAYNAME
     logic rather than reusing Step 1, keeping each output self-contained and
     runnable on its own. An alternative is to wrap Step 1 in a CTE and have
     each output SELECT from it — same results, less repetition.
   ============================================================================ */
