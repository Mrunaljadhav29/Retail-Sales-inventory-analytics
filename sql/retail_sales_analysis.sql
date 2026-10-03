-- Retail Sales & Inventory Performance Analytics
-- MySQL 8.0+ project script: create schema, load the external CSV, verify, and analyze.
-- The CSV remains a separate file; no data rows are embedded in this SQL file.
-- The target table is rebuilt when this script runs so it contains the current CSV exactly.

-- 2. Create the project database.
CREATE DATABASE IF NOT EXISTS retail_sales;

-- 3. Select the project database.
USE retail_sales;


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
    `Revenue` DECIMAL(20, 15) NOT NULL,
    `Month` CHAR(7) NOT NULL,
    `Year` SMALLINT NOT NULL,
    `Revenue per Unit` DECIMAL(19, 16) NULL,
    `Inventory Gap` INT NOT NULL,
    `Demand-to-Inventory Ratio` DECIMAL(22, 19) NULL
);

-- 5. Load the external cleaned_sales_data.csv file.
-- LOCAL reads this path from the computer running MySQL Workbench.
-- MySQL client local-infile support and the server local_infile setting must both be enabled.
LOAD DATA LOCAL INFILE 'C:/Users/jadha/Desktop/Project/Retail Store Inventory and Demand Forecasting/cleaned_sales_data.csv'
INTO TABLE cleaned_sales_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@csv_date, `Store ID`, `Product ID`, `Category`, `Region`, `Inventory Level`,
 `Units Sold`, `Units Ordered`, `Price`, `Discount`, `Promotion`, `Seasonality`,
 `Demand`, `Revenue`, `Month`, `Year`,
 @csv_revenue_per_unit, `Inventory Gap`, @csv_demand_to_inventory_ratio)
SET
    `Date` = STR_TO_DATE(@csv_date, '%Y-%m-%d'),
    `Revenue per Unit` = NULLIF(@csv_revenue_per_unit, ''),
    `Demand-to-Inventory Ratio` = NULLIF(@csv_demand_to_inventory_ratio, '');

-- 6. Verify the imported row count. Expected result: 76000.
SELECT COUNT(*) AS total_rows
FROM cleaned_sales_data;

-- 7. Preview imported records.
SELECT *
FROM cleaned_sales_data
LIMIT 10;

-- 1. Business question: What are total revenue, units sold, and demand?
-- Method: Sum the three measures over all rows.
-- Result to review: The three totals establish the dataset-wide baseline.
SELECT
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold,
    SUM(`Demand`) AS total_demand
FROM cleaned_sales_data;

-- 2. Business question: How do revenue and units sold change by month?
-- Method: Sum the measures by the notebook-created Month field.
-- Result to review: Compare month-to-month totals; Month is already YYYY-MM.
SELECT
    `Month`,
    ROUND(SUM(`Revenue`), 2) AS monthly_revenue,
    SUM(`Units Sold`) AS monthly_units_sold
FROM cleaned_sales_data
GROUP BY `Month`
ORDER BY `Month`;

-- 3. Business question: Which categories generate the most revenue and sales?
-- Method: Aggregate revenue, units sold, and average demand by category.
-- Result to review: Sort order puts the highest-revenue categories first.
SELECT
    `Category`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold,
    ROUND(AVG(`Demand`), 2) AS average_demand
FROM cleaned_sales_data
GROUP BY `Category`
ORDER BY total_revenue DESC;

-- 4. Business question: Which product/category combinations lead in revenue?
-- Method: Aggregate revenue, units sold, and average inventory by both fields.
-- Result to review: The ten highest-revenue combinations appear first.
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

-- 5. Business question: Which regions generate the most revenue?
-- Method: Sum revenue and units sold by region.
-- Result to review: Compare the revenue ranking and unit totals by region.
SELECT
    `Region`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold
FROM cleaned_sales_data
GROUP BY `Region`
ORDER BY total_revenue DESC;

-- 6. Business question: Which stores perform best by revenue and unit sales?
-- Method: Sum revenue and units sold by store and region.
-- Result to review: Compare store totals; region is retained as context.
SELECT
    `Store ID`,
    `Region`,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold
FROM cleaned_sales_data
GROUP BY `Store ID`, `Region`
ORDER BY total_revenue DESC;

-- 7. Business question: How do sales and demand vary across inventory bands?
-- Method: Use CASE to assign each row to a low, medium, or high inventory band.
-- Result to review: Compare observation counts and average sales/demand by band.
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

-- 8. Business question: Which products have above-average demand and below-average inventory?
-- Method: Build product/category averages, then compare them with overall row averages.
-- Result to review: These are relative review candidates, not confirmed stockouts.
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

-- 9. Business question: How do promotion and no-promotion observations compare?
-- Method: Compare counts, average units sold, average revenue, and total revenue.
-- Result to review: Differences are descriptive and do not prove promotion impact.
SELECT
    CASE WHEN `Promotion` = 1 THEN 'Promotion' ELSE 'No promotion' END AS promotion_status,
    COUNT(*) AS observations,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold,
    ROUND(AVG(`Revenue`), 2) AS average_revenue,
    ROUND(SUM(`Revenue`), 2) AS total_revenue
FROM cleaned_sales_data
GROUP BY `Promotion`
ORDER BY `Promotion`;

-- 10. Business question: How do sales and revenue vary across discount levels?
-- Method: Compare observation counts and sales/revenue aggregates by discount.
-- Result to review: Group differences are descriptive, not a causal estimate.
SELECT
    `Discount`,
    COUNT(*) AS observations,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold,
    ROUND(AVG(`Revenue`), 2) AS average_revenue,
    ROUND(SUM(`Revenue`), 2) AS total_revenue
FROM cleaned_sales_data
GROUP BY `Discount`
ORDER BY `Discount`;

-- 11. Business question: Which seasons have the highest demand and revenue?
-- Method: Sum demand and revenue and average units sold by season.
-- Result to review: Sorted totals show the highest-revenue season first.
SELECT
    `Seasonality`,
    SUM(`Demand`) AS total_demand,
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    ROUND(AVG(`Units Sold`), 2) AS average_units_sold
FROM cleaned_sales_data
GROUP BY `Seasonality`
ORDER BY total_revenue DESC;

-- 12. Business question: Which products merit review based on revenue, demand, and inventory?
-- Method: Rank product/category combinations and label relative demand/inventory signals.
-- Result to review: Check ranks and management_signal; this is not a replenishment rule.
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
    CASE WHEN average_demand > (SELECT AVG(`Demand`) FROM cleaned_sales_data)
           AND average_inventory < (SELECT AVG(`Inventory Level`) FROM cleaned_sales_data)
         THEN 0 ELSE 1 END,
    total_revenue DESC;

-- Interview check:
-- 1. Why do queries 8 and 12 group by both Product ID and Category?
-- 2. What does RANK add to the product prioritization output?
-- 3. Why is the promotion comparison descriptive rather than causal?






SELECT
    ROUND(SUM(`Revenue`), 2) AS total_revenue,
    SUM(`Units Sold`) AS total_units_sold,
    SUM(`Demand`) AS total_demand
FROM cleaned_sales_data;