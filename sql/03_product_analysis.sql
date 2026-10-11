
-- =========================================================
-- Retail Sales & Customer Analytics
-- 03 - Product & Category Analysis
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Database: PostgreSQL
-- =========================================================

-- Purpose:
-- Identify high-performing product categories,
-- analyze average item prices, and calculate
-- category contributions to delivered product value.
--
-- Methodology:
-- Only delivered orders are included.
-- Freight charges are excluded.
-- Missing categories are labeled 'Unknown'.


-- =========================================================
-- 1. Top 10 Product Categories by Product Value
-- =========================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_value

FROM order_items AS oi

JOIN orders AS o
    ON oi.order_id = o.order_id

JOIN products AS p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

ORDER BY product_value DESC
LIMIT 10;


-- =========================================================
-- 2. Category Value and Average Item Price
-- =========================================================

WITH category_sales AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,

        COUNT(*) AS items_sold,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS product_value

    FROM order_items AS oi

    JOIN orders AS o
        ON oi.order_id = o.order_id

    JOIN products AS p
        ON oi.product_id = p.product_id

    LEFT JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    category,
    items_sold,
    total_orders,
    ROUND(product_value, 2) AS product_value,

    ROUND(
        product_value / NULLIF(items_sold, 0),
        2
    ) AS avg_item_price

FROM category_sales

ORDER BY product_value DESC
LIMIT 10;


-- =========================================================
-- 3. Category Ranking and Product Value Share
-- =========================================================

WITH category_sales AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,

        COUNT(*) AS items_sold,
        SUM(oi.price) AS product_value

    FROM order_items AS oi

    JOIN orders AS o
        ON oi.order_id = o.order_id

    JOIN products AS p
        ON oi.product_id = p.product_id

    LEFT JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    category,
    items_sold,

    ROUND(product_value, 2) AS product_value,

    RANK() OVER (
        ORDER BY product_value DESC
    ) AS value_rank,

    ROUND(
        100.0 * product_value
        / NULLIF(SUM(product_value) OVER (), 0),
        2
    ) AS product_value_share_pct

FROM category_sales

ORDER BY value_rank, category
LIMIT 10;
