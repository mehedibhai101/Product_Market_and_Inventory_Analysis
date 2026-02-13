# 📊 Measures: Product Market & Supply Chain Analytics

This documentation provides a comprehensive overview of the DAX measures used to analyze sales performance, supply chain efficiency, and market behavior.

---

### 💰 Sales & Financial Performance

* **Gross Revenue**: Total sales generated before any deductions.
    * **Formula**: `SUM(fact_sales_lines[Sales Amount]) - [Discount Amount]`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`
* **Net Sales**: Revenue after tax is added (Gross + Tax).
    * **Formula**: `[Gross Revenue] + [Tax Amount]`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`
* **Net Revenue**: The actual realized revenue after deducting returns.
    * **Formula**: `[Gross Revenue] - [Return Amount]`
    * **Formatting**: `#,0"৳";-#,0"৳";#,0"৳"`
* **Gross Margin**: The profit remaining after subtracting the Cost of Goods Sold (COGS).
    * **Formula**: `[Net Revenue] - [Net COGS]`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`
* **Gross Margin%**: Profitability ratio indicating the percentage of revenue that exceeds COGS.
    * **Formula**: `DIVIDE([Gross Margin], [Net Revenue])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **AOV (Average Order Value)**: The average amount spent each time a customer places an order.
    * **Formula**: `DIVIDE([Net Sales], [Total Orders])`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`
* **Avg Basket Size**: The average quantity of items purchased per order.
    * **Formula**: `DIVIDE([Total Qty Sold], [Total Orders])`
    * **Formatting**: `General Number`
* **Discount Depth**: The ratio of discount given relative to total sales.
    * **Formula**: `DIVIDE([Discount Amount], [Net Sales])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Return Rate**: The percentage of orders that result in a return.
    * **Formula**: `DIVIDE([Total Returns], [Total Orders])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Return Amount**: Total monetary value of returned goods.
    * **Formula**: `CALCULATE([Gross Revenue], fact_sales_lines[is_returned]=1)`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

---

### 🎯 Marketing & Conversion Funnel

* **Impression Volume**: Total number of times products were displayed to users.
    * **Formula**: `SUM(fact_product_traffic[impression_count])`
    * **Formatting**: `#,0`
* **CTR (Click-Through Rate)**: The percentage of impressions that resulted in a page view.
    * **Formula**: `DIVIDE([Page View Volume], [Impression Volume])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Look-to-Book Ratio**: The percentage of product page views that convert into a purchase.
    * **Formula**: `DIVIDE([Total Orders], [Page View Volume])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Cart Abandonment Rate**: The percentage of users who added items to the cart but did not complete the purchase.
    * **Formula**: `DIVIDE([Cart Abandonment Volume], [Add-to-Cart Volume])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Conversion Rate**: The overall percentage of visitors (page views) who completed a transaction.
    * **Formula**: `DIVIDE([Total Carts Proceeded], [Page View Volume])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Sales per Visit**: Revenue generated per individual page view.
    * **Formula**: `DIVIDE([Net Sales], [Page View Volume])`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

---

### 📦 Supply Chain & Inventory Operations

* **Inventory Turnover Ratio**: Measures how many times inventory is sold and replaced over a period. It dynamically reconstructs average inventory based on movements.
    * **Formula**:
    ```dax
    Inventory Turnover Ratio = 
    VAR _cogs = 
        CALCULATE(
            [Net COGS], 
            DATESINPERIOD(dim_date[Date], MAX(fact_sales_lines[order_date]), -12, MONTH)
        )
    VAR _current = [Total Inventory Value]
    VAR _inbound = 
        CALCULATE(
            SUM(fact_stock_movements[total_cost]), 
            'fact_stock_movements'[movement_type] = "PO Receipt", 
            'fact_stock_movements'[movement_date] >= DATE(2023,12,31) - 30
        )
    VAR _outbound = 
        CALCULATE(
            SUM(fact_stock_movements[total_cost]), 
            'fact_stock_movements'[movement_type] = "Sales Shipment", 
            'fact_stock_movements'[movement_date] >= DATE(2023,12,31) - 30
        ) - 
        CALCULATE(
            SUM(fact_stock_movements[total_cost]), 
            'fact_stock_movements'[movement_type] = "Customer Return", 
            'fact_stock_movements'[movement_date] >= DATE(2023,12,31) - 30
        )
    VAR OpeningInventory = _current - _inbound + _outbound
    VAR AverageInventory = DIVIDE(OpeningInventory + _current, 2)
    RETURN 
        DIVIDE(_cogs, AverageInventory, 0)
    ```
    
    
    * **Formatting**: `General Number`
* **Stockout Frequency**: Counts the number of days in the last 30 days where stock would have been zero, based on reconstructing daily balances.
    * **Formula**:
    ```dax
    Stockout Frequency = 
    VAR AnchorDate = DATE(2023, 12, 31) -- Or use TODAY() for live data
    VAR Last30Days = DATESINPERIOD('dim_date'[Date], AnchorDate, -30, DAY)
    VAR CurrentSnapshot = [Stock On Hand]
    RETURN 
        COUNTROWS(
            FILTER(
                Last30Days,
                VAR LoopDate = 'dim_date'[Date]
                -- Calculate movements that happened AFTER this specific loop date to back-calculate
                VAR FutureInbound = 
                    CALCULATE(
                        SUM('fact_stock_movements'[quantity]), 
                        'fact_stock_movements'[movement_type] IN {"PO Receipt", "Customer Return"}, 
                        'fact_stock_movements'[movement_date] > LoopDate
                    )
                VAR FutureOutbound = 
                    CALCULATE(
                        SUM('fact_stock_movements'[quantity]), 
                        'fact_stock_movements'[movement_type] IN {"Sales Shipment", "Adjustment"}, 
                        'fact_stock_movements'[movement_date] > LoopDate
                    )
                -- Reconstruct the balance for that specific day
                VAR DailyStock = CurrentSnapshot - FutureInbound + FutureOutbound
                -- Return TRUE if stock was 0 or less
                RETURN DailyStock <= 0
            )
        )
    ```


    * **Formatting**: `#,0`
* **GMROI (Gross Margin Return on Investment)**: Measures the profit return on every dollar invested in inventory.
    * **Formula**: `DIVIDE([Gross Margin], [Total Inventory Cost])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Sales Velocity(Daily)**: Average net units sold per day over the last 30 days.
    * **Formula**:
    ```dax
    Sales Velocity(Daily) = 
    VAR GrossQty = CALCULATE([Total Qty Sold], DATESINPERIOD(dim_date[Date], MAX(dim_date[Date]), -30, DAY))
    VAR ReturnQty = CALCULATE([Return Qty], DATESINPERIOD(dim_date[Date], MAX(dim_date[Date]), -30, DAY))
    RETURN 
        DIVIDE(GrossQty - ReturnQty, 30)
    ```
    
    
    * **Formatting**: `General Number`
* **Weeks of Supply**: How long current stock will last based on current sales velocity.
    * **Formula**: `DIVIDE([Available Stock], [Sales Velocity(Daily)]*7, 999)`
    * **Formatting**: `General Number`
* **OOS Value (Out of Stock Value)**: Estimated revenue lost due to stockouts.
    * **Formula**: `[Stockout Frequency] * [Sales Velocity(Daily)] * AVERAGE(fact_sales_lines[unit_mrp_bdt])`
    * **Formatting**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`
* **Replenishment Qty**: Calculates required reorder quantity based on lead time and safety stock.
    * **Formula**:
    ```dax
    Replenishment Qty = 
    VAR LeadTimeDays = 14       -- Assumption: 14 days lead time
    VAR SafetyBufferDays = 7    -- Assumption: 7 days safety stock
    VAR AvgDailyUsage = [Sales Velocity(Daily)] 
    -- DEFINE TARGETS
    VAR LeadTimeDemand = AvgDailyUsage * LeadTimeDays
    VAR SafetyStock = AvgDailyUsage * SafetyBufferDays
    VAR TargetStockLevel = LeadTimeDemand + SafetyStock
    -- CURRENT POSITION
    VAR CurrentInventory = [Stock on Hand]
    VAR OnOrderInventory = 0    -- Set to 0 if Open PO data is unavailable
    -- CALCULATE GAP
    VAR ReplenishmentNeeded = TargetStockLevel - (CurrentInventory + OnOrderInventory)
    RETURN 
        IF(ReplenishmentNeeded > 0, ReplenishmentNeeded, 0)
    ```
    
    
    * **Formatting**: `General Number`
* **Value At Risk**: Inventory value of items expiring within the next 30 days.
    * **Formula**: `CALCULATE([Stock On Hand], fact_inventory_batches[expiry_date]<=DATE(2023, 12,31)+30)`
    * **Formatting**: `General Number`
* **Freshness Score%**: Ratio of remaining shelf life to total shelf life.
    * **Formula**:
    ```dax
    Freshness Score% = 
    DIVIDE(
        [Days to Expiry], 
        AVERAGEX(fact_inventory_batches, DATEDIFF(fact_inventory_batches[mfg_date], fact_inventory_batches[expiry_date], DAY)), 
        0
    )
    ```
    
    
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Shrinkage%**: Percentage of inventory lost due to theft, damage, or errors (Adjustments).
    * **Formula**: `DIVIDE([Shrinkage Qty], [Total Inbound Qty])`
    * **Formatting**: `0.00%;-0.00%;0.00%`

---

### 📈 Pricing & A/B Testing

* **Avg Price Hike%**: Average percentage increase for products that raised prices.
    * **Formula**:
    ```dax
    Avg Price Hike% = 
    VAR PriceIncreases = 
        FILTER('dim_pricing_history', 'dim_pricing_history'[new_price_bdt] > 'dim_pricing_history'[old_price_bdt])
    RETURN 
        AVERAGEX(
            PriceIncreases,
            DIVIDE(('dim_pricing_history'[new_price_bdt] - 'dim_pricing_history'[old_price_bdt]), 'dim_pricing_history'[old_price_bdt], 0)
        )
    ```
    
    
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Inflation Revenue Impact**: Estimates revenue gained strictly from price increases due to global inflation.
    * **Formula**:
    ```dax
    Inflation Revenue Impact = 
    SUMX(
        FILTER('dim_pricing_history', 'dim_pricing_history'[change_reason] = "Global Inflation Adjustment"),
        VAR PriceDelta = 'dim_pricing_history'[new_price_bdt] - 'dim_pricing_history'[old_price_bdt]
        VAR EffectiveDate = 'dim_pricing_history'[valid_from]
        VAR ExpiryDate = 'dim_pricing_history'[valid_to]
        VAR CurrentProduct = 'dim_pricing_history'[product_sk_id]
        VAR QtySoldAfterHike = 
            CALCULATE(
                SUM('fact_sales_lines'[quantity_sold]),
                'fact_sales_lines'[product_sk_id] = CurrentProduct,
                'fact_sales_lines'[order_date] >= EffectiveDate,
                'fact_sales_lines'[order_date] <= ExpiryDate
            )
        RETURN 
            QtySoldAfterHike * PriceDelta 
    )
    ```
    
    
    * **Formatting**: `#,0"৳";-#,0"৳";#,0"৳"`
* **Lift %**: The percentage improvement in conversion rate of Variant B over the Control group.
    * **Formula**:
    ```dax
    Lift % = 
    VAR ControlCR = [CR % (Control)]
    VAR VariantCR = [CR % (Variant B)]
    RETURN 
        DIVIDE(VariantCR - ControlCR, ControlCR, 0)
    ```
    
    
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Is Significant**: A rule-of-thumb check to see if the A/B test result is statistically reliable for business decisions.
    

---

### 👥 Customer Retention & Reviews

* **Retention Rate**: The percentage of customers from the previous month who made a purchase in the current month.
    * **Formula**:
    ```dax
    Retention Rate = 
    -- 1. Find the Latest Month in data
    VAR _MaxTransactionDate = CALCULATE(MAX(fact_sales_lines[order_date]), ALL(fact_sales_lines))
    VAR _LatestMonthStart = EOMONTH(_MaxTransactionDate, -1) + 1
    VAR _LatestMonthEnd = EOMONTH(_MaxTransactionDate, 0)
    VAR _IsFiltered = ISFILTERED('dim_date')
    VAR _HasOneMonth = HASONEVALUE('dim_date'[Year-Month]) 
    RETURN 
        IF(
            _HasOneMonth,
            -- SCENARIO A: User selected exactly one month.
            VAR _PM = CALCULATE(DISTINCTCOUNT(fact_sales_lines[customer_id]), PREVIOUSMONTH('dim_date'[Date]))
            VAR _retained = 
                VAR CustomersLastMonth = CALCULATETABLE(VALUES(fact_sales_lines[customer_id]), PREVIOUSMONTH('dim_date'[Date]))
                VAR CustomersThisMonth = VALUES(fact_sales_lines[customer_id])
                RETURN COUNTROWS(INTERSECT(CustomersLastMonth, CustomersThisMonth))
            RETURN DIVIDE(_retained, _PM, 0),
            IF(
                NOT _IsFiltered,
                -- SCENARIO B: No filter (Card Visual). Force context to Latest Month.
                CALCULATE(
                    VAR _PM_Default = CALCULATE(DISTINCTCOUNT(fact_sales_lines[customer_id]), PREVIOUSMONTH('dim_date'[Date]))
                    VAR _retained_Default = 
                        VAR CustomersLastMonth = CALCULATETABLE(VALUES(fact_sales_lines[customer_id]), PREVIOUSMONTH('dim_date'[Date]))
                        VAR CustomersThisMonth = VALUES(fact_sales_lines[customer_id])
                        RETURN COUNTROWS(INTERSECT(CustomersLastMonth, CustomersThisMonth))
                    RETURN DIVIDE(_retained_Default, _PM_Default, 0),
                    DATESBETWEEN('dim_date'[Date], _LatestMonthStart, _LatestMonthEnd)
                ),
                -- SCENARIO C: Multiple months selected. Return Blank.
                BLANK()
            )
        )
    ```
    
    
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Repeat Customer Rate**: Percentage of active customers who have placed more than one order.
    * **Formula**: `DIVIDE([Repeat Customers], [Active Customers])`
    * **Formatting**: `0.00%;-0.00%;0.00%`
* **Avg Sentiment Score**: Average score from customer feedback reviews.
    * **Formula**: `AVERAGE(fact_reviews_feedback[sentiment_score])`
    * **Formatting**: `General Number`

---

### ⏳ Time Intelligence & Formatting

* **Vs PM (Revenue)**: Month-over-Month percentage change in revenue.
    * **Formula**:
    ```dax
    Vs PM (Revenue) = 
    VAR _Pv = CALCULATE([Net Revenue], DATEADD(dim_date[Date], -1, MONTH)) 
    RETURN 
        DIVIDE([Net Revenue]-_Pv, _Pv)
    ```
    
    
    * **Formatting**: `0.00%`
* **KPI Color (Return Amount%)**: Conditional formatting logic to flag high return rates.
    * **Formula**: `IF([Return Amount%]<=0.05, "#252423", "#D64554")`
    * **Formatting**: `Text`
* **Cumulative Revenue %**: Pareto analysis measure for ranking products by contribution.
    * **Formula**:
    ```dax
    Cumulative Revenue % = 
    VAR NetRevenueAllProducts = CALCULATE([Net Revenue], ALLSELECTED(dim_products))
    VAR CurrentRevenue = [Net Revenue]
    VAR CumulativeRevenue = 
        CALCULATE(
            [Net Revenue],
            FILTER(
                ALLSELECTED(dim_products), 
                [Net Revenue] >= CurrentRevenue
            )
        )
    RETURN 
        DIVIDE(CumulativeRevenue, NetRevenueAllProducts)
    ```
    
    
    * **Formatting**: `0%;-0%;0%`

---

**🧠 Explanation of Complex Logics**

**Inventory Reconstruction**: The `Inventory Turnover Ratio` and `Stockout Frequency` measures are computationally intensive because standard inventory snapshots (Day/Month end) often miss mid-period fluctuations. These measures use `FILTER` and `CALCULATE` to "rewind" or "fast-forward" stock movements from a known anchor date, allowing us to estimate daily stock levels even if we only have a monthly snapshot.

**Context-Aware Retention**: The `Retention Rate` measure includes a complex `IF` structure to handle different user behaviors. If a user selects a specific month, it compares it to the previous one. If they open the dashboard without filters, it automatically defaults to the "Latest Month" data to ensure the KPI card isn't blank or showing an meaningless average.

**Inflation Impact**: The `Inflation Revenue Impact` measure is designed to isolate price vs. volume growth. By iterating through the pricing history table and identifying price changes tagged specifically as "Inflation Adjustment," we can quantify exactly how much of the topline revenue growth is "artificial" (price hikes) versus "organic" (selling more units).
