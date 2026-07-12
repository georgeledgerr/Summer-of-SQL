/* =====================================================================
   Summer of SQL — Week 03 — Challenge 04
   ---------------------------------------------------------------------
   Title      : Foodie-Fi, Section B Q6, Q7, Q11 — Plan transitions
   Link       : https://8weeksqlchallenge.com/case-study-3/
   Date       : 2026-07-12
   Tests      : LEAD, QUALIFY, percent of total, COALESCE
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- All three questions are about what a customer moved to next, so each
-- builds on LEAD over the full subscriptions table, partitioned by
-- customer and ordered by start_date, with filters applied afterwards.

-- Q6. Number and percentage of customer plans after the initial free
-- trial. Filtering to the trial row leaves one row per customer, whose
-- next_plan is what they chose after the trial.
WITH plan_after_freetrial AS (
    SELECT
        plan_id,
        LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
    FROM subscriptions
)
SELECT
    next_plan,
    COUNT(next_plan) AS customers,
    ROUND(100.0 * COUNT(next_plan) / SUM(COUNT(next_plan)) OVER (), 1) AS pct_of_total
FROM plan_after_freetrial
WHERE plan_id = 0
GROUP BY next_plan;

-- Returns (sums to 1000):
--   next_plan   customers   pct_of_total
--   1           546         54.6
--   3           37          3.7
--   2           325         32.5
--   4           92          9.2

-- Q7. Customer count and percentage breakdown of all 5 plan_name values
-- at 2020-12-31: each customer's latest row on or before the date.
-- Boundary is inclusive - a plan starting on the 31st is in force that day.
WITH snapshot_plan AS (
    SELECT
        s.customer_id,
        p.plan_name
    FROM plans AS p
    INNER JOIN subscriptions AS s ON p.plan_id = s.plan_id
    WHERE s.start_date <= '2020-12-31'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.start_date DESC) = 1
)
SELECT
    plan_name,
    COUNT(plan_name) AS customers,
    ROUND(100.0 * COUNT(plan_name) / SUM(COUNT(plan_name)) OVER (), 1) AS pct_of_total
FROM snapshot_plan
GROUP BY plan_name;

-- Returns (percentages sum to 100):
--   plan_name       customers   pct_of_total
--   trial           19          1.9
--   churn           236         23.6
--   basic monthly   224         22.4
--   pro monthly     326         32.6
--   pro annual      195         19.5

-- Q11. How many customers downgraded from pro monthly (2) to basic
-- monthly (1) in 2020? The downgrade is dated by the basic row's
-- start_date (when the change took effect), and LEAD runs before the
-- year filter so moves straddling the year end are still visible.
-- COALESCE returns an explicit 0 when no rows match.
WITH user_journey AS (
    SELECT
        plan_id,
        LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan,
        LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_start_date
    FROM subscriptions
)
SELECT COALESCE(SUM(CASE WHEN plan_id = 2 AND next_plan = 1 THEN 1 END), 0) AS downgrades_2020
FROM user_journey
WHERE YEAR(next_start_date) = 2020;

-- Returns: 0 (no customer made this downgrade)
