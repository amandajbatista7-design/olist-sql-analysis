-- Customer behavior analysis

-- Overall customer metrics
SELECT
    COUNT(DISTINCT c.customer_unique_id)            AS unique_customers,
    COUNT(DISTINCT o.order_id)                      AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value
FROM orders o
JOIN order_items oi  ON o.order_id   = oi.order_id
JOIN customers c     ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';


-- Number of orders by customer
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE 
        WHEN total_orders = 1 THEN '1 order'
        WHEN total_orders = 2 THEN '2 orders'
        WHEN total_orders = 3 THEN '3 orders'
        ELSE '4+ orders'
    END                         AS order_frequency,
    COUNT(*)                    AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM customer_orders
GROUP BY order_frequency
ORDER BY MIN(total_orders);


-- Average days between order and delivery by state
SELECT
    c.customer_state AS state,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))
        / 86400
    )::NUMERIC, 1)   AS avg_delivery_days,
    COUNT(*)          AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY state
ORDER BY avg_delivery_days;


-- Average review score by state
SELECT
    c.customer_state                        AS state,
    ROUND(AVG(r.review_score)::NUMERIC, 2)  AS avg_review_score,
    COUNT(*)                                AS total_reviews
FROM order_reviews r
JOIN orders o       ON r.order_id    = o.order_id
JOIN customers c    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY avg_review_score DESC;