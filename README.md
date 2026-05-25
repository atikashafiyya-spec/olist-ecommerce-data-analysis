# Olist E-Commerce End-to-End Data Analysis

## Project Overview
This project focuses on analyzing customer retention, order fulfillment, and business performance metrics using the Olist E-Commerce dataset. It covers the entire data pipeline, from raw data cleaning in PostgreSQL to interactive visualization in Power BI.

## Data Analyst Workflow

1. **Data Cleaning & Validation (SQL):** Handled duplicate primary keys, fixed corrupted string formats in pricing, and managed data type conversions.

The process of cleaning the raw data for Olist E-Commerce is carried out entirely using PostgreSQL. Here are the key queries I used to address data anomalies:

<details>
<summary><b> View All SQL Data Cleaning Queries (Click to Expand)</b></summary>

```sql
-- 1. Referential Integrity Check (Ensure customer_id exists in master table)
SELECT *
FROM order_data od 
LEFT JOIN customers_data cd ON od.customer_id = cd.customer_id
WHERE cd.customer_id IS NULL;

-- 2. Handling Corrupted Pricing Strings (Fix double periods format)
UPDATE order_item_data
SET price = SPLIT_PART(price, '.', 1) || '.' || SPLIT_PART(price, '.', 2)
WHERE price LIKE '%.%.%';

-- 3. Data Type Conversion (Cast text to numeric)
ALTER TABLE order_item_data
ALTER COLUMN price TYPE NUMERIC USING price::NUMERIC;

-- 4. Data Profiling (Check for Primary Key duplicates)
SELECT order_id, order_item_id, COUNT(*) AS duplicate_count
FROM order_item_data
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```
</details>


2. **Data Reconciliation (Notion):** Logged the filtering process from raw checkout records (99k) to validated successful transactions (98k).
3. **Data Visualization (Power BI):** Developed an interactive dashboard to display high-level KPIs and resolve structural data issues in user retention metrics.

## Important Links
- **Interactive Dashboard:** [Download Power BI File (.pbix)](./AtikaShafiyya_OlistDashboard.pbix)
- **Data Cleansing Documentation:** [Notion Log](https://www.notion.so/Data-Analyst-Portofolio-Atika-Shafiyya-Davino-3653ba008b1c8072b369ceae91fe2867?source=copy_link)

## Dashboard Overview
<img width="1088" height="625" alt="Screenshot 2026-05-23 190652" src="https://github.com/user-attachments/assets/f6d24a72-a3d1-45df-a591-45c43000c678" />

## Key Business Insight
- **97% of the customer base consists of one-time buyers.** This high customer churn rate suggests that the company is spending heavily on user acquisition but struggling with retention. 
- **Recommendation:** Shift budget toward retention marketing (e.g., automated email voucher loops 30 days post-purchase) to drive repeat orders more

sefficiently.IC USING price::NUMERIC;
  
