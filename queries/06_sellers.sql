-- Seller performance analysis

-- Overall seller metrics
SELECT
    COUNT(DISTINCT s.seller_id)                         AS total_sellers,
    ROUND(SUM(oi.price)::NUMERIC, 2)                    AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2)                    AS avg_item_price,
    ROUND(SUM(oi.price) / COUNT(DISTINCT s.seller_id)::NUMERIC, 2) AS avg_revenue_per_seller
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id;


-- Top 10 sellers by revenue
WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)             AS total_orders,
        ROUND(SUM(oi.price)::NUMERIC, 2)        AS total_revenue,
        ROUND(AVG(oi.price)::NUMERIC, 2)        AS avg_item_price,
        ROUND(AVG(r.review_score)::NUMERIC, 2)  AS avg_review_score
    FROM order_items oi
    JOIN sellers s      ON oi.seller_id  = s.seller_id
    JOIN orders o       ON oi.order_id   = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id, s.seller_state
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_item_price,
    avg_review_score,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM seller_metrics
ORDER BY revenue_rank
LIMIT 10;


-- Seller performance by state
SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id)                     AS total_sellers,
    COUNT(DISTINCT oi.order_id)                     AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)                AS total_revenue,
    ROUND(AVG(r.review_score)::NUMERIC, 2)          AS avg_review_score
FROM sellers s
JOIN order_items oi  ON s.seller_id  = oi.seller_id
JOIN orders o        ON oi.order_id  = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY total_revenue DESC;


-- Seller reliability: on time vs late deliveries
WITH delivery_performance AS (
    SELECT
        oi.seller_id,
        COUNT(*)                                                AS total_orders,
        SUM(CASE 
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
            THEN 1 ELSE 0 
        END)                                                    AS on_time_deliveries,
        ROUND(AVG(r.review_score)::NUMERIC, 2)                  AS avg_review_score
    FROM order_items oi
    JOIN orders o       ON oi.order_id  = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id
    HAVING COUNT(*) >= 30
)
SELECT
    seller_id,
    total_orders,
    on_time_deliveries,
    ROUND(on_time_deliveries * 100.0 / total_orders, 1) AS on_time_rate,
    avg_review_score
FROM delivery_performance
ORDER BY on_time_rate DESC
LIMIT 20;