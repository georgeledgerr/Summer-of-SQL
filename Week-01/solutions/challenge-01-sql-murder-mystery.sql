/* =====================================================================
   Summer of SQL — Week 01 — Challenge 01
   ---------------------------------------------------------------------
   Title      : SQL Murder Mystery (full solution, incl. bonus mastermind)
   Link       : https://mystery.knightlab.com
   Date       : 2026-07-11
   Tests      : filtering, wildcards (LIKE), ORDER BY + LIMIT,
                multi-table INNER JOINs, GROUP BY + HAVING
   Dialect    : SQLite (the challenge site's engine; rest of repo is Snowflake)
   ===================================================================== */

-- Approach:
-- Work the clues like a detective: recover the crime scene report, identify
-- the two witnesses, read their interviews, then chain every clue into one
-- multi-join query so a single row must satisfy ALL constraints. Repeat the
-- trick for the mastermind using GROUP BY + HAVING on event check-ins.

/* ----------------------------------------------------------------------------
   STEP 1 — Recover the crime scene report
   Filter the report table down to the one incident we care about: the murder,
   on the right date, in the right city.
   ---------------------------------------------------------------------------- */
SELECT *
FROM crime_scene_report
WHERE date = 20180115           -- date stored as a YYYYMMDD integer, not a date type
  AND type = 'murder'
  AND city = 'SQL City';
-- Description gives two witnesses:
--   Witness 1: lives in the LAST house on Northwestern Dr.
--   Witness 2: named Annabel, somewhere on Franklin Ave.


/* ----------------------------------------------------------------------------
   STEP 2 — Identify Witness 1 (last house on Northwestern Dr)
   "Last house" = highest street number, so sort descending and take the top row.
   ---------------------------------------------------------------------------- */
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;
-- Result: Morty Schapiro (person id 14887).


/* ----------------------------------------------------------------------------
   STEP 3 — Identify Witness 2 (Annabel on Franklin Ave)
   We know a first name and a street, which together are enough to pin her down.
   ---------------------------------------------------------------------------- */
SELECT *
FROM person
WHERE name LIKE 'Annabel%'                 -- wildcard: only her first name is known
  AND address_street_name = 'Franklin Ave';
-- Result: Annabel Miller (person id 16371).


/* ----------------------------------------------------------------------------
   STEP 4 — Read both witness interview transcripts
   Pull the interviews for the two person ids found above.
   ---------------------------------------------------------------------------- */
SELECT *
FROM interview
WHERE person_id IN (14887, 16371);   -- Morty (14887) and Annabel (16371)
-- Morty's statement:
--   -> Killer carried a "Get Fit Now" gym bag
--   -> Membership number began with "48Z"
--   -> Only GOLD members carry that style of bag
--   -> Killer left in a car whose plate contained "H42W"
-- Annabel's statement:
--   -> She recognised the killer from her gym
--   -> She was working out there on 9th January 2018


/* ----------------------------------------------------------------------------
   STEP 5 — Cross-reference every clue at once to find the killer
   Chain the tables so a single row must satisfy ALL constraints:
     check-in on Jan 9  ->  the membership used  ->  the person  ->  their licence.
   ---------------------------------------------------------------------------- */
SELECT p.name,                       -- who the killer is
       p.id,                         -- their person id (needed to submit + interview)
       m.id           AS membership_id, -- membership id from gym
       l.plate_number                -- plate number to identify and validate killer
FROM get_fit_now_check_in c
INNER JOIN get_fit_now_member   m ON c.membership_id = m.id   -- check-in -> membership
INNER JOIN person               p ON m.person_id     = p.id   -- membership -> person
INNER JOIN drivers_license      l ON p.license_id    = l.id   -- person -> driving licence
WHERE c.check_in_date = 20180109         -- the day Annabel saw the killer at the gym
  AND m.id LIKE '48Z%'                   -- membership number from Morty
  AND m.membership_status = 'gold'       -- only gold members carry the bag
  AND l.plate_number LIKE '%H42W%';      -- partial license plate from Morty
-- One person survives all four filters - Jeremy Bowers (person id 67318).


/* ----------------------------------------------------------------------------
   STEP 6 — Submit the killer to check the solution
   ---------------------------------------------------------------------------- */
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
SELECT value FROM solution;
-- Confirmation message reveals a BONUS: someone HIRED Jeremy. Find them.


/* ----------------------------------------------------------------------------
   STEP 7 — Read the killer's own interview for leads on his employer
   ---------------------------------------------------------------------------- */
SELECT *
FROM interview
WHERE person_id = 67318;   -- Jeremy Bowers
-- Jeremy describes the person who hired him:
--   -> Female, with RED hair.
--   -> About 5'5" - 5'7"  (height 65 - 67 inches).
--   -> Drives a Tesla Model S.
--   -> Attended the "SQL Symphony Concert" 3 times in December 2017.


/* ----------------------------------------------------------------------------
   STEP 8 — Identify the mastermind
   Each clue maps to a column. Need to use Group By and Having to count number of
   times the person went to SQL Symphony Concert
   ---------------------------------------------------------------------------- */
SELECT p.name,
       p.id
FROM drivers_license        l
JOIN person                 p ON p.license_id = l.id   -- licence -> person
JOIN facebook_event_checkin f ON f.person_id = p.id    -- person -> event check-ins
WHERE l.gender    = 'female'
  AND l.hair_color = 'red'
  AND l.car_make   = 'Tesla'
  AND l.car_model  = 'Model S'
  AND l.height BETWEEN 65 AND 67      -- 5'5" to 5'7", boundaries inclusive
  AND f.event_name = 'SQL Symphony Concert'
  AND f.date BETWEEN 20171201 AND 20171231   -- December 2017
GROUP BY p.id
HAVING COUNT(*) = 3;                   -- "attended 3 times" clue
-- Result: Miranda Priestly (person id 99716).
-- Note: COUNT(*) counts joined rows; if the data had duplicate same-day
-- check-ins, COUNT(DISTINCT f.date) = 3 would be the safer test.


/* ----------------------------------------------------------------------------
   STEP 9 — Submit the mastermind to close the case
   ---------------------------------------------------------------------------- */
INSERT INTO solution VALUES (1, 'Miranda Priestly');
SELECT value FROM solution;   -- final confirmation: case solved.

/* ============================================================================
   SOLVED.
     Killer     : Jeremy Bowers
     Mastermind : Miranda Priestly
   ============================================================================ */
