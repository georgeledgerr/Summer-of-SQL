/* =====================================================================
   Summer of SQL — Week 03 — Challenge 05
   ---------------------------------------------------------------------
   Title      : Foodie-Fi, Section B Q8-Q10 — Annual plan upgrades
   Link       : https://8weeksqlchallenge.com/case-study-3/
   Date       : 2026-07-12
   Tests      : MIN + GROUP BY, DATEDIFF, AVG, FLOOR binning
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Q9 and Q10 share a pipeline: each customer's join date (earliest
-- subscription row), inner joined to their pro annual row, DATEDIFF
-- between the two. The inner join drops non-upgraders, which is the
-- population both questions want. Q9 averages the result; Q10 bins it
-- into 30-day periods.

-- Q8. How many customers upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS annual_upgrades_2020
FROM subscriptions
WHERE plan_id = 3
    AND YEAR(start_date) = 2020;

-- Returns: 195

-- Q9. How many days on average does it take a customer to move to an
-- annual plan from the day they join?
WITH start_date_customers AS (
    SELECT
        customer_id,
        MIN(start_date) AS join_date
    FROM subscriptions
    GROUP BY customer_id
),
annual_plan_customers AS (
    SELECT
        customer_id,
        start_date AS annual_date
    FROM subscriptions
    WHERE plan_id = 3
),
date_diff_plans AS (
    SELECT
        sdc.customer_id,
        DATEDIFF(day, sdc.join_date, apc.annual_date) AS date_diff
    FROM start_date_customers AS sdc
    INNER JOIN annual_plan_customers AS apc ON sdc.customer_id = apc.customer_id
)
SELECT ROUND(AVG(date_diff)) AS avg_days_to_annual_plan
FROM date_diff_plans;

-- Returns: 105 days

-- Q10. Breakdown of the same value into 30 day periods (0-30 days,
-- 31-60 days, etc). Bucket 0 covers days 0-29, bucket 1 covers 30-59,
-- and each label is derived from the bucket number.
WITH start_date_customers AS (
    SELECT
        customer_id,
        MIN(start_date) AS join_date
    FROM subscriptions
    GROUP BY customer_id
),
annual_plan_customers AS (
    SELECT
        customer_id,
        start_date AS annual_date
    FROM subscriptions
    WHERE plan_id = 3
),
date_diff_plans AS (
    SELECT
        sdc.customer_id,
        DATEDIFF(day, sdc.join_date, apc.annual_date) AS date_diff
    FROM start_date_customers AS sdc
    INNER JOIN annual_plan_customers AS apc ON sdc.customer_id = apc.customer_id
)
SELECT
    FLOOR(date_diff / 30) AS bucket,
    FLOOR(date_diff / 30) * 30 || '-' || (FLOOR(date_diff / 30) + 1) * 30 || ' days' AS period,
    COUNT(*) AS customers
FROM date_diff_plans
GROUP BY bucket
ORDER BY bucket;

-- Returns (sums to 258 annual upgraders):
--   bucket   period          customers
--   0        0-30 days       48
--   1        30-60 days      25
--   2        60-90 days      33
--   3        90-120 days     35
--   4        120-150 days    43
--   5        150-180 days    35
--   6        180-210 days    27
--   7        210-240 days    4
--   8        240-270 days    5
--   9        270-300 days    1
--   10       300-330 days    1
--   11       330-360 days    1
