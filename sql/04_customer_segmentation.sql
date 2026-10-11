
-- =========================================================
-- Retail Sales & Customer Analytics
-- 04 - Customer RFM Segmentation
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Database: PostgreSQL
-- =========================================================

-- Purpose:
-- Segment customers based on:
-- R = Recency (days since last purchase)
-- F = Frequency (number of distinct orders)
-- M = Monetary (total product value)
--
-- Methodology:
-- Only delivered orders are included.
-- Freight charges are excluded.
-- Customers are identified using customer_unique_id.
-- Recency is measured against the latest purchase
-- date among delivered orders in the dataset.


-- =========================================================
-- 1. Calculate Customer RFM Metrics
-- =========================================================

WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,

        MAX(o.order_purchase_timestamp) AS last_purchase,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(oi.price) AS monetary

    FROM customers AS c

    JOIN orders AS o
        ON c.customer_id = o.customer_id

    JOIN order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
),


-- =========================================================
-- 2. Calculate Recency
-- =========================================================

reference_date AS (
    SELECT
        MAX(order_purchase_timestamp)::DATE AS max_purchase_date
    FROM orders
    WHERE order_status = 'delivered'
),

rfm_values AS (
    SELECT
        cr.customer_unique_id,

        rd.max_purchase_date
            - cr.last_purchase::DATE AS recency,

        cr.frequency,
        cr.monetary

    FROM customer_rfm AS cr
    CROSS JOIN reference_date AS rd
),


-- =========================================================
-- 3. Assign RFM Scores
-- =========================================================

rfm_scores AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,

        ROUND(monetary, 2) AS monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,

        CASE
            WHEN frequency >= 5 THEN 5
            WHEN frequency = 4 THEN 4
            WHEN frequency = 3 THEN 3
            WHEN frequency = 2 THEN 2
            ELSE 1
        END AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS m_score

    FROM rfm_values
),


-- =========================================================
-- 4. Classify Customer Segments
-- =========================================================

customer_segments AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,

        CASE
            WHEN r_score >= 4
                AND f_score >= 2
                AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                AND f_score >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                AND f_score = 1
                THEN 'Recent Customers'

            WHEN r_score <= 2
                AND m_score >= 4
                THEN 'At Risk - High Value'

            WHEN r_score <= 2
                THEN 'Inactive Customers'

            ELSE 'Potential Customers'
        END AS customer_segment

    FROM rfm_scores
)


-- =========================================================
-- 5. Summarize Customer Segments
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS customers,

    ROUND(SUM(monetary), 2) AS total_product_value,

    ROUND(AVG(monetary), 2) AS avg_customer_value,

    ROUND(
        100.0 * COUNT(*)
        / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS customer_pct

FROM customer_segments

GROUP BY customer_segment

ORDER BY total_product_value DESC;
