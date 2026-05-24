-- =========================================================================
-- PROJECT     : Olist E-Commerce End-to-End Data Analysis
-- ANALYST     : Atika Shafiyya Davino
-- OBJECTIVE   : Data Cleaning, Validation, and Business Metric Extraction
-- =========================================================================

-- -------------------------------------------------------------------------
-- STAGE 1: DATA CLEANING & INTEGRITY CHECK
-- -------------------------------------------------------------------------

-- 1.1 Checking for duplicate Primary Keys in master tables
SELECT customer_id, COUNT(*) AS total_duplicate
FROM customers_data
GROUP BY customer_id HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM order_data
GROUP BY order_id HAVING COUNT(*) > 1;

-- 1.2 Checking for missing (NULL) values in critical columns
SELECT * FROM customers_data WHERE customer_id IS NULL;

SELECT * FROM order_data WHERE order_id IS NULL OR customer_id IS NULL;

SELECT * FROM order_item_data WHERE order_id IS NULL OR product_id IS NULL;

-- 1.3 Referential Integrity Check (Orphan Rows Tracking)
-- Checking if there are orders without valid customers
SELECT * FROM order_data od 
LEFT JOIN customers_data cd ON od.customer_id = cd.customer_id
WHERE cd.customer_id IS NULL;

-- Checking if there are order items without valid order details
SELECT * FROM order_item_data ot  
LEFT JOIN order_data od ON ot.order_id = od.order_id
WHERE od.order_id IS NULL;

-- 1.4 Checking for composite key duplicates in transaction details
SELECT order_id, order_item_id, COUNT(*) AS duplicate_count    
FROM order_item_data
GROUP BY order_id, order_item_id HAVING COUNT(*) > 1;


-- -------------------------------------------------------------------------
-- STAGE 2: DATA TRANSFORMATION & ANOMALY HANDLING
-- -------------------------------------------------------------------------

-- 2.1 Cleaning anomaly format in price column (e.g., '.00.00' to '.00')
UPDATE order_item_data
SET price = REPLACE(price, '.00.00', '.00')
WHERE price LIKE '%.00.00';

-- 2.2 Fixing multi-period float anomalies
UPDATE order_item_data
SET price = SPLIT_PART(price, '.', 1) || '.' || SPLIT_PART(price, '.', 2)
WHERE price LIKE '%.%.%';

-- 2.3 Altering column type from TEXT to NUMERIC for mathematical calculation
ALTER TABLE order_item_data
ALTER COLUMN price TYPE NUMERIC USING price::NUMERIC;

-- 2.4 Sanity check for negative or zero pricing
SELECT * FROM order_item_data WHERE price <= 0;


-- -------------------------------------------------------------------------
-- STAGE 3: BUSINESS METRIC EXTRACTION & EXPLORATORY DATA ANALYSIS (EDA)
-- -------------------------------------------------------------------------

-- 3.1 High-Level KPI (Total Revenue, Total Orders, Average Order Value)
SELECT 
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM order_item_data;

-- 3.2 Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', shipping_limit_date) AS sales_month,
    ROUND(SUM(price), 2) AS monthly_revenue,
    COUNT(order_id) AS total_items_sold
FROM order_item_data
GROUP BY sales_month
ORDER BY sales_month;

-- 3.3 Hourly Order Profile (Peak Shopping Hours)
SELECT 
    EXTRACT(HOUR FROM shipping_limit_date) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_revenue
FROM order_item_data
GROUP BY 1 ORDER BY 1;

-- 3.4 Geographic Performance (Revenue & Order Volume by State)
SELECT 
    cd.customer_state,
    ROUND(SUM(ot.price), 2) AS total_revenue,
    COUNT(ot.order_id) AS total_orders
FROM order_item_data ot
JOIN order_data od ON ot.order_id = od.order_id
JOIN customers_data cd ON od.customer_id = cd.customer_id
GROUP BY 1 ORDER BY 2 DESC;

-- 3.5 Tracking Uncompleted/Unprocessed Orders
SELECT COUNT(DISTINCT od.customer_id) 
FROM order_data od
LEFT JOIN order_item_data oid ON od.order_id = oid.order_id
WHERE oid.order_id IS NULL;

-- 3.6 Advanced Customer Segmentation (User Retention Analytics)
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-time Buyer'
        WHEN total_orders = 2 THEN 'Repeat Buyer'
        ELSE 'Loyal Customer (3+ Orders)'
    END AS customer_segment,
    COUNT(customer_unique_id) AS total_customers
FROM (
    SELECT 
        cd.customer_unique_id, 
        COUNT(DISTINCT od.order_id) AS total_orders
    FROM order_data od
    JOIN customers_data cd ON od.customer_id = cd.customer_id 
    GROUP BY cd.customer_unique_id
) customer_counts 
GROUP BY 1;