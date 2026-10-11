# Retail Sales & Customer Analytics

## Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist using PostgreSQL to explore sales performance, product-category contributions, and customer purchasing behavior.

The database contains **99,441 orders** of which 96,478 were marked as delivered. The primary sales and customer segmentation analyses focus on delivered orders. This analysis demonstrates how SQL can transform relational transaction data into actionable business insights.

The project includes database design, data validation, multi-table joins, aggregations, Common Table Expressions (CTEs), window functions, and Recency, Frequency, Monetary (RFM) customer segmentation.

## Business Questions

The project investigates:

1. What is the total recorded product value, and how much is associated with delivered orders?
2. What is the average order value?
3. Which months generated the highest delivered-order product value?
4. Which product categories contributed most to sales?
5. How concentrated is product value across categories?
6. How can customers be segmented using purchasing behavior?
7. Which customer segments have the highest historical value?
8. What business opportunities emerge from the analysis?

## Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

**Provider:** Olist  
**Database:** PostgreSQL  
**Database management:** pgAdmin 4

The dataset contains anonymized Brazilian e-commerce transactions from 2016 to 2018.

### Tables Used

| Table | Records |
|---|---:|
| customers | 99,441 |
| orders | 99,441 |
| order_items | 112,650 |
| products | 32,951 |
| category_translation | Not separately counted |

### Database Relationships

The main relational structure is:

`customers → orders → order_items → products`

The `category_translation` table provides English category names.

![Database Tables](screenshots/01_database_tables.png)

## Data Validation

Before conducting the analysis, SQL queries were used to check database completeness and relational consistency.

The validation confirmed:

- All 99,441 order IDs were unique.
- All 112,650 order-item records matched an existing order.
- All 112,650 order-item records linked to a valid customer.
- 98,666 orders contained at least one order-item record.
- 96,478 orders had a delivered status.

These checks helped prevent duplicate counting and identify differences between recorded orders and orders containing items.

## Tools and SQL Techniques

**Tools:** PostgreSQL, pgAdmin 4, GitHub

**SQL techniques demonstrated:**

- Relational database design
- Primary and foreign keys
- SELECT, WHERE, GROUP BY, ORDER BY
- Aggregate functions: SUM, AVG, COUNT
- INNER JOIN and LEFT JOIN
- Subqueries and derived tables
- Common Table Expressions (CTEs)
- CASE expressions
- COALESCE and NULLIF
- Date functions and DATE_TRUNC
- Window functions: RANK, NTILE
- Percentage-of-total calculations
- RFM customer segmentation

## Sales Analysis

Product value was calculated using item prices, excluding freight charges.

Two measures were distinguished:

| KPI | Value |
|---|---:|
| Total recorded product value | R$13,591,643.70 |
| Delivered-order product value | R$13,221,498.11 |
| Average order value — all orders with items | R$137.75 |
| Average order value — delivered orders | R$137.04 |
| Delivered orders | 96,478 |

Delivered-order product value was used as the primary fulfilled-sales proxy. It should not be interpreted as verified accounting revenue.

### Top 5 Sales Months

Months are based on the original purchase date of orders subsequently marked as delivered.

| Rank | Month | Product Value |
|---|---|---:|
| 1 | November 2017 | R$987,765.37 |
| 2 | May 2018 | R$977,544.69 |
| 3 | April 2018 | R$973,534.09 |
| 4 | March 2018 | R$953,356.25 |
| 5 | January 2018 | R$924,645.00 |

![Monthly Sales Analysis](screenshots/02_monthly_revenue.png)

**Finding:** November 2017 recorded the highest delivered-order product value, at approximately R$987,765.

Four of the five highest-performing months occurred in 2018. However, this ranking alone does not establish consistent month-over-month growth.

## Product Category Analysis

Product categories were evaluated using delivered-order product value, item counts, category rankings, and percentage contributions.

| Category | Product Value | Share |
|---|---:|---:|
| Health & Beauty | R$1,233,131.72 | 9.33% |
| Watches & Gifts | R$1,166,176.98 | 8.82% |
| Bed, Bath & Table | R$1,023,434.76 | 7.74% |
| Sports & Leisure | R$954,852.55 | 7.22% |
| Computers & Accessories | R$888,724.61 | 6.72% |

![Product Category Analysis](screenshots/03_category_analysis.png)

### Key Findings

**Health & Beauty** generated the highest product value, accounting for approximately 9.33% of analyzed category value.

**Watches & Gifts** generated substantial product value despite selling fewer items than Health & Beauty, suggesting a higher average item price.

**Bed, Bath & Table** recorded the highest item count among the top five categories, demonstrating that high sales volume does not necessarily produce the highest product value.

The top five categories accounted for approximately **39.83%** of analyzed category product value.

## Customer RFM Segmentation

Customers were identified using `customer_unique_id` and classified according to three dimensions:

**Recency (R):** Days since the customer's most recent purchase, measured relative to the latest purchase date among delivered orders.

**Frequency (F):** Number of distinct delivered orders associated with the customer.

**Monetary (M):** Total product value associated with delivered orders.

Recency and monetary values were scored using `NTILE(5)`, while frequency was scored according to actual purchase counts.

Customers were classified into six analyst-defined segments.

### Segmentation Results

| Segment | Customers | Product Value | Avg. Customer Value | Share |
|---|---:|---:|---:|---:|
| Recent Customers | 36,140 | R$5,071,407.73 | R$140.33 | 38.71% |
| At Risk – High Value | 14,537 | R$4,050,384.50 | R$278.63 | 15.57% |
| Potential Customers | 18,069 | R$2,343,910.03 | R$129.72 | 19.35% |
| Inactive Customers | 22,807 | R$1,276,077.61 | R$55.95 | 24.43% |
| Champions | 932 | R$305,370.50 | R$327.65 | 1.00% |
| Loyal Customers | 873 | R$174,347.74 | R$199.71 | 0.94% |

**Total customers analyzed:** 93,358

![Customer Segmentation](screenshots/04_customer_segments.png)

### Key Findings

**Recent Customers** formed the largest segment, representing 38.71% of analyzed customers.

**At Risk – High Value** customers accounted for 15.57% of customers but contributed approximately R$4.05 million in historical product value. This makes them a potentially important group for re-engagement.

**Champions** represented only 1.00% of customers but recorded the highest average customer value, at R$327.65.

**Inactive Customers** represented 24.43% of customers and had a relatively low average historical value of R$55.95.

These segments are descriptive classifications based on historical transactions, not predictions of future purchasing behavior.

## Business Recommendations

### 1. Prioritize high-value customer retention

The At Risk – High Value segment has substantial historical purchasing value. Targeted re-engagement campaigns could be tested to determine whether these customers can be encouraged to purchase again.

### 2. Strengthen relationships with valuable customers

Champions have the highest average customer value. Loyalty benefits and personalized communication could help maintain these relationships.

### 3. Investigate product-category opportunities

Health & Beauty and Watches & Gifts are major contributors to delivered-order product value. Their performance warrants further investigation into pricing, product mix, and sales volume.

### 4. Monitor monthly sales performance

Monthly product-value analysis can help identify seasonal patterns and inform planning. Further analysis would be required to distinguish seasonality from general market growth.

## Methodology and Limitations

- The analysis uses historical transactions from 2016–2018 and does not represent current marketplace performance.
- Delivered-order product value is used as a proxy for fulfilled sales, not verified revenue recognition.
- Freight charges are excluded from product-value calculations.
- The monthly analysis groups delivered orders by purchase month, not delivery month.
- The first and final months may represent incomplete reporting periods.
- RFM segments are based on analyst-defined scoring thresholds.
- Customers with identical recency or monetary values may receive different NTILE scores at quintile boundaries.
- Category revenue shares depend on successful matching between order items and product records.
- Repeat-purchase rates should be recalculated using the delivered-order population before being included in the final findings.

## Reproducing the Analysis

1. Download the Olist dataset from the source linked above.
2. Create a PostgreSQL database.
3. Execute `01_database_setup.sql` to create the five tables.
4. Import the five CSV files into PostgreSQL in this order:

   `customers → orders → products → category_translation → order_items`

   Ensure the CSV columns match the database schema.
5. Run `02_sales_analysis.sql` to examine sales performance.
6. Run `03_product_analysis.sql` to analyze product categories.
7. Run `04_customer_segmentation.sql` to calculate customer RFM segments.

The SQL scripts are intended to be executed in numerical order. Database setup is required only once.

## Project Structure

```text
retail-sql-analytics/
├── README.md
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_sales_analysis.sql
│   ├── 03_product_analysis.sql
│   └── 04_customer_segmentation.sql
└── screenshots/
    ├── 01_database_tables.png
    ├── 02_monthly_revenue.png
    ├── 03_category_analysis.png
    └── 04_customer_segments.png
```

## Author

**Ian Mark Esipisu**

Data Analytics | SQL | PostgreSQL | Research | Financial Engineering

