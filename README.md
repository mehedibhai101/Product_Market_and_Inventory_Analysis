# 📊 Project Background: BanglaBazaar FMCG Operations

BanglaBazaar.com is one of Bangladesh's largest e-commerce platforms. Since its inception in 2018, the company has transitioned from a generalist marketplace to a logistics-heavy retail powerhouse. This project focuses specifically on the **FMCG & Grocery division**, which is the company's highest-frequency business unit.

As a Data Analyst within the Operations & Supply Chain team, my objective was to evaluate the efficiency of our **3.67 Billion BDT** annual revenue stream. While the business is growing, we faced challenges with regional stock distribution and inventory spoilage. This analysis serves as a strategic review to move the company from "reactive" stock management to "predictive" supply chain flow.

Insights and recommendations are provided on the following key areas:

* **Regional Supply Chain Polarization** (Dhaka vs. Regional Hubs)
* **Inventory Health & Expiry Risk** (Protecting Margins from Spoilage)
* **Market Basket Affinity** (Unlocking Revenue through Bundling)
* **Operational Quality & Return Mitigation** (Reducing Reverse Logistics Costs)

https://github.com/user-attachments/assets/559225a4-232d-4c74-b1d5-0f00aaef6c73

**PowerQuery M Code regarding data preparation process of various tables can be found [[here]](https://github.com/mehedibhai101/Product_Market_and_Inventory_Analysis/tree/main/Data%20Cleaning).**

**DAX queries regarding various analytical calculations can be found [[here]](https://github.com/mehedibhai101/Product_Market_and_Inventory_Analysis/tree/main/DAX%20Calculations).**

**An interactive Power BI dashboard used to report and explore sales trends can be found [[here]](https://app.powerbi.com/view?r=eyJrIjoiODQ5NDVlYWUtMmUzYS00YTViLWE0Y2UtZDZiODdmNjc2ZTc5IiwidCI6IjAwMGY1Mjk5LWU2YTUtNDYxNi1hNTI4LWJjZTNlNGUyYjk4ZCIsImMiOjEwfQ%3D%3D).**

---

# 🏗️ Data Structure & Initial Checks

The company's primary analytics database for the FMCG division is structured as a Star Schema, containing over **2.2 Million records**. The core data resides in four primary tables:

* **`fact_sales_lines`:** Contains 2.2M+ transaction rows, tracking MRP, unit costs, and discounts for every item sold.
* **`fact_inventory_batches`:** Tracks 7,500+ unique batches with granular Manufacturing (MFG) and Expiry date data.
* **`fact_stock_movements`:** Logs all warehouse activity, including PO receipts, returns, and stock adjustments.
* **`fact_reviews_feedback`:** Aggregates customer ratings and sentiment scores, linked to specific return reason codes.

### 🗺️ Entity Relationship Diagram (ERD)
![Entity Relationship Diagram](Dataset/entity_relationship_diagram.svg)

---

# 📋 Executive Summary

### Overview of Findings

BanglaBazaar is operating at a high velocity (ITR > 2x), but is currently "leaking" profit in two areas: **Regional Mismatch** and **Inventory Spoilage**. While Dhaka generates 46% of revenue and faces constant stockouts, regional hubs are overstocked with perishables that face a **12% write-off risk** within the next 90 days. Strategically, we have identified a high-loyalty "Parent" segment that treats our platform as a primary grocer, providing a clear path to increase Average Order Value (AOV) through staples bundling.

---

# 🔍 Insights Deep Dive

### 🧭 Regional Supply Chain Polarization

* **The Dhaka Dominance.** Dhaka Central and North warehouses drive **46% of total transaction volume**, yet consistently maintain the lowest Days of Sales Inventory (DSI), leading to lost revenue from stockouts.
* **Regional Overstocking.** Khulna and Rajshahi hubs account for **33% of inventory value** but only 18% of sales velocity, effectively acting as expensive storage units for slow-moving stock.
* **Inefficient Allocation.** Current replenishment logic is based on warehouse capacity rather than regional demand velocity, causing "dead capital" to sit in low-demand zones.
* **Inter-Warehouse Opportunity.** Analysis shows that 20% of the stock currently in Rajshahi (Rice, Detergents) is identical to the items frequently out-of-stock in Dhaka.

<img width="1264" height="442" alt="Image" src="https://github.com/user-attachments/assets/89d951ff-79d7-4a64-8dce-d07869d989ee" />

### ☣️ Inventory Health & Expiry Risk

* **The 12% Spoilage Risk.** Approximately **12% of perishable inventory** (Juices, Baby Food) in regional hubs is scheduled to expire within the next 90 days.
* **Category Specifics.** The "Beverage" category has the highest risk profile, with several batches in Sylhet already crossing the 60-day-to-expiry threshold.
* **Dead Stock Identification.** "Lentils" have shown a 40% decrease in velocity over the last two quarters, leading to high storage costs with no clear exit path.
* **Margin Impact.** Potential write-offs from these near-expiry items could reduce the division's Net Profit margin by an estimated 1.5% if not liquidated.

### 🍼 Market Basket Affinity (The "Parent Economy")

* **The Diaper-Rice Correlation.** There is a statistically significant correlation (>7,000 co-occurrences) between **Baby Diapers and Bulk Rice**.
* **High-Value Loyalty.** Customers who purchase Baby Care products have a **30% higher 12-month retention rate** compared to the average shopper.
* **Winter Seasonality.** Baby Care and Skin Care categories saw a **25% QoQ growth** in Q4, signaling a seasonal shift in consumer stock-up behavior.
* **AOV Gap.** Despite buying staples, these "Parent" shoppers rarely use discounts on non-baby items, suggesting they prioritize convenience over price.

<img width="1264" height="333" alt="Image" src="https://github.com/user-attachments/assets/8ecc2de6-548a-4e1f-8cff-8ae6af145ae3" />

### 🛑 Operational Quality & Returns

* **The "Liquid" Leakage.** "Damaged Packaging" is the primary reason for returns in the Personal Care and Home Care categories (Shampoo, Detergent).
* **NPS Correlation.** Products with damage-related returns show a **40% lower sentiment score** in reviews, leading to a permanent drop in organic conversion rates.
* **Logistics Drain.** Every return costs the company 2.5x the original shipping fee due to reverse logistics and manual quality inspection.
* **Protocol Failure.** Review text analysis indicates that the "Seal Broken" tag is most prevalent in shipments originating from the Savar Fulfillment Center.

<img width="859" height="399" alt="Image" src="https://github.com/user-attachments/assets/f6fdf29d-1d3a-479d-9057-8536e81be8bd" />

---

# 🚀 Recommendations:

Based on the insights above, the following strategic actions are recommended for the Operations and Marketing teams:

* **Regional Rebalancing:** Immediately initiate **Inter-Warehouse Transfers (STO)** to move non-perishable staples (Rice, Oil) from Rajshahi to Dhaka hubs. **This meets high demand in the capital without increasing procurement costs.**
* **Liquidation Strategy:** Launch a geo-targeted **"Freshness First" Flash Sale** in regional districts for all batches with <90 days expiry. **Recapture cash at break-even prices rather than incurring 100% write-off losses.**
* **The "Parent Monthly Box":** Create a subscription-style bundle containing Diapers, Baby Food, and Rice. **Lock in high-value customers and increase AOV by 15%.**
* **Incentivized Clearance:** Include slow-moving "Lentils" as a **Free Gift** for orders above 3,000 BDT in the Baby Care category. **This clears warehouse space for high-velocity Q1 stock.**
* **Packaging Overhaul:** Implement a mandatory **"Bubble Wrap + Tape Seal" protocol** for all Liquid SKUs at the Savar Fulfillment Center. **Target a 50% reduction in liquid-related returns within 6 months.**

---

## ⚠️ Assumptions and Caveats:

* **Data Incompleteness:** Missing "District" data for 2% of legacy customers was imputed based on the warehouse ID from which their most recent order was fulfilled.
* **Sales Velociy Volatility:** The "Expiry Risk" calculation assumes no significant change in the current daily sales velocity for the next 90 days.
* **Return Sentiment Logic:** Returns labeled as "Quality Issue" without further comment were categorized under "General Dissatisfaction" unless paired with a low sentiment score indicating damage.

---

## 📂 Repository Structure

```
Advanced_End-to-End_Retial_Analytics/
│
├── Dashboard/                            # Final visualization and reporting outputs
│   ├── assets/                           # Visual elements used in reports (logos, icons, etc.)
│   │   ├── Icons/                        # Collection of icons used in KPI Cards/Buttons
│   │   └── Theme.json                    # Custom Power BI color palette for dashboard
│   ├── live_dashboard.md                 # Links to hosted Power BI Service report
│   └── static_overview.pdf               # Exported PDF version of the final dashboard for quick viewing
│
├── Data Cleaning/                        # Power Query M Codes for cleaning tables of the dataset.
│
├── Dataset/                              # The data foundation of the project
│   ├── entity_relationship_diagram.svg   # Visual map of table connections and cardinality
│   ├── Marketing/                     # Customer acquisition, retention and product test, reviews
│   ├── Master Data/                   # Core business entities and dimensional attributes
│   ├── Sales and Commercial/          # Revenue-generating transaction, pricing and return records
│   └── Supply Chain/                  # Operational logistics and inventory flow data
│
├── DAX Calculations/                     # Business logic and analytical formulas
│   ├── calculated_column.md              # Definitions for static row-level logic (e.g., hour buckets)
│   └── measures.md                       # Dynamic aggregation formulas (e.g., Total Revenue, MoM Growth)
│
├── .gitattributes                        # Repository configuration for handling large binary/data files
├── LICENSE                               # Legal terms for code and data usage
└── README.md                             # Project background, summary and key insights
``` 

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute it with proper attribution.

---

## 🌟 About Me

Hi! I’m **Mehedi Hasan**, well known as **Mehedi Bhai**, a Certified Data Analyst with strong proficiency in *Excel*, *Power BI*, and *SQL*. I specialize in data visualization, transforming raw data into clear, meaningful insights that help businesses make impactful data-driven decisions.

Let’s connect:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge\&logo=linkedin\&logoColor=white)](https://www.linkedin.com/in/mehedi-hasan-b3370130a/)
[![YouTube](https://img.shields.io/badge/YouTube-red?style=for-the-badge\&logo=youtube\&logoColor=white)](https://youtube.com/@mehedibro101?si=huk7eZ05dOwHTs1-)
