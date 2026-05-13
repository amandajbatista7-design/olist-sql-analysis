-- Data quality checks

-- Check nulls in critical orders columns
SELECT
    COUNT(*)                                                    AS total_orders,
    COUNT(*) FILTER (WHERE order_status IS NULL)                AS null_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL)    AS null_purchase_date,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_delivery_date,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS null_estimated_date
FROM orders;

-- Check nulls in order_items critical columns
SELECT
    COUNT(*)                                        AS total_items,
    COUNT(*) FILTER (WHERE price IS NULL)           AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL)   AS null_freight
FROM order_items;

-- Check nulls in products
SELECT
    COUNT(*)                                                    AS total_products,
    COUNT(*) FILTER (WHERE product_category_name IS NULL)       AS null_category,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL)            AS null_weight
FROM products;

-- Check for duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Check for duplicate review IDs
SELECT
    review_id,
    COUNT(*) AS occurrences
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
LIMIT 10;

-- Orders where delivery date is before purchase date
SELECT COUNT(*) AS impossible_deliveries
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Orders where estimated delivery is before purchase date (data entry error)
SELECT COUNT(*) AS bad_estimated_dates
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;


-- Orders with zero or negative price
SELECT COUNT(*) AS zero_or_negative_price
FROM order_items
WHERE price <= 0;

-- Products with no category translation
SELECT
    p.product_category_name,
    COUNT(*) AS total_products
FROM products p
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY total_products DESC;


-- Orders with no corresponding payment
SELECT COUNT(*) AS orders_without_payment
FROM orders o
LEFT JOIN order_payments op ON o.order_id = op.order_id
WHERE op.order_id IS NULL;


-- Orders with no items
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;