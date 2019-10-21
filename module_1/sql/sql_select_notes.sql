SELECT *
FROM bank.account
LIMIT 10;

SELECT *
FROM bank.card
LIMIT 10;

/*
I'm a comment block
*/

SELECT -- project only the two columns card_id and disp_id
    card_id,
    disp_id
FROM bank.card
LIMIT 10; -- project only the first 10 rows

SELECT 
    duration,
    payments,
    `status`
FROM bank.loan
LIMIT 20;

SELECT *
FROM bank.loan
LIMIT 10;

-----

-- Sorting output

SELECT 
    loan_id,
    account_id,
    amount
FROM bank.loan
ORDER BY amount DESC
LIMIT 10;

SELECT *
FROM bank.trans
LIMIT 10;

SELECT
    account_id
FROM bank.trans
ORDER BY amount ASC
LIMIT 10;

---- Selection (Filtering)

SELECT
    account_id      AS accountttt,
    amount          AS transaction_amount,
    balance         AS bank_balance
FROM bank.trans
WHERE account_id = 1972
ORDER BY date;

SELECT 
    trans_id,
    account_id,
    amount
FROM bank.trans
WHERE 
    amount < 5000
    AND amount >= 5
    AND account_id = 1972 
ORDER BY amount DESC
LIMIT 10;