# Project Background: BanglaBazaar FMCG Operations

BanglaBazaar.com is one of Bangladesh's largest e-commerce platforms. Since its inception in 2018, the company has transitioned from a generalist marketplace to a logistics-heavy retail powerhouse. This project focuses specifically on the **FMCG & Grocery division**, which is the company's highest-frequency business unit.

As a Data Analyst within the Operations & Supply Chain team, my objective was to evaluate the efficiency of our **3.67 Billion BDT** annual revenue stream. While the business is growing, we faced challenges with regional stock distribution and inventory spoilage. This analysis serves as a strategic review to move the company from "reactive" stock management to "predictive" supply chain flow.

Insights and recommendations are provided on the following key areas:

* **Category 1: Regional Supply Chain Polarization** (Dhaka vs. Regional Hubs)
* **Category 2: Inventory Health & Expiry Risk** (Protecting Margins from Spoilage)
* **Category 3: Market Basket Affinity** (Unlocking Revenue through Bundling)
* **Category 4: Operational Quality & Return Mitigation** (Reducing Reverse Logistics Costs)

**DAX queries regarding various analytical calculations can be found here [[Link to Script]](https://www.google.com/search?q=%23).**

**An interactive Power BI dashboard used to report and explore sales trends can be found here [[Link to Dashboard]](https://www.google.com/search?q=%23).**

---

# Data Structure & Initial Checks

The company's primary analytics database for the FMCG division is structured as a Star Schema, containing over **2.2 Million records**. The core data resides in four primary tables:

* **`fact_sales_lines`:** Contains 2.2M+ transaction rows, tracking MRP, unit costs, and discounts for every item sold.
* **`fact_inventory_batches`:** Tracks 7,500+ unique batches with granular Manufacturing (MFG) and Expiry date data.
* **`fact_stock_movements`:** Logs all warehouse activity, including PO receipts, returns, and stock adjustments.
* **`fact_reviews_feedback`:** Aggregates customer ratings and sentiment scores, linked to specific return reason codes.

### Entity Relationship Diagram (ERD)

---

# Executive Summary

### Overview of Findings

BanglaBazaar is operating at a high velocity (ITR > 2x), but is currently "leaking" profit in two areas: **Regional Mismatch** and **Inventory Spoilage**. While Dhaka generates 46% of revenue and faces constant stockouts, regional hubs are overstocked with perishables that face a **12% write-off risk** within the next 90 days. Strategically, we have identified a high-loyalty "Parent" segment that treats our platform as a primary grocer, providing a clear path to increase Average Order Value (AOV) through staples bundling.

[**Visualization: Executive KPI Overview - Revenue vs. Inventory Turnover**]

---

# Insights Deep Dive

### Category 1: Regional Supply Chain Polarization

* **The Dhaka Dominance.** Dhaka Central and North warehouses drive **46% of total transaction volume**, yet consistently maintain the lowest Days of Sales Inventory (DSI), leading to lost revenue from stockouts.
* **Regional Overstocking.** Khulna and Rajshahi hubs account for **33% of inventory value** but only 18% of sales velocity, effectively acting as expensive storage units for slow-moving stock.
* **Inefficient Allocation.** Current replenishment logic is based on warehouse capacity rather than regional demand velocity, causing "dead capital" to sit in low-demand zones.
* **Inter-Warehouse Opportunity.** Analysis shows that 20% of the stock currently in Rajshahi (Rice, Detergents) is identical to the items frequently out-of-stock in Dhaka.

[**Visualization: Heatmap of Sales Velocity vs. Stock Levels by District**]

### Category 2: Inventory Health & Expiry Risk

* **The 12% Spoilage Risk.** Approximately **12% of perishable inventory** (Juices, Baby Food) in regional hubs is scheduled to expire within the next 90 days.
* **Category Specifics.** The "Beverage" category has the highest risk profile, with several batches in Sylhet already crossing the 60-day-to-expiry threshold.
* **Dead Stock Identification.** "Lentils" have shown a 40% decrease in velocity over the last two quarters, leading to high storage costs with no clear exit path.
* **Margin Impact.** Potential write-offs from these near-expiry items could reduce the division's Net Profit margin by an estimated 1.5% if not liquidated.

[**Visualization: Expiry Risk Countdown & Potential Loss Gauge**]

### Category 3: Market Basket Affinity (The "Parent Economy")

* **The Diaper-Rice Correlation.** There is a statistically significant correlation (>7,000 co-occurrences) between **Baby Diapers and Bulk Rice**.
* **High-Value Loyalty.** Customers who purchase Baby Care products have a **30% higher 12-month retention rate** compared to the average shopper.
* **Winter Seasonality.** Baby Care and Skin Care categories saw a **25% QoQ growth** in Q4, signaling a seasonal shift in consumer stock-up behavior.
* **AOV Gap.** Despite buying staples, these "Parent" shoppers rarely use discounts on non-baby items, suggesting they prioritize convenience over price.

[**Visualization: Market Basket Analysis - Association Rule Network**]

### Category 4: Operational Quality & Returns

* **The "Liquid" Leakage.** "Damaged Packaging" is the primary reason for returns in the Personal Care and Home Care categories (Shampoo, Detergent).
* **NPS Correlation.** Products with damage-related returns show a **40% lower sentiment score** in reviews, leading to a permanent drop in organic conversion rates.
* **Logistics Drain.** Every return costs the company 2.5x the original shipping fee due to reverse logistics and manual quality inspection.
* **Protocol Failure.** Review text analysis indicates that the "Seal Broken" tag is most prevalent in shipments originating from the Savar Fulfillment Center.

[**Visualization: Return Reason Breakdown & Sentiment Analysis**]

---

# Recommendations:

Based on the insights above, the following strategic actions are recommended for the Operations and Marketing teams:

* **Regional Rebalancing:** Immediately initiate **Inter-Warehouse Transfers (STO)** to move non-perishable staples (Rice, Oil) from Rajshahi to Dhaka hubs. **This meets high demand in the capital without increasing procurement costs.**
* **Liquidation Strategy:** Launch a geo-targeted **"Freshness First" Flash Sale** in regional districts for all batches with <90 days expiry. **Recapture cash at break-even prices rather than incurring 100% write-off losses.**
* **The "Parent Monthly Box":** Create a subscription-style bundle containing Diapers, Baby Food, and Rice. **Lock in high-value customers and increase AOV by 15%.**
* **Incentivized Clearance:** Include slow-moving "Lentils" as a **Free Gift** for orders above 3,000 BDT in the Baby Care category. **This clears warehouse space for high-velocity Q1 stock.**
* **Packaging Overhaul:** Implement a mandatory **"Bubble Wrap + Tape Seal" protocol** for all Liquid SKUs at the Savar Fulfillment Center. **Target a 50% reduction in liquid-related returns within 6 months.**

---

# Assumptions and Caveats:

* **Assumption 1:** Missing "District" data for 2% of legacy customers was imputed based on the warehouse ID from which their most recent order was fulfilled.
* **Assumption 2:** The "Expiry Risk" calculation assumes no significant change in the current daily sales velocity for the next 90 days.
* **Assumption 3:** Returns labeled as "Quality Issue" without further comment were categorized under "General Dissatisfaction" unless paired with a low sentiment score indicating damage.
