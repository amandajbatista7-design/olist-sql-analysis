-- Import CSV data into tables

COPY customers
FROM 'C:\olist_data\olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY sellers
FROM 'C:\olist_data\olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY products
FROM 'C:\olist_data\olist_products_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY category_translation
FROM 'C:\olist_data\product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;

COPY orders
FROM 'C:\olist_data\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY order_items
FROM 'C:\olist_data\olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY order_payments
FROM 'C:\olist_data\olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY order_reviews
FROM 'C:\olist_data\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;