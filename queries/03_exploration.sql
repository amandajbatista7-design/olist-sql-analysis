-- Data exploration

-- How many orders are completed vs cancelled
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Date range of the dataset
SELECT 
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;


-- Orders per state?
SELECT 
    customer_state,
    COUNT(*) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY total_orders DESC;


-- Most sold product categories
SELECT 
    ct.product_category_name_english AS category,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY total_items_sold DESC
LIMIT 10;