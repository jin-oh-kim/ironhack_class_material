-- Selecting and column transformations

-- Casting
SELECT 
    loan_id,
    account_id,
    loan_id + account_id AS sum_id,
    CAST(loan_id AS CHAR) AS loan_id_text,
    CAST(account_id AS CHAR) AS account_id_text,
    CONCAT(CAST(loan_id AS CHAR), CAST(account_id AS CHAR)) AS loan_account_sum
FROM bank.loan
LIMIT 100;

-- Decoding, translating
SELECT 
    loan_id,
    account_id,
    IF(account_id <= 5000, 'lower', 'upper') AS account_id_range
FROM bank.loan
LIMIT 100;

-- CASE statements
SELECT 
    loan_id,
    account_id,
    IF(account_id <= 5000, 'lower', IF(account_id <= 10000, 'middle', 'upper')) AS anything,
    CASE 
        WHEN account_id <= 5000 THEN 'lower'
        WHEN account_id <= 10000 THEN 'middle'
        ELSE 'upper'
    END AS whatever
FROM bank.loan
LIMIT 100;

------- GROUP BY!!!! OR DISTINCT

SELECT DISTINCT frequency AS unique_frequencies
FROM account;

SELECT DISTINCT 
    frequency, 
    date
FROM account;

-- equivalent to

SELECT frequency
FROM account
GROUP BY frequency;

SELECT
    frequency,
    date
FROM account
GROUP BY 
    frequency,
    date;

-- AGG function

SELECT
    COUNT(*)                    AS no_rows,
    COUNT(frequency)            AS no_of_frequencies,
    COUNT(1)                    AS no_of_ones,
    COUNT(DISTINCT frequency)   AS no_of_distinct_freqs,
    COUNT(DISTINCT 1000)        AS no_of_distinct_ones
FROM account;

SELECT *
FROM trans
LIMIT 10;

SELECT
    COUNT(DISTINCT trans_id) AS no_of_transactions
FROM trans
LIMIT 10;

SELECT
    CAST(SUM(amount) AS UNSIGNED) AS total_amount
FROM trans;

-- Grouping with agg functions

SELECT
    CASE
        WHEN type = 'PRIJEM'
            THEN 'CREDIT'
        WHEN type = 'VYDAJ'
            THEN 'DEBIT'
        WHEN type = 'VYBER'
            THEN 'CREDIT CARD'
    END                 AS type_english,
    SUM(amount)         AS total_amount,
    COUNT(*)            AS no_of_rows
FROM trans
GROUP BY 1;

SELECT *
FROM trans 
LIMIT 100;


SELECT
    CASE
        WHEN type = 'PRIJEM'
            THEN 'CREDIT'
        WHEN type = 'VYDAJ'
            THEN 'DEBIT'
        WHEN type = 'VYBER'
            THEN 'CREDIT CARD'
    END                 AS type_english,
    CAST(SUM(amount) AS SIGNED) AS total_amount,
    COUNT(1)            AS no_of_rows,
    SUM(1)              AS no_of_rows_as_well
FROM trans
GROUP BY type_english
ORDER BY total_amount;

SELECT
    CASE
        WHEN type = 'PRIJEM'
            THEN 'CREDIT'
        WHEN type = 'VYDAJ'
            THEN 'DEBIT'
        WHEN type = 'VYBER'
            THEN 'CREDIT CARD'
    END                 AS type_english,
    FLOOR(SUM(amount))  AS total_amount,
    COUNT(1)            AS no_of_rows,
    SUM(1)              AS no_of_rows_as_well
FROM trans
GROUP BY type_english
ORDER BY total_amount;

SELECT *
FROM trans
LIMIT 100;

SELECT DISTINCT type, operation
FROM trans
ORDER BY 1,2;

SELECT COUNT(*)
FROM trans
WHERE operation = '';

SELECT
    type,
    operation,
    CAST(SUM(amount) AS UNSIGNED)   AS total_amount,
    COUNT(1)                        AS no_of_rows
FROM trans
GROUP BY
    type,
    operation
ORDER BY 1,2;
