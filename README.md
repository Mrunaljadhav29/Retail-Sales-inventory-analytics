# Retail Sales & Inventory Performance Analytics

A beginner-friendly data analytics project that uses **Python, MySQL and Power BI** to understand a retail business: where the money comes from, where stock may run short, and how promotions and discounts relate to sales.

![Power BI Dashboard](assets/dashboard.png)

## 1. Introduction

This project looks at retail sales and inventory data to answer simple business questions about categories, stores, regions, promotions and discounts. I took it from raw data to business insights and an interactive dashboard.

## 2. Business Problem

A retail business needs a simple way to answer questions like:

- Which categories and regions earn the most revenue?
- Where is inventory under pressure?
- Which stores and products perform better?
- Do sales change by month or season?
- How do promotions and discounts relate to sales?

The goal is one clear view of sales, demand and inventory, so managers know where to look closer.

## 3. Dataset

Source: **Retail Store Inventory and Demand Forecasting** dataset from Kaggle. It is a synthetically generated retail dataset, so the results show the method and are not real company results.

[Dataset on Kaggle](https://www.kaggle.com/datasets/atomicd/retail-store-inventory-and-demand-forecasting)

| Item | Detail |
|---|---|
| Rows | 76,000 |
| Columns | 16 original, 19 in the final project data |
| Stores / Products | 5 stores, 20 product IDs |
| Categories | Clothing, Electronics, Furniture, Groceries, Toys |
| Regions / Seasons | 4 regions, 4 seasons |
| Dates | 1 January 2022 to 30 January 2024 |

The currency is not given in the data. Dollar ($) signs are used only for display.

## 4. Tools Used

| Tool | What I used it for |
|---|---|
| Python (Pandas, Matplotlib) | Cleaning data, creating new metrics, exploring the data |
| MySQL | Answering business questions and checking the final KPIs |
| Power BI and DAX | KPI calculations and the interactive dashboard |

## 5. What I Did

`Raw Data → Python → Cleaned CSV → MySQL → Power BI`

- **Python:** cleaned the data, checked duplicates and data types, created new metrics and saved the final CSV.
- **SQL:** loaded the CSV into MySQL and answered questions about months, categories, products, stores, regions, inventory, promotions, discounts and seasons. I also used SQL to check the final KPIs.
- **Power BI:** built KPI cards, filters (slicers) and charts in one dashboard page.

## 6. Metrics I Created

```text
Revenue                    = Units Sold × Price
Revenue per Unit           = Revenue ÷ Units Sold
Inventory Gap              = Inventory Level − Units Sold
Demand-to-Inventory Ratio  = Demand ÷ Inventory Level
