# Retail Sales & Inventory Performance Analytics

An end-to-end Data Analytics project using **Python, SQL, and Power BI** to understand retail sales, demand, inventory pressure, and business performance.

![Power BI Dashboard](assets/dashboard.png)

## 📌 Business Problem

A retail business needs one clear view of:

- Sales and revenue performance
- Inventory and demand pressure
- Category and regional performance
- Store performance
- Promotion and discount patterns

The goal of this project was to turn raw sales data into useful business insights and an interactive dashboard.

## 🎯 What I Did

I followed a simple analytics workflow:

**Python → SQL → Power BI**

- Cleaned and prepared the data using Python
- Created useful business metrics
- Explored sales, inventory and demand patterns
- Used MySQL for business analysis
- Built an interactive Power BI dashboard
- Cross-checked the important KPIs across the workflow

## 📊 Dataset

- **76,000 rows**
- **19 final columns**
- **Date:** January 2022 – January 2024
- **5 stores**
- **20 product IDs**
- **5 categories**
- **4 regions**

The final dataset contains sales, inventory, demand, pricing, promotion and derived performance metrics.

## 🛠 Tools Used

| Tool | Purpose |
|---|---|
| Python | Cleaning, feature engineering, EDA |
| Pandas | Data manipulation |
| Matplotlib | Visualization |
| MySQL | Business analysis and SQL queries |
| Power BI | Dashboard and reporting |
| DAX | KPI measures |

## 🔧 Key Metrics Created

Some of the main calculated fields were:

```text
Revenue = Units Sold × Price

Revenue per Unit = Revenue ÷ Units Sold

Inventory Gap = Inventory Level − Units Sold

Demand-to-Inventory Ratio = Demand ÷ Inventory Level
