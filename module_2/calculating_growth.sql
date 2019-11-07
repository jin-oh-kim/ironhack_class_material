USE olist;

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS month_id,
        SUM(oi.price)                                       AS revenue
    FROM order_items oi
        JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_purchase_timestamp < '2018-08-01'
        AND o.order_purchase_timestamp >= '2017-01-01'
    GROUP BY 1),

shifted_monthly_revenue AS (
    SELECT
        DATE_ADD(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01'), INTERVAL 1 MONTH) AS month_id,
        SUM(oi.price)                                       AS revenue,
        COUNT(DISTINCT oi.seller_id)                        AS sellers
    FROM order_items oi
        JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_purchase_timestamp < '2018-08-01'
        AND o.order_purchase_timestamp >= '2017-01-01'
    GROUP BY 1),

shifted_year_monthly_revenue AS (
    SELECT
        DATE_ADD(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01'), INTERVAL 12 MONTH) AS month_id,
        SUM(oi.price)                                       AS revenue,
        COUNT(DISTINCT oi.seller_id)                        AS sellers
    FROM order_items oi
        JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_purchase_timestamp < '2018-08-01'
        AND o.order_purchase_timestamp >= '2017-01-01'
    GROUP BY 1)

SELECT
    mr.month_id,
    mr.revenue,
    smr.revenue                     AS revenue_last_month,
    (mr.revenue / smr.revenue) - 1  AS mom_growth,
    symr.revenue                    AS revenue_last_year,
    (mr.revenue / symr.revenue) - 1 AS yoy_growth
FROM monthly_revenue mr
    LEFT JOIN shifted_monthly_revenue smr
    ON mr.month_id = smr.month_id
    LEFT JOIN shifted_year_monthly_revenue symr
    ON mr.month_id = symr.month_id
ORDER BY 1;