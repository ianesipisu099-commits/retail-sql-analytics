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
    GROUP BY c.customer_unique_id
),

rfm_values AS (
    SELECT
        customer_unique_id,
        (
            SELECT MAX(order_purchase_timestamp)::date
            FROM orders
        ) - last_purchase::date AS recency,
        frequency,
        monetary
    FROM customer_rfm
),

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
)
, customer_segments AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,

        CASE
            WHEN r_score >= 4 AND f_score >= 2 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3 AND f_score >= 2
                THEN 'Loyal Customers'

            WHEN r_score >= 4 AND f_score = 1
                THEN 'Recent Customers'

            WHEN r_score <= 2 AND m_score >= 4
                THEN 'At Risk - High Value'

            WHEN r_score <= 2
                THEN 'Inactive Customers'

            ELSE 'Potential Customers'
        END AS customer_segment

    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(AVG(monetary), 2) AS avg_customer_value,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_pct
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;