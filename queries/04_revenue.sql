-- Revenue analysis

-- Total revenue, number of orders and average order value. Only delivered orders
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC / 
          COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- Monthly revenue trend
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;


-- Revenue by product category
SELECT
    ct.product_category_name_english    AS category,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)    AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2)    AS avg_item_price
FROM orders o
JOIN order_items oi  ON o.order_id   = oi.order_id
JOIN products p      ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- Revenue by state
SELECT
    c.customer_state                                     AS state,
    COUNT(DISTINCT o.order_id)                           AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2)  AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2)  AS avg_order_value
FROM orders o
JOIN order_items oi  ON o.order_id   = oi.order_id
JOIN customers c     ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_revenue DESC;


-- Revenue by payment type
SELECT
    payment_type,
    COUNT(*)                                        AS total_transactions,
    ROUND(SUM(payment_value)::NUMERIC, 2)           AS total_revenue,
    ROUND(AVG(payment_installments)::NUMERIC, 1)    AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;