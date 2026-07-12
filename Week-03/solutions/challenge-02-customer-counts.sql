/* =====================================================================
   Summer of SQL — Week 03 — Challenge 02
   ---------------------------------------------------------------------
   Title      : Foodie-Fi, Section B Q1-Q3 — Customer counts
   Link       : https://8weeksqlchallenge.com/case-study-3/
   Date       : 2026-07-12
   Tests      : COUNT DISTINCT, DATE_TRUNC, joins, GROUP BY
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Straight aggregations over subscriptions, joined to plans where the
-- plan name is needed.

/* ----------------------------------------------------------------------------
   INPUT: plans maps plan_id to plan_name and price (0 trial, 1 basic
   monthly, 2 pro monthly, 3 pro annual, 4 churn). subscriptions has one
   row per customer per plan change, dated when the change takes effect.
   Every customer begins with a 7-day free trial.
   ---------------------------------------------------------------------------- */

-- Q1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

-- Returns: 1000

-- Q2. What is the monthly distribution of trial plan start_date values,
-- grouped by the start of the month?
SELECT
    DATE_TRUNC('month', s.start_date) AS month_start,
    COUNT(p.plan_name) AS trial_starts
FROM plans AS p
INNER JOIN subscriptions AS s ON p.plan_id = s.plan_id
WHERE p.plan_name = 'trial'
GROUP BY month_start
ORDER BY month_start ASC;

-- Returns (sums to 1000 - every customer trialled once, all in 2020):
--   month_start   trial_starts
--   2020-01-01    88
--   2020-02-01    68
--   2020-03-01    94
--   2020-04-01    81
--   2020-05-01    88
--   2020-06-01    79
--   2020-07-01    89
--   2020-08-01    88
--   2020-09-01    87
--   2020-10-01    79
--   2020-11-01    75
--   2020-12-01    84

-- Q3. What plan start_date values occur after the year 2020? Breakdown
-- by count of events for each plan_name.
-- Trial excluded explicitly, though no trials start after 2020 anyway.
SELECT
    p.plan_name,
    COUNT(p.plan_name) AS events
FROM plans AS p
INNER JOIN subscriptions AS s ON p.plan_id = s.plan_id
WHERE YEAR(s.start_date) > 2020
    AND p.plan_id != 0
GROUP BY p.plan_name;

-- Returns:
--   plan_name       events
--   pro annual      63
--   basic monthly   8
--   churn           71
--   pro monthly     60
