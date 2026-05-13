-- Cohort retention analysis

-- Step 1: customer's first purchase month
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

-- Step 2: get all purchases per customer with their cohort month attached
customer_purchases AS (
    SELECT
        c.customer_unique_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month
    FROM orders o
    JOIN customers c    ON o.customer_id      = c.customer_id
    JOIN first_purchase fp ON c.customer_unique_id = fp.customer_unique_id
    WHERE o.order_status = 'delivered'
),

-- Step 3: calculate how many months after their first purchase each order happened
cohort_data AS (
    SELECT
        cohort_month,
        customer_unique_id,
        EXTRACT(YEAR FROM AGE(purchase_month, cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(purchase_month, cohort_month)) AS months_since_first
    FROM customer_purchases
)

-- Step 4: count unique customers per cohort per month offset
SELECT
    cohort_month,
    months_since_first,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM cohort_data
WHERE cohort_month >= '2017-01-01'
  AND months_since_first <= 6
GROUP BY cohort_month, months_since_first
ORDER BY cohort_month, months_since_first;