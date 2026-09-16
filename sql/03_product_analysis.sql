-- =========================================================
-- Retail Sales & Customer Analytics
-- Product & Category Analysis
-- =========================================================


-- 1. Top 10 Product Categories by Revenue
SELECT
    ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;


-- 2. Category Revenue and Average Item Price
WITH category_sales AS (
    SELECT
        ct.product_category_name_english AS category,
        COUNT(*) AS items_sold,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS revenue
    FROM order_items AS oi
    JOIN products AS p
        ON oi.product_id = p.product_id
    JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
)

SELECT
    category,
    items_sold,
    total_orders,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue / items_sold, 2) AS avg_item_price
FROM category_sales
ORDER BY revenue DESC
LIMIT 10;


-- 3. Category Revenue Ranking and Revenue Share
WITH category_sales AS (
    SELECT
        ct.product_category_name_english AS category,
        COUNT(*) AS items_sold,
        SUM(oi.price) AS revenue
    FROM order_items AS oi
    JOIN products AS p
        ON oi.product_id = p.product_id
    JOIN category_translation AS ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
)

SELECT
    category,
    items_sold,
    ROUND(revenue, 2) AS revenue,

    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank,

    ROUND(
        100 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct

FROM category_sales
ORDER BY revenue_rank
LIMIT 10;