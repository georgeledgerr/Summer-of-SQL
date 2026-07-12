# Week 03 — notes

What I learned this week (Foodie-Fi, Section B):

* An aggregate on its own needs no GROUP BY - the clash only happens when mixing aggregates with row-level columns in one SELECT
* LAG and LEAD to read the previous/next row per customer (SQL's multi-row formula: PARTITION BY is the reset, ORDER BY inside OVER is the sort)
* CROSS JOIN to glue a one-row total onto a result (Append Fields in Alteryx terms)
* Percent of total with SUM(COUNT(...)) OVER () - window functions run after GROUP BY, so they can total the finished groups
* QUALIFY as Snowflake shorthand for the ROW\_NUMBER-in-a-CTE dedup pattern - a point-in-time snapshot is just latest-row-per-customer with ORDER BY date DESC
* If only the value is needed, MIN + GROUP BY; if the whole row is needed, rank it
* Binning with FLOOR(days / 30), building labels from the bucket number so bins never get typed out by hand
* WHERE runs before window functions, so a filter deletes rows before LAG/LEAD ever see them. Filtering to 2020 first meant LEAD couldn't see a next plan starting in 2021, silently hiding any downgrade that was near year end. Solution: compute the window over the full table in a CTE, then filter in the next step
* COALESCE to turn a NULL SUM into an explicit 0 when the true answer is zero
* Compare dates to full date literals, never partial strings like '2020'
* Only carry columns a later step actually needs, especially through joins - stray columns caused an ambiguous column error and hid a broken query

