USE bank;

-- check out some of the tables we're gonna use
SELECT *
FROM loan
LIMIT 100;


SELECT *
FROM trans
LIMIT 100;

--
-- transaction volume and number of transactions for each date before 930104, but only if transaction volume > 2000
--

SELECT
    date,
    SUM(amount) AS transaction_volume,
    COUNT(*)    AS no_of_transactions
FROM trans
WHERE date < 930104
GROUP BY
    date
HAVING transaction_volume > 2000
ORDER BY
    date;
--
-- transaction_volume for each account_id and day before 930104
--

SELECT
    account_id,
    date,
    SUM(amount) AS transaction_volume,
    COUNT(*)    AS no_of_transactions
FROM trans
WHERE date < 930104
GROUP BY
    account_id,
    date
ORDER BY
    account_id,
    date;


SELECT
    date,
    SUM(amount) AS transaction_volume,
    COUNT(*)    AS no_of_transactions
FROM trans
WHERE date < 930104
GROUP BY
    date
HAVING transaction_volume > 2000
ORDER BY
    date;

--
-- Number of accounts per region
--

-- check if account_ids are unique
SELECT
    COUNT(*),
    COUNT(DISTINCT account_id)
FROM account;

-- snapshots
SELECT *
FROM account
LIMIT 1000;

SELECT * 
FROM district 
LIMIT 1000;

-- create temp table with proper aliases for districts
CREATE TEMPORARY TABLE dim_district AS (
SELECT
    A1  AS district_id,
    A3  AS region
FROM district);

-- perform join to add region to account table
SELECT
    a.account_id,
    a.district_id,
    dd.district_id,
    dd.region
FROM account a
    INNER JOIN dim_district dd
    ON a.district_id = dd.district_id
LIMIT 1000;

-- only use the columns that we actually need
SELECT
    a.account_id,
    dd.region
FROM account a
    INNER JOIN dim_district dd
    ON a.district_id = dd.district_id
LIMIT 1000;

-- putting it together
SELECT
    dd.region,
    COUNT(*) AS no_of_accounts
FROM account a
    INNER JOIN dim_district dd
    ON a.district_id = dd.district_id
GROUP BY dd.region;

--
-- Which region has most accounts?
--

SELECT
    dd.region,
    COUNT(*) AS no_of_accounts
FROM account a
    INNER JOIN dim_district dd
    ON a.district_id = dd.district_id
GROUP BY dd.region
ORDER BY no_of_accounts DESC
LIMIT 1;

-- now, do this without our temp table dim_district, but with the actual district table
SELECT
    d.A3        AS region,
    COUNT(*)    AS no_of_accounts
FROM account a
    INNER JOIN district d
    ON a.district_id = d.A1
GROUP BY d.A3
ORDER BY no_of_accounts DESC
LIMIT 1;

--
-- get average transaction amount for each transaction type and region
-- 

SELECT * FROM trans LIMIT 1000;

SELECT DISTINCT type
FROM trans;

SELECT *
FROM account
LIMIT 1000;

SELECT *
FROM district;

-- Approach 1: Using two joins
SELECT
    d.A3                    AS region,
    t.type                  AS transaction_type,
    FLOOR(AVG(t.amount))    AS average_transaction_amount
FROM trans t
    INNER JOIN account a
    ON t.account_id = a.account_id
        INNER JOIN district d
        ON d.A1 = a.district_id
WHERE t.account_id < 1000
GROUP BY
    region,
    transaction_type;

-- Approach 2: Using subqueries to first merge the account and district table
SELECT
    r.region,
    t.type                  AS transaction_type,
    FLOOR(AVG(t.amount))    AS average_transaction_amount
FROM trans t
    JOIN (
        SELECT
            a.account_id,
            d.A3            AS region
        FROM account a
            JOIN district d
            ON a.district_id = d.A1) r
    ON t.account_id = r.account_id
WHERE t.account_id < 1000
GROUP BY
    r.region,
    t.type;

-- Approach 3: Using CTEs (Common table expressions), aka the WITH clause
WITH prefiltered_account AS (
    SELECT *
    FROM account
    WHERE account_id < 1000),

region AS (
    SELECT
        a.account_id,
        d.A3            AS region
    FROM prefiltered_account a
        JOIN district d
        ON a.district_id = d.A1)

SELECT
    r.region,
    t.type                  AS transaction_type,
    FLOOR(AVG(t.amount))    AS average_transaction_amount
FROM trans t
    JOIN region r
    ON t.account_id = r.account_id
GROUP BY
    r.region,
    t.type;

-- Approach 4: Using temporary tables

CREATE TEMPORARY TABLE prefiltered_account AS (
    SELECT *
    FROM account
    WHERE account_id < 1000);

CREATE TEMPORARY TABLE region (
    SELECT
        a.account_id,
        d.A3            AS region
    FROM prefiltered_account a
        JOIN district d
        ON a.district_id = d.A1);

SELECT
    r.region,
    t.type                  AS transaction_type,
    FLOOR(AVG(t.amount))    AS average_transaction_amount
FROM trans t
    JOIN region r
    ON t.account_id = r.account_id
GROUP BY
    r.region,
    t.type;

--
-- Gender Split (in %) of account owners for accounts that have or have no loans linked to them
--

-- first, create a temp table that extracts gender info from birth_number (see documentation)
CREATE TEMPORARY TABLE client_gender AS (
    SELECT
        client_id,
        IF(RIGHT(LEFT(birth_number,4),2) > 12, 'F', 'M') AS gender
    FROM client);

SELECT *
FROM disp
LIMIT 1000;

SELECT type
FROM disp
GROUP BY type;

SELECT
    client_id,
    COUNT(account_id)
FROM disp
GROUP BY 1
HAVING COUNT(account_id) > 1;

-- enrich the disp table with gender info 
CREATE TEMPORARY TABLE account_owner_gender AS (
    SELECT
        d.client_id,
        d.account_id,
        cg.gender
    FROM disp d
        JOIN client_gender cg
        ON d.client_id = cg.client_id
    WHERE type = 'OWNER');

SELECT *
FROM account
LIMIT 1000;

SELECT *
FROM loan
LIMIT 1000;

-- classify accounts based on whether they have a loan linked or not
CREATE TEMPORARY TABLE loaner_status_by_account AS (
    SELECT
        a.account_id,
        IF(l.loan_id IS NOT NULL, 'LOANER', 'NON-LOANER') AS loaner_status
    FROM account a
        LEFT JOIN loan l
        ON a.account_id = l.account_id);

-- merge previously created tables to link loaner status to gender through account_ids
CREATE TEMPORARY TABLE gender_split_abs AS (
    SELECT
        lsba.loaner_status,
        aog.gender,
        COUNT(*)            AS no_of_owners
    FROM loaner_status_by_account lsba
        JOIN account_owner_gender aog
        ON lsba.account_id = aog.account_id
    GROUP BY 1,2);

-- create an aggregate for each loaner status to be able to compute the split
WITH loaner_agg AS (
    SELECT
        lsba.loaner_status,
        COUNT(*)            AS no_of_owners
    FROM loaner_status_by_account lsba
        JOIN account_owner_gender aog
        ON lsba.account_id = aog.account_id
    GROUP BY 1)

-- create the split
SELECT
    gsa.loaner_status,
    gsa.gender,
    gsa.no_of_owners / la.no_of_owners AS gender_split
FROM gender_split_abs gsa
    JOIN loaner_agg la
    ON gsa.loaner_status = la.loaner_status
ORDER BY 1,2;
