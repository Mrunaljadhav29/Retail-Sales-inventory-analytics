# Retail Sales & Inventory Performance Analytics

## 1. Introduction

This project looks at retail sales and inventory data to understand where revenue is coming from, where inventory pressure exists, and how different categories, stores, regions, promotions, and discounts perform.

I used **Python, MySQL, and Power BI** to take the project from raw data to business insights and an interactive dashboard.

![Power BI Dashboard](assets/dashboard.png)

---

## 2. Business Problem

A retail business needs a simple way to answer questions such as:

- Which categories and regions generate the most revenue?
- Where is inventory under pressure?
- Which stores and products perform better?
- Does sales activity change by month or season?
- How do promotion and discount levels relate to sales?

The main goal was to create **one consistent view of sales, demand, and inventory** that can help managers decide where to investigate further.

---

## 3. Dataset

The final dataset contains:

- **76,000 rows**
- **19 columns**
- **5 stores**
- **20 product IDs**
- **5 categories**
- **4 regions**
- **4 seasons**
- **Date range:** January 2022 to January 2024

The final data includes sales, inventory, demand, price, discount, promotion, and calculated performance measures. :chatgpt-content-reference{index="0"}

---

## 4. Tools Used

| Tool | What I used it for |
|---|---|
| Python | Data cleaning, feature engineering and EDA |
| Pandas | Data preparation and analysis |
| Matplotlib | Exploratory visualizations |
| MySQL | Business questions and SQL analysis |
| Power BI | Interactive dashboard |
| DAX | KPI calculations |

---

## 5. What I Did

I followed a simple end-to-end workflow:

**Raw Data → Python → Cleaned CSV → MySQL → Power BI**

### Python

I cleaned the dataset, checked duplicates and data types, created new metrics, performed exploratory analysis, and exported the final cleaned dataset.

### SQL

I loaded the cleaned data into MySQL and used SQL to answer business questions around:

- Monthly performance
- Categories
- Products
- Stores
- Regions
- Inventory
- Promotions
- Discounts
- Seasonality

### Power BI

I converted the analysis into an interactive dashboard with KPI cards, slicers, and business charts.

---

## 6. Key Metrics Created

```text
Revenue
= Units Sold × Price

Revenue per Unit
= Revenue ÷ Units Sold

Inventory Gap
= Inventory Level − Units Sold

Demand-to-Inventory Ratio
= Demand ÷ Inventory Level
