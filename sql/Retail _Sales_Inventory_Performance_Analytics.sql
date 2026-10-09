/* =====================================================================
   PROJECT: Retail Sales & Inventory Performance Analytics
   MySQL 8.0+

   CSV: cleaned_sales_data.csv
   Expected: 76,000 rows, 19 columns

   IMPORTANT:
   - This script DROPS and recreates cleaned_sales_data.
   - Do not run it if you need to preserve data currently in that table.
   - Update the CSV path below if the file is saved elsewhere or has a
     different filename.
   ===================================================================== */

CREATE DATABASE IF NOT EXISTS retail_sales_inventory;
USE retail_sales_inventory;

-- Rebuild the table from the CSV on each full run.
DROP TABLE IF EXISTS cleaned_sales_data;

CREATE TABLE cleaned_sales_data (
    `Date` DATE NOT NULL,
    `Store ID` VARCHAR(10) NOT NULL,
    `Product ID` VARCHAR(10) NOT NULL,
    `Category` VARCHAR(50) NOT NULL,
    `Region` VARCHAR(20) NOT NULL,
    `Inventory Level` INT NOT NULL,
    `Units Sold` INT NOT NULL,
    `Units Ordered` INT NOT NULL,
    `Price` DECIMAL(10, 2) NOT NULL,
    `Discount` INT NOT NULL,
    `Promotion` TINYINT NOT NULL,
    `Seasonality` VARCHAR(20) NOT NULL,
    `Demand` INT NOT NULL,
    `Revenue` DECIMAL(14, 2) NOT NULL,
    `Month` CHAR(7) NOT NULL,
    `Year` SMALLINT NOT NULL,
    `Revenue per Unit` DECIMAL(10, 2) NULL,
    `Inventory Gap` INT NOT NULL,
    `Demand-to-Inventory Ratio` DECIMAL(12, 8) NULL
);

-- Bulk-load the CSV. This path matches the folder path you shared.
-- If your file is named cleaned_sales_data(6).csv, change the filename below.
LOAD DATA LOCAL INFILE
'C:/Users/jadha/Desktop/Project/Retail Store Inventory and Demand Forecasting/cleaned_sales_data.csv'
INTO TABLE cleaned_sales_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    @csv_date,
    `Store ID`,
    `Product ID`,
    `Category`,
    `Region`,
    `Inventory Level`,
    `Units Sold`,
    `Units Ordered`,
    `Price`,
    `Discount`,
    `Promotion`,
    `Seasonality`,
    `Demand`,
    `Revenue`,
    `Month`,
    `Year`,
    @csv_revenue_per_unit,
    `Inventory Gap`,
    @csv_demand_to_inventory_ratio
)
SET
    `Date` = STR_TO_DATE(@csv_date, '%Y-%m-%d'),
    `Revenue per Unit` = NULLIF(TRIM(@csv_revenue_per_unit), ''),
    `Demand-to-Inventory Ratio` = NULLIF(TRIM(@csv_demand_to_inventory_ratio), '');
    
    
    SHOW GLOBAL VARIABLES LIKE 'local_infile';
    
    SET GLOBAL local_infile = 1;
    
    
 -- =====================================================================
-- DATA VALIDATION
-- =====================================================================

-- Expected result: 76,000 rows.
SELECT COUNT(*) AS total_rows
FROM cleaned_sales_data;

-- Preview imported data.
SELECT *
FROM cleaned_sales_data
LIMIT 10;

-- Check key numeric/date fields for missing values.
SELECT
    SUM(`Date` IS NULL) AS null_dates,
    SUM(`Inventory Level` IS NULL) AS null_inventory_levels,
    SUM(`Units Sold` IS NULL) AS null_units_sold,
    SUM(`Price` IS NULL) AS null_prices,
    SUM(`Revenue` IS NULL) AS null_revenue,
    SUM(`Revenue per Unit` IS NULL) AS null_revenue_per_unit,
    SUM(`Demand-to-Inventory Ratio` IS NULL) AS null_demand_inventory_ratio
FROM cleaned_sales_data;

-- =====================================================================
-- BUSINESS QUESTION 1: Overall baseline KPIs
-- =====================================================================
SELECT
    COUNT(*) AS total_rows,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold,
    SUM(`Demand`) AS total_demand,
    SUM(`Inventory Level`) AS total_inventory_level,
    SUM(CASE WHEN `Demand` > `Inventory Level` THEN 1 ELSE 0 END) AS restock_needed,
    ROUND(SUM(`Revenue`) / NULLIF(SUM(`Units Sold`), 0), 2) AS avg_revenue_per_unit
FROM cleaned_sales_data;

-- =====================================================================
-- BUSINESS QUESTION 2: Monthly revenue and units sold
-- =====================================================================
SELECT
    `Month`,
    ROUND(SUM(`Revenue`), 2) AS monthly_revenue,
    SUM(`Units Sold`) AS monthly_units_sold
FROM cleaned_sales_data
GROUP BY `Month`
ORDER BY `Month`;

-- =====================================================================
-- BUSINESS QUESTION 3: Revenue and sales by category
-- =====================================================================
SELECT
    `Category`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold,
    ROUND(AVG(`Demand`), 2) AS average_demand
FROM cleaned_sales_data
GROUP BY `Category`
ORDER BY total_revenue DESC;

-- =====================================================================
-- BUSINESS QUESTION 4: Top product/category combinations by revenue
-- =====================================================================
SELECT
    `Product ID`,
    `Category`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold,
    ROUND(AVG(`Inventory Level`), 2) AS average_inventory
FROM cleaned_sales_data
GROUP BY `Product ID`, `Category`
ORDER BY total_revenue DESC
LIMIT 10;

-- =====================================================================
-- BUSINESS QUESTION 5: Revenue by region
-- =====================================================================
SELECT
    `Region`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold
FROM cleaned_sales_data
GROUP BY `Region`
ORDER BY total_revenue DESC;


-- =====================================================================
-- BUSINESS QUESTION 6: Store performance by revenue and unit sales
-- =====================================================================
SELECT
    `Store ID`,
    `Region`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold
FROM cleaned_sales_data
GROUP BY `Store ID`, `Region`
ORDER BY total_revenue DESC;

-- =====================================================================
-- BUSINESS QUESTION 7: Sales and demand across inventory bands
-- =====================================================================
SELECT
    CASE
        WHEN `Inventory Level` < 100 THEN 'Low (<100)'
        WHEN `Inventory Level` < 200 THEN 'Medium (100-199)'
        ELSE 'High (200+)'
    END AS inventory_band,
    COUNT(*) AS observations,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold,
    ROUND(AVG(`Demand`), 2) AS average_demand
FROM cleaned_sales_data
GROUP BY inventory_band
ORDER BY MIN(`Inventory Level`);

-- =====================================================================
-- BUSINESS QUESTION 8: High demand with below-average inventory
-- These are review candidates, not confirmed stockouts.
-- =====================================================================
WITH product_metrics AS (
    SELECT
        `Product ID`,
        `Category`,
        AVG(`Demand`) AS average_demand,
        AVG(`Inventory Level`) AS average_inventory,
        SUM(`Units Sold`) AS total_units_sold,
        SUM(`Revenue`) AS total_revenue
    FROM cleaned_sales_data
    GROUP BY `Product ID`, `Category`
)
SELECT
    `Product ID`,
    `Category`,
    ROUND(average_demand, 2) AS average_demand,
    ROUND(average_inventory, 2) AS average_inventory,
    total_units_sold,
    ROUND(total_revenue, 2) AS total_revenue
FROM product_metrics
WHERE average_demand > (SELECT AVG(`Demand`) FROM cleaned_sales_data)
  AND average_inventory < (SELECT AVG(`Inventory Level`) FROM cleaned_sales_data)
ORDER BY average_demand DESC, average_inventory ASC;

-- =====================================================================
-- BUSINESS QUESTION 9: Compare promotion and no-promotion observations
-- Descriptive comparison; it does not prove causation.
-- =====================================================================
SELECT
    CASE WHEN `Promotion` = 1 THEN 'Promotion' ELSE 'No promotion' END AS promotion_status,
    COUNT(*) AS observations,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold,
    ROUND(AVG(`Revenue`), 2) AS average_revenue,
    ROUND(SUM(`Revenue`), 2) AS total_revenue
FROM cleaned_sales_data
GROUP BY `Promotion`
ORDER BY `Promotion`;


-- =====================================================================
-- BUSINESS QUESTION 10: Sales and revenue by discount level
-- =====================================================================
SELECT
    `Discount`,
    COUNT(*) AS observations,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold,
    ROUND(AVG(`Revenue`), 2) AS average_revenue,
    ROUND(SUM(`Revenue`), 2) AS total_revenue
FROM cleaned_sales_data
GROUP BY `Discount`
ORDER BY `Discount`;


-- =====================================================================
-- BUSINESS QUESTION 11: Demand and revenue by season
-- =====================================================================
SELECT
    `Seasonality`,
    SUM(`Demand`) AS total_demand,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold
FROM cleaned_sales_data
GROUP BY `Seasonality`
ORDER BY total_revenue DESC;

-- =====================================================================
-- BUSINESS QUESTION 12: Product prioritization using revenue ranking
-- The management signal is a descriptive flag, not a replenishment rule.
-- =====================================================================
WITH product_metrics AS (
    SELECT
        `Product ID`,
        `Category`,
        SUM(`Revenue`) AS total_revenue,
        SUM(`Units Sold`) AS total_units_sold,
        AVG(`Demand`) AS average_demand,
        AVG(`Inventory Level`) AS average_inventory
    FROM cleaned_sales_data
    GROUP BY `Product ID`, `Category`
),
ranked_products AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY average_demand DESC) AS demand_rank
    FROM product_metrics
)
SELECT
    `Product ID`,
    `Category`,
    ROUND(total_revenue, 2) AS total_revenue,
    total_units_sold,
    ROUND(average_demand, 2) AS average_demand,
    ROUND(average_inventory, 2) AS average_inventory,
    revenue_rank,
    demand_rank,
    CASE
        WHEN average_demand > (SELECT AVG(`Demand`) FROM cleaned_sales_data)
         AND average_inventory < (SELECT AVG(`Inventory Level`) FROM cleaned_sales_data)
            THEN 'High demand, relatively low inventory'
        WHEN revenue_rank <= 5 THEN 'High revenue contributor'
        ELSE 'Monitor performance'
    END AS management_signal
FROM ranked_products
ORDER BY
    CASE
        WHEN average_demand > (SELECT AVG(`Demand`) FROM cleaned_sales_data)
         AND average_inventory < (SELECT AVG(`Inventory Level`) FROM cleaned_sales_data)
            THEN 0
        ELSE 1
    END,
    total_revenue DESC;






