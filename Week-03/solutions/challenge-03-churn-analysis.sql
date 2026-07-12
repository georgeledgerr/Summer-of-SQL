/* =====================================================================
   Summer of SQL — Week 03 — Challenge 03
   ---------------------------------------------------------------------
   Title      : Foodie-Fi, Section B Q4-Q5 — Churn analysis
   Link       : https://8weeksqlchallenge.com/case-study-3/
   Date       : 2026-07-12
   Tests      : chained CTEs, CROSS JOIN, LAG, CASE flags, percentages
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Both questions divide a churn figure by the customer total, so the
-- total sits in its own one-row CTE and is attached with a CROSS JOIN.
-- Q5 flags churn rows whose previous plan was the trial, then sums the
-- flags in a separate step.

-- Q4. Customer count and percentage of customers who have churned,
-- rounded to 1 decimal place.
WITH count_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM subscriptions
),
count_churn AS (
    SELECT COUNT(DISTINCT customer_id) AS churned_customers
    FROM subscriptions
    WHERE plan_id = 4
)
SELECT
    cc.churned_customers,
    ROUND(100.0 * cc.churned_customers / tc.total_customers, 1) AS churn_percentage
FROM count_churn AS cc
CROSS JOIN count_customers AS tc;

-- Returns: 307 churned customers, 30.7%

-- Q5. How many customers churned straight after their free trial, and
-- what percentage is this rounded to the nearest whole number?
WITH count_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM subscriptions
),
count_freetrial_churn AS (
    SELECT
        plan_id,
        LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan,
        CASE WHEN plan_id = 4 AND prev_plan = 0 THEN 1 END AS freetrial_churn_customer
    FROM subscriptions
),
sum_freetrial_churn AS (
    SELECT SUM(freetrial_churn_customer) AS count_freetrial_churn
    FROM count_freetrial_churn
)
SELECT
    sf.count_freetrial_churn,
    ROUND(100.0 * sf.count_freetrial_churn / tc.total_customers, 0) AS freetrial_churn_percentage
FROM sum_freetrial_churn AS sf
CROSS JOIN count_customers AS tc;

-- Returns: 92 customers, 9%
