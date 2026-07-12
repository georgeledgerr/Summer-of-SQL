/* =====================================================================
   Summer of SQL — Week 02 — Challenge 03
   ---------------------------------------------------------------------
   Title      : Preppin' Data 2023 Week 3 — Targets for DSB
   Link       : https://preppindata.blogspot.com/2023/01/2023-week-3-targets-for-dsb.html
   Date       : 2026-07-11
   Tests      : CTEs, UNPIVOT, QUARTER/TO_DATE date handling, CASE
                recoding, aggregation, multi-condition joins
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Build DSB's actuals in a CTE: filter to DSB transactions, recode the
-- channel flag, bucket each transaction into its quarter and sum values.
-- Then unpivot the wide quarterly targets table into one row per channel
-- and quarter, and join it to the actuals on both channel and quarter to
-- compare performance against target.

/* ----------------------------------------------------------------------------
   INPUT: pd2023_wk01 — the Week 1 transactions table (transaction code,
   online_or_in_person flag, transaction date, value) and
   pd2023_wk03_targets — quarterly targets, one row per channel with a
   column per quarter (Q1-Q4). (Challenge by Jenny Martin.)

   Requirements
     1. Filter to DSB's transactions only ('DSB' in the transaction code).
     2. Recode Online or In-Person: 1 -> 'Online', 2 -> 'In-Person'.
     3. Convert the transaction date to a quarter.
     4. Sum transaction values per quarter and transaction type.
     5. Unpivot the quarterly targets so there is one row per transaction
        type and quarter, and make the quarter numeric (strip the 'Q').
     6. Join actuals to targets on transaction type AND quarter.
     7. Calculate the Variance to Target for each row.
   ---------------------------------------------------------------------------- */

-- Actuals: DSB's total transaction value per channel per quarter.
WITH wk01 AS (
    SELECT
        -- Req 2: recode the numeric flag into readable labels.
        CASE
            WHEN online_or_in_person = 1 THEN 'Online'
            WHEN online_or_in_person = 2 THEN 'In-Person'
            ELSE ''
        END AS online_or_in_person,

        -- Req 3: parse the text date with a format mask, then take the
        -- quarter (1-4).
        QUARTER(TO_DATE(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) AS quarter,

        -- Req 4: one summed value per channel/quarter group.
        SUM(value) AS total_value
    FROM pd2023_wk01
    -- Req 1: DSB's transactions carry 'DSB' in the transaction code.
    WHERE CONTAINS(transaction_code, 'DSB')
    GROUP BY quarter, online_or_in_person
)

SELECT
    t.online_or_in_person,

    -- Req 5 (part 2): the unpivoted quarter labels are 'Q1'-'Q4'; keep
    -- the last character and cast it so it matches the numeric quarter
    -- in the actuals.
    TO_NUMBER(RIGHT(t.quarter, 1)) AS quarter,

    v.total_value,
    t.target,

    -- Req 7: positive = beat the target, negative = missed it.
    v.total_value - t.target AS variance_to_target

-- Req 5 (part 1): UNPIVOT rotates the Q1-Q4 columns into rows, giving
-- one (channel, quarter label, target) row per original cell.
FROM pd2023_wk03_targets
    UNPIVOT (target FOR quarter IN (Q1, Q2, Q3, Q4)) AS t

    -- Req 6: both conditions are needed — joining on channel alone would
    -- match every quarter to every other quarter.
    INNER JOIN wk01 AS v
        ON t.online_or_in_person = v.online_or_in_person
        AND TO_NUMBER(RIGHT(t.quarter, 1)) = v.quarter
;

-- Returns: 8 rows (2 channels x 4 quarters). DSB beat target in 5 of 8,
-- with one big miss: In-Person Q4 at -16,777.
--   online_or_in_person   quarter   total_value   target   variance_to_target
--   In-Person             1         77,576        75,000    2,576
--   In-Person             2         70,634        70,000    634
--   In-Person             3         74,189        70,000    4,189
--   In-Person             4         43,223        60,000   -16,777
--   Online                1         74,562        72,500    2,062
--   Online                2         69,325        70,000   -675
--   Online                3         59,072        60,000   -928
--   Online                4         61,908        60,000    1,908
