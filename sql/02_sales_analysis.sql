-- =========================================================
-- Retail Sales & Customer Analytics
-- Sales Analysis
-- =========================================================


-- 1. Total Product Sales Revenue
SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items;


-- 2. Average Order Value
SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_totals;


-- 3. Monthly Revenue Trend
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;


-- 4. Top 5 Revenue Months
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY monthly_revenue DESC
LIMIT 5;