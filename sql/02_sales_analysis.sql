
-- =========================================================
-- Retail Sales & Customer Analytics
-- 02 - Sales Analysis
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Database: PostgreSQL
-- =========================================================

-- Purpose:
-- Analyze product sales value, average order value,
-- monthly sales trends, and top-performing months.
--
-- Primary sales metric:
-- Product value from delivered orders only.
--
-- Note:
-- Freight charges are excluded from product value.
-- Delivered product value is a proxy for fulfilled
-- sales, not verified accounting revenue.


-- =========================================================
-- 1. Total Product Value vs Delivered Product Value
-- =========================================================

SELECT
    ROUND(SUM(oi.price), 2) AS total_product_value,

    ROUND(
        SUM(oi.price) FILTER (
            WHERE o.order_status = 'delivered'
        ), 2
    ) AS delivered_product_value

FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id;


-- =========================================================
-- 2. Average Order Value (Delivered Orders)
-- =========================================================

-- First calculate the product value of each order.
-- Then calculate the average across delivered orders.

SELECT
    ROUND(AVG(order_total), 2) AS delivered_aov
FROM (
    SELECT
        oi.order_id,
        SUM(oi.price) AS order_total
    FROM order_items AS oi
    JOIN orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.order_id
) AS order_totals;


-- =========================================================
-- 3. Monthly Delivered Product Value
-- =========================================================

-- Group delivered-order product value by purchase month.
-- The month represents when the order was placed,
-- not when it was delivered.

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::DATE AS month,

    ROUND(SUM(oi.price), 2) AS monthly_product_value

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    DATE_TRUNC('month', o.order_purchase_timestamp)

ORDER BY month;


-- =========================================================
-- 4. Top 5 Months by Delivered Product Value
-- =========================================================

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        )::DATE AS month,

        ROUND(SUM(oi.price), 2) AS monthly_product_value

    FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        DATE_TRUNC('month', o.order_purchase_timestamp)
)

SELECT
    month,
    monthly_product_value
FROM monthly_sales

ORDER BY monthly_product_value DESC
LIMIT 5;
