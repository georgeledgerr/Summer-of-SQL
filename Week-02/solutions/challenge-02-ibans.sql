/* =====================================================================
   Summer of SQL — Week 02 — Challenge 02
   ---------------------------------------------------------------------
   Title      : Preppin' Data 2023 Week 2 — International Bank Account
                Numbers
   Link       : https://preppindata.blogspot.com/2023/01/2023-week-2-international-bank-account.html
   Date       : 2026-07-11
   Tests      : REPLACE for substring removal, INNER JOIN as a lookup,
                string concatenation with ||
   Dialect    : Snowflake
   ===================================================================== */

-- Approach:
-- Join each transaction to its bank's SWIFT record, strip the dashes out
-- of the sort code with REPLACE, then build the IBAN by concatenating
-- country code + check digits + SWIFT code + sort code + account number.

/* ----------------------------------------------------------------------------
   INPUT: pd2023_wk02_transactions (transaction id, account number, sort
   code, bank) and pd2023_wk02_swift_codes (bank, swift code, check digits).
   (Challenge by Carl Allchin.)

   Requirements
     1. Remove the dashes from the Sort Code to leave a 6-digit string.
     2. Use the SWIFT lookup table to bring in each bank's SWIFT code
        and Check Digits.
     3. Add a Country Code field — 'GB' for every transaction, as all
        accounts are UK-based.
     4. Build the IBAN: Country Code + Check Digits + SWIFT code
        + Sort Code + Account Number.
     5. Remove unnecessary fields: output is Transaction ID and IBAN only
        (100 rows).
   ---------------------------------------------------------------------------- */

SELECT
    -- Req 5: only the transaction id and finished IBAN are kept.
    t.transaction_id,

    -- Reqs 1, 3 and 4 all happen inside the IBAN build:
    --   'GB' is the hardcoded country code (Req 3),
    --   REPLACE strips the dashes from the sort code (Req 1),
    --   || concatenates the parts and implicitly casts the numeric
    --   columns to text (Req 4). (+ is arithmetic only in Snowflake —
    --   it tries to cast 'GB' to a number and errors.)
    'GB' || sc.check_digits || sc.swift_code || REPLACE(t.sort_code, '-', '') || t.account_number AS IBAN

-- Req 2: the SWIFT codes table acts as the lookup, keyed on bank name.
FROM pd2023_wk02_transactions AS t
    INNER JOIN pd2023_wk02_swift_codes AS sc
        ON sc.bank = t.bank
;
