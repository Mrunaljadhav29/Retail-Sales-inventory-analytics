Retail Sales & Inventory Performance Analytics

An end-to-end data analytics project using Python, MySQL and Power BI to find where revenue comes from, where inventory is under pressure, and how categories, stores, regions, promotions and discounts perform.

Show Image

1. Business Problem

A retail business needs one consistent view of sales, demand and inventory to answer questions such as:

Which categories and regions generate the most revenue?
Where is inventory under pressure?
Which stores and products perform better?
Does sales activity change by month or season?
How do promotion and discount levels relate to sales?

The goal is to help managers decide where to investigate further, using KPIs that match across Python, SQL and Power BI.

2. Dataset
Item	Detail
Rows / Columns	76,000 / 19
Period	1 Jan 2022 to 30 Jan 2024
Stores / Products	5 stores, 20 product IDs
Categories	Clothing, Electronics, Furniture, Groceries, Toys
Regions / Seasons	4 regions (North, East, South, West), 4 seasons
Contents	Sales, inventory, demand, price, discount, promotion and calculated measures

The source does not document its currency. USD ($) is used for display only.

3. Tools
Tool	Used for
Python (Pandas, Matplotlib)	Cleaning, feature engineering, EDA, CSV export
MySQL	Data loading, validation and business analysis with aggregations, CASE, CTEs and window functions
Power BI + DAX	KPI measures and interactive dashboard
4. Workflow

Raw Data → Python → Cleaned CSV → MySQL → Power BI

Python: checked missing values, duplicates and data types, created new metrics, ran exploratory analysis and exported the final CSV. SQL: loaded the CSV and answered questions on monthly performance, categories, products, stores, regions, inventory, promotions, discounts and seasonality. A final validation query recalculates the headline KPIs. Power BI: built DAX measures and a one-page dashboard with KPI cards, slicers and charts.

5. Calculated Fields
text
Revenue                    = Units Sold × Price
Revenue per Unit           = Revenue ÷ Units Sold
Inventory Gap              = Inventory Level − Units Sold
Demand-to-Inventory Ratio  = Demand ÷ Inventory Level

The ratios are left blank (not filled with 0) when their denominator is zero:

Revenue per Unit is blank where Units Sold = 0 (406 rows).
Demand-to-Inventory Ratio is blank where Inventory Level = 0 (406 rows).
6. Key KPIs
KPI	Definition	Value
Total Revenue	Sum of Revenue	$455,300,094.50
Total Units Sold	Sum of Units Sold	6,750,876
Total Demand	Sum of Demand	7,928,104
Total Inventory Level	Sum of Inventory Level across all rows	22,880,776
Avg Inventory Level	Average inventory per row	301.06
Avg Revenue per Unit	Total Revenue ÷ Total Units Sold	$67.44
Restock Needed	Rows where Demand > Inventory Level	10,394 (13.68% of rows)

These headline KPIs were validated in Python and SQL and match the Power BI dashboard values.

7. Key Insights

Percentages are calculated from the project data. Promotion and discount results are descriptive and do not prove cause and effect.

Insight	Evidence	Why it matters
About 1 in 7 observations show restock pressure	10,394 of 76,000 rows (13.68%)	A review signal, not a confirmed stockout
Clothing has the highest restock rate	19.42%, vs 7.84% for Furniture	Where stock review is most worthwhile
Groceries lead revenue	37.09% of revenue, 46.32% of units	Big contributor at only $54 per unit
Furniture earns more per unit	24.44% of revenue from 13.05% of units ($126 per unit)	High-value, low-volume category
North leads regions	37.34% of revenue	North has 2 of the 5 stores
Promotion rows sell more per row	103.10 vs 81.83 average units	Promotion rows also show higher demand and a 19.56% restock rate vs 10.79%
Yearly revenue dipped slightly	2023 was 2.66% below 2022	January 2024 has only 30 days, so it is left out of the comparison
8. Dashboard
KPI cards: Total Inventory Level, Total Revenue, Avg Inventory Level, Avg Revenue per Unit, Restock Needed
Slicers: Year, Region, Category, Seasonality
Charts: Monthly Revenue Trend, Revenue by Category, Revenue by Region, Demand vs Inventory by Category, Inventory by Region
9. Recommendations
Review reorder levels for Clothing first (highest restock rate).
Check stock before promotion periods, since promotion rows show tighter inventory.
Investigate store-product combinations where Units Sold equals Inventory Level (8,654 rows, 11.39%), as sales may have been limited by stock.
Compare Store S005 (lowest revenue per unit, $58.81) with S003 on category and price mix.
Compare regions per store, not in total.
10. Limitations
No cost, profit, customer or supplier lead-time data.
Promotion and discount overlap (no non-promotion row has a discount above 10%), so their effects cannot be separated.
Restock Needed and Inventory Gap are row-level review signals, not confirmed stockouts or purchase quantities.
Dataset provenance is not documented.
11. How to Reproduce
Run python/retail_sales_analysis.ipynb to produce cleaned_sales_data.csv.
In sql/retail_sales_analysis.sql, change the file path in LOAD DATA LOCAL INFILE to your own. Make sure the Date format in the CSV matches the STR_TO_DATE format in the script.
Run the script in MySQL 8 and check the validation query against the KPI table above.
Open powerbi/retail_sales.pbix.
12. Repository Structure
text
├── data/
│   └── cleaned_sales_data.csv
├── python/
│   └── retail_sales_analysis.ipynb
├── sql/
│   └── retail_sales_analysis.sql
├── powerbi/
│   └── retail_sales.pbix
├── assets/
│   ├── dashboard.png
│   ├── python_verification.png
│   └── sql_verification.png
└── README.md
13. What I Learned
Defining a KPI clearly (for example, Restock Needed) matters as much as calculating it.
Totals should be reconciled across tools before they go on a dashboard.
A descriptive comparison, such as promotion vs no promotion, should not be presented as proof of impact.
Totals can hide structure, for example North's lead comes from having two stores.
14. Next Improvements
Add cost data to measure profit and margin.
Add Units Sold by Seasonality and Avg Revenue per Unit by Region to the dashboard.
Add more SQL validation queries (null counts, date range).
Document the dataset source.
Author

Mrunal Jadhav, aspiring Data Analyst, Pune, India GitHub · LinkedIn
