# Retail Sales & Inventory Performance Analytics

**Tools:** Python (Pandas, NumPy, Matplotlib) · MySQL 8 · Power BI · DAX  
**Domain:** Retail Sales and Inventory Analytics  
**Project type:** Descriptive and diagnostic analytics

![Retail Sales & Inventory Dashboard](assets/dashboard.png)

> **Project takeaway:** I analyzed 76,000 retail observations to understand revenue concentration and identify where recorded demand exceeded available inventory. In this dataset, demand exceeded inventory in **13.68%** of observations, with Clothing showing the highest review rate at **19.42%**.

> **Dataset note:** The Kaggle dataset is synthetically generated. The figures below demonstrate an analytics workflow and should not be interpreted as results from a real retailer.

## 1. Business Problem

Retail teams need to understand which categories and regions contribute most to revenue, how performance changes over time, and where demand may be greater than recorded inventory. A useful analysis should connect those patterns to specific areas for review without treating every inventory gap as a confirmed stockout.

This project investigates four questions:

- Which categories and regions account for the largest shares of revenue?
- How do sales and revenue vary across time and retail segments?
- How often does recorded demand exceed inventory, and where is this most common?
- How do sales observations during promotions compare with non-promotion observations?

## 2. Dataset and Source

The project uses the [Retail Store Inventory and Demand Forecasting dataset on Kaggle](https://www.kaggle.com/datasets/atomicd/retail-store-inventory-and-demand-forecasting). The final analysis file contains **76,000 rows and 19 fields**, covering **1 January 2022 through 30 January 2024**.

| Dataset characteristic | Detail |
|---|---:|
| Original fields | 16 |
| Final fields | 19 |
| Stores | 5 |
| Product IDs | 20 |
| Product categories | 5 |
| Regions | 4 |
| Seasons | 4 |

The source includes date, store and product identifiers, category and region, inventory level, units sold, units ordered, price, discount, promotion, seasonality, weather, competitor pricing, epidemic indicator, and demand. The prepared project data excludes Weather Condition, Competitor Pricing, and Epidemic, and adds analytical fields for revenue and inventory-demand comparison.

**Currency note:** The source does not specify a monetary unit. The dashboard uses `$` as a display convention only; it should not be interpreted as a verified USD denomination.

## 3. Tools and Methodology

### Python: preparation and exploratory analysis

- Used Pandas to load, inspect, and prepare the dataset.
- Reviewed data types, missing values, duplicate rows, and date consistency.
- Parsed date fields and created month/year features.
- Added calculated measures and exported the prepared data for SQL and Power BI.
- Used summary statistics, charts, and correlation analysis to explore sales, revenue, demand, and inventory patterns.

### Derived measures

```text
Revenue = Units Sold × Price
Revenue per Unit = Revenue ÷ Units Sold
Inventory Gap = Inventory Level − Units Sold
Demand-to-Inventory Ratio = Demand ÷ Inventory Level
```

Revenue is calculated using the project's documented formula before the separate `Discount` field is applied. Discount is analyzed as a distinct dimension. Ratio calculations are left blank when their denominator is zero.

For the inventory review, an observation is flagged when `Demand > Inventory Level`. This is a screening indicator for further investigation, not confirmation that a stockout occurred or a calculation of how many units to reorder.

### MySQL: business questions and validation

- Imported the prepared data into `cleaned_sales_data`.
- Checked row counts and reconciled headline metrics.
- Used aggregations, `CASE`, CTEs, and ranking/window functions to compare performance by month, category, product, region, store, promotion, discount, and seasonality.
- Wrote a product-prioritization query combining revenue rank with relative demand and inventory indicators.

### Power BI and DAX: reporting

Built an interactive dashboard with KPI cards, slicers, revenue trends, category and regional comparisons, and demand-versus-inventory views.

## 4. Key Results

| KPI | Result |
|---|---:|
| Total gross revenue (before discounts) | **$455,300,094.50** |
| Total units sold | **6,750,876** |
| Total demand | **7,928,104** |
| Average inventory level per observation | **301.06** |
| Average revenue per unit (total gross revenue ÷ total units sold) | **$67.44** |
| Observations where demand exceeds inventory | **10,394 of 76,000 (13.68%)** |
| Gross revenue in 2022 | **Approximately $222.2M** |
| Gross revenue in 2023 | **Approximately $216.3M** |
| Revenue change, 2023 vs. 2022 | **−2.66%** |
| Highest seasonal share of revenue | **Winter — 27.55%** |
| Groceries share of gross revenue | **37.09%** |
| North region share of gross revenue | **37.34% — combined across two stores** |

\* The dataset source does not specify a currency; `$` is used for display only. Gross revenue is calculated as `Units Sold × Price`, before discounts. The displayed average revenue per unit (**$67.44**) is total gross revenue divided by total units sold; the unweighted mean of the row-level `Revenue per Unit` field is **67.73**. The dollar symbol is a display convention only.

### Three findings that matter

1. **Inventory review flags are common enough to investigate:** demand exceeds recorded inventory in **10,394 observations (13.68%)**; this is a screening signal, not confirmation of a stockout or a precise reorder quantity.
2. **The inventory review rate varies by category:** Clothing is highest at **19.42%**, while Furniture is lowest at **7.84%**; the dashboard's **Restock Needed** card represents observations where `Demand > Inventory Level`.
3. **Revenue patterns vary by category, season, year, and store:** Groceries accounts for **37.09%** of gross revenue, Winter contributes the highest seasonal share (**27.55%**), and 2023 revenue was approximately **2.66% below** 2022 (about **$216.3M vs. $222.2M**). North's **37.34%** share combines two stores—S001 (**19.74%**) and S005 (**17.60%**), the two lowest-earning stores individually—so the regional total should not be interpreted as stronger per-store performance. January 2024 is partial and should not be compared with a complete year.

### Promotion comparison

Average units sold are **103.10** for promotion observations versus **81.83** for non-promotion observations—approximately **26% higher** in the promotion group. This is an observational comparison, not proof that promotions caused the difference; product mix, timing, and other factors may also matter.

## 5. Dashboard

The Power BI report in `powerbi/` presents:

- KPI cards for revenue, units sold, demand, and inventory-related measures.
- Slicers for year, region, category, and seasonality.
- Monthly revenue trends and revenue by category and region.
- Demand-versus-inventory comparisons by category and inventory by region.

The screenshot at the top of this README is `assets/dashboard.png`.

## 6. Business Recommendations

- **Prioritize inventory reviews:** start with Clothing, which has the highest demand-exceeds-inventory review rate at **19.42%**; inspect the affected store-product combinations before adjusting replenishment.
- **Review demand before promotion periods:** compare inventory and sales for similar products, stores, and time periods before deciding whether inventory buffers need adjustment.
- **Monitor revenue by category, season, and store:** track Groceries, which contributes **37.09%** of gross revenue, and investigate the Winter peak (**27.55%** of revenue). North’s **37.34%** share aggregates two stores and does not indicate stronger per-store performance; compare S001 and S005 with the other stores individually. Revenue in 2023 was approximately **2.66% lower** than in 2022. The January 2024 data is partial.
- **Investigate promotion performance fairly:** compare similar categories, stores, and periods to reduce the risk of mistaking a difference in product mix for a promotion effect.
- **Use inventory flags as leads, not automatic orders:** validate demand and inventory records and consider supplier lead times and replenishment constraints before determining order quantities.

## 7. Validation and Limitations

- The notebook includes checks for row count, column structure, date parsing, month/year consistency, duplicate rows, derived metrics, and headline KPIs.
- The dataset is synthetically generated and does not represent verified results from a named retailer.
- The source does not specify a currency.
- `Demand > Inventory Level` is a review signal, not evidence of a confirmed stockout or the number of units that should be reordered.
- No cost or profit field is included, so gross profit and margin cannot be calculated.
- Customer-level information and supplier lead-time data are not available.
- Promotion and discount comparisons are observational and do not establish causal effects.
- January 2024 is a partial month; compare it carefully with complete months.

## 8. Reproducibility

1. Download the raw dataset from the [Kaggle source](https://www.kaggle.com/datasets/atomicd/retail-store-inventory-and-demand-forecasting).
2. Rename the downloaded input CSV to `sales_data.csv` to match the notebook, or edit the notebook input path to match your downloaded filename.
3. Run `python/retail_sales_analysis.ipynb` from top to bottom to inspect and prepare the data and export the cleaned dataset.
4. Import `data/cleaned_sales_data.csv` into MySQL using `sql/retail_sales_analysis.sql`. Before running the load statement, replace the personal local path currently in the SQL script with your own local path or a clear placeholder.
5. Run the SQL validation and analysis queries, then compare headline metrics with the notebook output.
6. Open `powerbi/Retail_Sales_Inventory.pbix` and compare its KPI values with the prepared data and SQL results.

