USE financial5_49;

-- TYPES OF RELATIONS

SELECT
    account_id,
    COUNT(trans_id) as amount
FROM trans
GROUP BY account_id
ORDER BY 2 DESC;

-- SUMMARY OF LOANS

SELECT * FROM loan;

-- extract from date
SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month
FROM loan;

-- group by
SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month
FROM loan
GROUP BY 1, 2, 3;

-- rollup (year, quarter, month, summary)
SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month
FROM loan
GROUP BY 1, 2, 3 WITH ROLLUP;

-- statistics
SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month,

    sum(payments) as loans_total,
    avg(payments) as loans_avg,
    count(payments) as loans_count
FROM loan
GROUP BY 1, 2, 3 WITH ROLLUP
ORDER BY 1, 2, 3;

-- LOAN STATUS

/* On the database website we can find information that the
database contains a total of 682 loans granted, of which 606
have been repaid and 76 have not.
 */

SELECT * FROM loan; -- 682

SELECT
    status,
    count(loan_id) as count_id
FROM loan
GROUP BY status
ORDER BY status;

-- A and C repaid, B and D not repaid

-- ACCOUNT ANALYSIS (only repaid loans)

SELECT * FROM loan;

-- repaid
SELECT account_id
FROM loan
WHERE status IN ('A', 'C');

-- statistics
SELECT
    account_id,
    sum(amount)   as loans_amount,
    count(amount) as loans_count,
    avg(amount)   as loans_avg
FROM loan
WHERE status IN ('A', 'C')
GROUP BY account_id;

-- subquery
WITH cte as (
    SELECT
        account_id,
        sum(amount)   as loans_amount,
        count(amount) as loans_count,
        avg(amount)   as loans_avg
    FROM loan
    WHERE status IN ('A', 'C')  -- tylko udzielone pożyczki
    GROUP BY account_id
)
SELECT *
FROM cte;

-- rank
WITH cte AS (
    -- pierwszy krok, czyli zagregowanie danych do poziomu account_id
    SELECT
       account_id,
       sum(amount)   as loans_amount,
       count(amount) as loans_count,
       avg(amount)   as loans_avg
    FROM loan
    WHERE status IN ('A', 'C')  -- tylko udzielone pożyczki
    GROUP BY account_id
    )
SELECT
    *,
    ROW_NUMBER() over (ORDER BY loans_amount DESC) AS rank_loans_amount,
    ROW_NUMBER() over (ORDER BY loans_count DESC) AS rank_loans_count
FROM cte;

-- REPAID LOANS (How many loans were repaid? by client's gender)
SELECT *
FROM loan as l
WHERE l.status IN ('A', 'C');

-- join (loan and account)
SELECT *
FROM
        loan as l
    INNER JOIN
        account as a USING (account_id)
WHERE l.status IN ('A', 'C');

-- join (disp)
SELECT *
FROM
        loan as l
    INNER JOIN
        account as a USING (account_id)
    INNER JOIN
        disp as d USING (account_id)
WHERE l.status IN ('A', 'C');

-- join (client)
SELECT
    *
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE l.status IN ('A', 'C');

-- group by gender
SELECT
    c.gender,
    sum(l.amount) as amount
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE l.status IN ('A', 'C')
GROUP BY c.gender;

-- test
DROP TABLE IF EXISTS tmp_results;
CREATE TEMPORARY TABLE tmp_results AS
SELECT
    c.gender,
    sum(l.amount) as amount
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender;

WITH cte as (
    SELECT sum(amount) as amount
    FROM loan as l
    WHERE l.status IN ('A', 'C')
)
SELECT (SELECT SUM(amount) FROM tmp_results) - (SELECT amount FROM cte);

-- CUSTOMER ANALYSIS v.1
/* How has more repaid loans - women or men?
   What is the average age of the borrower?
*/

-- age
SELECT
    c.gender,
    2021 - extract(year from birth_date) as age,

    sum(l.amount) as amount
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

SELECT
    c.gender,
    2021 - extract(year from birth_date) as age,

    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

DROP TABLE IF EXISTS tmp_analysis;
CREATE TEMPORARY TABLE tmp_analysis AS
SELECT
    c.gender,
    2021 - extract(year from birth_date) as age,

    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

-- test

SELECT SUM(loans_count) FROM tmp_analysis;

SELECT
    gender,
    SUM(loans_count) as loans_count
FROM tmp_analysis
GROUP BY gender;

SELECT avg(age) FROM tmp_analysis;

SELECT
    gender,
    avg(age) as avg_age
FROM tmp_analysis
GROUP BY gender;

-- CUSTOMER ANALYSIS v.2
/* Which area has the most customers,
   in which region the most loans were repaid (quantity),
   in which region the most loans were repaid (amount)
*/

SELECT
    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER';

SELECT
    d2.district_id,

    count(distinct c.client_id) as customer_amount,
    sum(l.amount) as loans_given_amount,
    count(l.amount) as loans_given_count
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
    INNER JOIN
        district as d2 on
            c.district_id = d2.district_id
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY d2.district_id
;

DROP TABLE IF EXISTS tmp_district_analytics;
CREATE TEMPORARY TABLE tmp_district_analytics AS
SELECT
    d2.district_id,

    count(distinct c.client_id) as customer_amount,
    sum(l.amount) as loans_given_amount,
    count(l.amount) as loans_given_count
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
    INNER JOIN
        district as d2 on
            c.district_id = d2.district_id
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY d2.district_id
;

-- The area with the customers
SELECT *
FROM tmp_district_analytics
ORDER BY customer_amount DESC
LIMIT 1;

-- The area where the most loans were repaid (quantity)

SELECT *
FROM tmp_district_analytics
ORDER BY loans_given_amount DESC
LIMIT 1;

-- The area where the most loans were repaid (amount)
SELECT *
FROM tmp_district_analytics
ORDER BY loans_given_count DESC
LIMIT 1;

-- -- CUSTOMER ANALYSIS v.3
/*
The percentage share of each region in the total amount of loans granted.
 */

WITH cte AS (
    SELECT
        d2.district_id,

        count(distinct c.client_id) as customer_amount,
        sum(l.amount) as loans_given_amount,
        count(l.amount) as loans_given_count
    FROM
            loan as l
        INNER JOIN
            account a using (account_id)
        INNER JOIN
            disp as d using (account_id)
        INNER JOIN
            client as c using (client_id)
        INNER JOIN
            district as d2 on
                c.district_id = d2.district_id
    WHERE True
        AND l.status IN ('A', 'C')
        AND d.type = 'OWNER'
    GROUP BY d2.district_id
)
SELECT *
FROM cte;

WITH cte AS (
    SELECT d2.district_id,

           count(distinct c.client_id) as customer_amount,
           sum(l.amount)               as loans_given_amount,
           count(l.amount)             as loans_given_count
    FROM
            loan as l
        INNER JOIN
            account a using (account_id)
        INNER JOIN
            disp as d using (account_id)
        INNER JOIN
            client as c using (client_id)
        INNER JOIN
            district as d2 on
                c.district_id = d2.district_id
    WHERE True
      AND l.status IN ('A', 'C')
      AND d.type = 'OWNER'
    GROUP BY d2.district_id
)
SELECT
    *,
    loans_given_amount / SUM(loans_given_amount) OVER () AS share
FROM cte
ORDER BY share DESC;

-- CUSTOMER SELECTION
/*
 customers who:
account balance exceeds 1000,
have more than five loans,
are born after 1990
*/

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
    INNER JOIN
        district as d2 on
            c.district_id = d2.district_id
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
    AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id;

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM loan as l
         INNER JOIN
     account a using (account_id)
         INNER JOIN
     disp as d using (account_id)
         INNER JOIN
     client as c using (client_id)
WHERE True
  AND l.status IN ('A', 'C')
  AND d.type = 'OWNER'
GROUP BY c.client_id
HAVING
    SUM(amount - payments) > 1000
    AND COUNT(loan_id) > 5;
/*
the set is empty
*/

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM
        loan as l
    INNER JOIN
        account a using (account_id)
    INNER JOIN
        disp as d using (account_id)
    INNER JOIN
        client as c using (client_id)
    INNER JOIN
        district as d2 on
            c.district_id = d2.district_id
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
    -- AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id;

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM loan as l
         INNER JOIN
     account a using (account_id)
         INNER JOIN
     disp as d using (account_id)
         INNER JOIN
     client as c using (client_id)
WHERE True
  AND l.status IN ('A', 'C')
  AND d.type = 'OWNER'
GROUP BY c.client_id
HAVING
    SUM(amount - payments) > 1000
    -- AND COUNT(loan_id) > 5
;

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM loan as l
         INNER JOIN
     account a using (account_id)
         INNER JOIN
     disp as d using (account_id)
         INNER JOIN
     client as c using (client_id)
WHERE True
  AND l.status IN ('A', 'C')
  AND d.type = 'OWNER'
--  AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id
HAVING
    sum(amount - payments) > 1000
--    and count(loan_id) > 5
ORDER BY loans_amount DESC;

/*
 Customers have at most one loan
 */

 -- EXPIRING CARDS

-- join (card-disp-client-district)

SELECT
    c2.client_id,
    c.card_id,

    DATE_ADD(c.issued, INTERVAL 3 year) as expiration_date,
    d2.A3 as client_adress
FROM
        card as c
    INNER JOIN
        disp as d using (disp_id)
    INNER JOIN
        client as c2 using (client_id)
    INNER JOIN
        district as d2 using (district_id);

WITH cte AS (
    SELECT
        c2.client_id,
        c.card_id,

        DATE_ADD(c.issued, interval 3 year) as expiration_date,
        d2.A3 as client_adress
    FROM
            card as c
        INNER JOIN
            disp as d using (disp_id)
        INNER JOIN
            client as c2 using (client_id)
        INNER JOIN
            district as d2 using (district_id)
)
SELECT *
FROM cte;

WITH cte AS (
    SELECT
        c2.client_id,
        c.card_id,

        DATE_ADD(c.issued, interval 3 year) as expiration_date,
        d2.A3 as client_adress
    FROM
            card as c
        INNER JOIN
            disp as d using (disp_id)
        INNER JOIN
            client as c2 using (client_id)
        INNER JOIN
            district as d2 using (district_id)
)
SELECT *
FROM cte
WHERE '2000-01-01' BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;

CREATE TABLE cards_at_expiration
(
    client_id       int                      not null,
    card_id         int default 0            not null,
    expiration_date date                     null,
    A3              varchar(15) charset utf8 not null,
    generated_for_date date                     null
);

-- 2000-01-01 --> p_date
WITH cte AS (
    SELECT
        c2.client_id,
        c.card_id,

        DATE_ADD(c.issued, interval 3 year) as expiration_date,
        d2.A3 as client_adress
    FROM
            card as c
        INNER JOIN
            disp as d using (disp_id)
        INNER JOIN
            client as c2 using (client_id)
        INNER JOIN
            district as d2 using (district_id)
)
SELECT *
FROM cte
WHERE p_date BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;


DELIMITER $$
DROP PROCEDURE IF EXISTS generate_cards_at_expiration_report;
CREATE PROCEDURE generate_cards_at_expiration_report(p_date DATE)
BEGIN
END;
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS generate_cards_at_expiration_report;
CREATE PROCEDURE generate_cards_at_expiration_report(p_date DATE)
BEGIN
    TRUNCATE TABLE cards_at_expiration;
    INSERT INTO cards_at_expiration
    WITH cte AS (
        SELECT c2.client_id,
               c.card_id,
               date_add(c.issued, interval 3 year) as expiration_date,
               d2.A3
        FROM
            card as c
                 INNER JOIN
            disp as d using (disp_id)
                 INNER JOIN
            client as c2 using (client_id)
                 INNER JOIN
            district as d2 using (district_id)
    )
    SELECT
           *,
           p_date
    FROM cte
    WHERE p_date BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date
    ;
END;
DELIMITER ;

CALL generate_cards_at_expiration_report('2001-01-01');
SELECT * FROM cards_at_expiration;

