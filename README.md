# Olist E-Commerce End-to-End Data Analysis

## Project Overview
This project analyzes customer retention, sales performance, and purchasing behavior using the Olist E-Commerce dataset. The workflow covers the complete analytics process, starting from data cleaning in PostgreSQL to building an interactive dashboard in Power BI.

---

## Data Analyst Workflow

### 1. Data Cleaning & Validation (SQL)
Performed data cleaning and validation using PostgreSQL, including:
- checking referential integrity between tables
- fixing corrupted pricing formats
- converting incorrect data types
- identifying duplicate records

Key SQL queries used during the cleaning process:

<details>
<summary><b>View SQL Data Cleaning Queries</b></summary>

```sql
-- 1. Referential Integrity Check
SELECT *
FROM order_data od 
LEFT JOIN customers_data cd 
ON od.customer_id = cd.customer_id
WHERE cd.customer_id IS NULL;

-- 2. Fix Corrupted Pricing Format
UPDATE order_item_data
SET price = SPLIT_PART(price, '.', 1) || '.' || SPLIT_PART(price, '.', 2)
WHERE price LIKE '%.%.%';

-- 3. Convert Data Type
ALTER TABLE order_item_data
ALTER COLUMN price TYPE NUMERIC USING price::NUMERIC;

-- 4. Check Duplicate Records
SELECT order_id, order_item_id, COUNT(*) AS duplicate_count
FROM order_item_data
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```
</details>

### 2. Data Reconciliation
Documented the filtering process from raw transaction records (99k rows) into validated successful transactions (98k rows) to ensure data consistency before visualization.

### 3. Data Visualization (Power BI)
Built an interactive dashboard to monitor:
  - sales performance
  - customer retention
  - purchasing patterns
  - regional order distribution
The dashboard was designed to support business analysis through KPI tracking and customer behavior insights.

## Data Validation Summary
During the validation process, a discrepancy was found between the total records in the order table (99,441) and the final successful transactions used for analysis (98,666).
Further investigation showed that several records in the `order_data` table did not have matching transaction details in the `order_item_data` table. These incomplete records were excluded to maintain data consistency and reporting accuracy.

## Tools & Technologies
  - PostgreSQL
  - DBeaver
  - Power BI
  - GitHub
  - Notion

## Dataset Source
[Olist Brazilian E-Commerce Public Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Important Links
- **Interactive Dashboard:** [Download Power BI File (.pbix)](./AtikaShafiyya_OlistDashboard.pbix)
- **Data Cleansing Documentation:** [Notion Log](https://www.notion.so/Data-Analyst-Portofolio-Atika-Shafiyya-Davino-3653ba008b1c8072b369ceae91fe2867?source=copy_link)
- **Full Report:** You can view the full presentation here: [E-commerce Strategic Analysis](https://docs.google.com/presentation/d/1kvpgt9dY0cXcuDmSqgTKGVoT-PPHIq9Ng7Li3iJzmVo/edit?usp=sharing)

## Dashboard Overview
<img width="1088" height="625" alt="Screenshot 2026-05-23 190652" src="https://github.com/user-attachments/assets/f6d24a72-a3d1-45df-a591-45c43000c678" />

## Key Insights
  - More than 97% of customers made only one purchase, showing a low repeat purchase rate.
  - Transaction activity peaked between 2–3 AM, indicating unusually high nighttime purchasing activity.
  - São Paulo (SP) contributed the largest share of total orders.
  - Sales volume grew significantly throughout 2017–2018.

## Key Business Insight
  - Improve customer retention through post-purchase engagement strategies such as email reminders or discount vouchers.
  - Optimize marketing campaigns during peak transaction hours.
  - Prioritize operational support in high-demand regions such as São Paulo.

  
