/* =====================================================================
   Summer of SQL — Week 03 — Challenge 01
   ---------------------------------------------------------------------
   Title      : Foodie-Fi, Section A — Customer journey
   Link       : https://8weeksqlchallenge.com/case-study-3/
   Date       : 2026-07-12
   Tests      : joins, ordering events into journeys
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Pull the 8 sample customers' subscription rows in date order, with the
-- plan name joined on for readability, then describe each journey.

SELECT
    s.customer_id,
    p.plan_name,
    s.start_date
FROM plans AS p
INNER JOIN subscriptions AS s ON p.plan_id = s.plan_id
WHERE s.customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY s.customer_id, s.start_date ASC;

-- Journeys:
-- Customer 1  - trialled, then settled on the basic monthly plan.
-- Customer 2  - went straight from the trial to pro annual.
-- Customer 11 - trialled and cancelled at the end of the week, never
--               taking a paid plan.
-- Customer 13 - started on basic monthly after the trial, later
--               upgrading to pro monthly.
-- Customer 15 - moved onto pro monthly after the trial but churned just
--               over a month in.
-- Customer 16 - took basic monthly after the trial, eventually
--               upgrading to pro annual.
-- Customer 18 - converted from trial to pro monthly and stayed there.
-- Customer 19 - went from trial to pro monthly, then up to pro annual.
