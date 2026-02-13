# 🏗️ Calculated Tables & Columns: Product Market & Inventory Analysis

This documentation details the structural enhancements to the data model, including DAX calculated tables, Power Query (M) transformations, and calculated columns for advanced segmentation and market basket analysis.

---

## 📊 Calculated Tables

These tables are generated within the data model to support specific analysis frameworks like ABC/XYZ inventory segmentation and marketing funnel visualization.

**Inventory Analysis Table**: Base table for product performance metrics used in segmentation.

  * **Formula**:
  
  ```dax
  VAR ProductStats = 
      SUMMARIZE(
          'fact_sales_lines',
          'fact_sales_lines'[product_sk_id],
          "Total_Revenue", [Net Revenue],
          "Avg_Monthly_Demand", DIVIDE([Total Qty Sold], DISTINCTCOUNT(dim_date[Year-Month]))
      )
  RETURN
      ProductStats
  ```

**Marketing Funnel**: A specialized table for funnel-stage visualization.

  * **Formula**:
  
  ```dax
  {
      ("Impressions", [Impression Volume], 1),
      ("Page Views", [Page View Volume], 2),
      ("Add-to-Carts", [Add-to-Cart Volume], 3),
      ("Purchases", [Total Carts Proceeded], 4)
  }
  ```

**dim_segments**: Static metadata table for mapping ABC/XYZ segment codes to descriptive names.

  * **Formula**:

  ```dax
  DATATABLE (
      "Segment_Code", STRING,
      "Segment_Name", STRING,
      {
          {"AX", "High Value - Stable Demand"},
          {"AY", "High Value - Variable Demand"},
          {"AZ", "High Value - Irregular Demand"},
          
          {"BX", "Medium Value - Stable Demand"},
          {"BY", "Medium Value - Variable Demand"},
          {"BZ", "Medium Value - Irregular Demand"},
          
          {"CX", "Low Value - Stable Demand"},
          {"CY", "Low Value - Variable Demand"},
          {"CZ", "Dead Stock Risk"}
      }
  )
  ```

---

## 🧺 Market Basket Analysis Table (Power Query)

This table is created via M-code to identify product affinities by calculating how often items are purchased together in the same order.

  * **M-Code**:

  ```powerquery
  let
      Source = fact_sales_lines,
      #"Removed Other Columns" = Table.SelectColumns(Source,{"order_id", "product_sk_id"}),
      #"Merged Queries" = Table.NestedJoin(#"Removed Other Columns", {"order_id"}, #"Removed Other Columns", {"order_id"}, "Removed Other Columns", JoinKind.LeftOuter),
      #"Expanded Removed Other Columns" = Table.ExpandTableColumn(#"Merged Queries", "Removed Other Columns", {"product_sk_id"}, {"product_sk_id.1"}),
      #"Renamed Columns" = Table.RenameColumns(#"Expanded Removed Other Columns",{{"product_sk_id", "Product A"}, {"product_sk_id.1", "Product B"}}),
      #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Custom", each if [Product A] < [Product B] then 1 else 0),
      #"Filtered Rows" = Table.SelectRows(#"Added Custom", each ([Custom] = 1)),
      #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Custom"}),
      #"Inserted Merged Column" = Table.AddColumn(#"Removed Columns", "Product Pair", each Text.Combine({Text.From([Product B], "en-US"), Text.From([Product A], "en-US")}, " & "), type text),
      #"Grouped Rows" = Table.Group(#"Inserted Merged Column", {"Product A", "Product B", "Product Pair"}, {{"Frequency", each Table.RowCount(_), Int64.Type}})
  in
      #"Grouped Rows"
  ```

---

## 📑 Calculated Columns

| Table Name | Column Name | DAX Formula |
| --- | --- | --- |
| **dim_date** | **Year-Month** | `dim_date[Year] & " - " & dim_date[Month]` |
| **dim_products** | **Product Cumulative %** | See Multi-line Snippet Below |
| **dim_products** | **vaalue** | `[Cumulative Revenue %]` |
| **dim_products** | **Segment** | `LOOKUPVALUE('Inventory Analysis Table'[Segment], 'Inventory Analysis Table'[product_sk_id], dim_products[product_sk_id])` |
| **fact_sales_lines** | **Sales Amount** | `fact_sales_lines[unit_mrp_bdt] * fact_sales_lines[quantity_sold]` |
| **fact_sales_lines** | **COGS** | `fact_sales_lines[unit_cost_bdt] * fact_sales_lines[quantity_sold]` |
| **fact_sales_lines** | **Tax Amount** | `fact_sales_lines[Sales Amount] * 0.15` |
| **fact_sales_lines** | **discount_pct** | `RELATED(dim_discounts[pct])` |
| **fact_sales_lines** | **discount_amount** | `fact_sales_lines[discount_pct] * (fact_sales_lines[Sales Amount] + fact_sales_lines[Tax Amount])` |
| **fact_inventory_batches** | **On Hand Value** | `fact_inventory_batches[quantity_on_hand] * fact_inventory_batches[unit_cost_bdt]` |
| **fact_inventory_batches** | **Reserved Value** | `fact_inventory_batches[quantity_reserved] * fact_inventory_batches[unit_cost_bdt]` |
| **fact_stock_movements** | **unit_cost** | See Multi-line Snippet Below |
| **fact_stock_movements** | **total_cost** | `fact_stock_movements[unit_cost] * fact_stock_movements[quantity]` |
| **Inventory Analysis Table** | **ABC Class** | See Multi-line Snippet Below |
| **Inventory Analysis Table** | **XYZ Class** | See Multi-line Snippet Below |
| **Inventory Analysis Table** | **Segment** | `'Inventory Analysis Table'[ABC Class] & 'Inventory Analysis Table'[XYZ Class]` |
| **Inventory Analysis Table** | **Segment Name** | `RELATED(dim_segments[Segment_Name])` |
| **Market Basket Analysis** | **Product A name** | `LOOKUPVALUE(dim_products[product_name], dim_products[product_sk_id], 'Market Basket Analysis'[Product A])` |
| **Market Basket Analysis** | **Product B name** | `LOOKUPVALUE(dim_products[product_name], dim_products[product_sk_id], 'Market Basket Analysis'[Product B])` |

---

## 🧠 Complex Column Logic Explained

**Product Cumulative % (dim_products)**:
Ranks products by revenue to facilitate Pareto (80/20) analysis.

  ```dax
  VAR TotalProducts = COUNTROWS(ALL(dim_products)) 
  VAR CurrentRank = 
      RANKX(
          ALL(dim_products),
          [Net Revenue],
          ,
          DESC,
          Dense 
      ) 
  RETURN 
      DIVIDE(CurrentRank, TotalProducts)
  ```

**ABC Class (Inventory Analysis Table)**:
Segments products into A (High Value), B (Medium Value), and C (Low Value) based on cumulative revenue contribution.

  ```dax
  VAR CurrentProductValue = 'Inventory Analysis Table'[Total_Revenue] 
  VAR TotalInventoryValue = SUM('Inventory Analysis Table'[Total_Revenue]) 
  VAR CumulativeValue = 
      CALCULATE(
          SUM('Inventory Analysis Table'[Total_Revenue]), 
          FILTER(
              'Inventory Analysis Table', 
              'Inventory Analysis Table'[Total_Revenue] >= CurrentProductValue 
          ) 
      ) 
  VAR RunningPercent = DIVIDE(CumulativeValue, TotalInventoryValue) 
  RETURN 
      SWITCH(TRUE(), 
          RunningPercent <= 0.70, "A", 
          RunningPercent <= 0.90, "B", 
          "C"
      )
  ```

**XYZ Class (Inventory Analysis Table)**:
Calculates the Coefficient of Variation (CV) to categorize demand stability. X is stable, Y is variable, and Z is erratic or new.

  ```dax
  VAR CurrentProduct = 'Inventory Analysis Table'[product_sk_id] 
  VAR UniqueMonths = 
      DISTINCT(
          SELECTCOLUMNS(
              FILTER('fact_sales_lines', 'fact_sales_lines'[product_sk_id] = CurrentProduct), 
              "Month", EOMONTH('fact_sales_lines'[order_date], 0) 
          ) 
      ) 
  VAR MonthlySales = 
      ADDCOLUMNS(
          UniqueMonths, 
          "MonthlyQty", 
          VAR CurrentMonth = [Month] 
          RETURN 
              CALCULATE(
                  [Total Qty Sold], 
                  'fact_sales_lines'[product_sk_id] = CurrentProduct, 
                  EOMONTH('fact_sales_lines'[order_date], 0) = CurrentMonth 
              ) 
      ) 
  VAR AvgDemand = AVERAGEX(MonthlySales, [MonthlyQty]) 
  VAR StdDevDemand = STDEVX.P(MonthlySales, [MonthlyQty]) 
  VAR CV = DIVIDE(StdDevDemand, AvgDemand, 0) 
  VAR MonthCount = COUNTROWS(UniqueMonths) 
  RETURN 
      IF(MonthCount < 2, "Z", 
          IF(CV <= 0.5, "X", 
              IF(CV <= 1.0, "Y", "Z")
          )
      )
  ```

**unit_cost (fact_stock_movements)**:
Retrieves the relevant unit cost from sales records to value inventory movements.
  
  ```dax
  CALCULATE(
      AVERAGE(fact_sales_lines[unit_cost_bdt]), 
      FILTER(
          fact_sales_lines, 
          fact_sales_lines[product_sk_id] = fact_stock_movements[product_sk_id] 
      ) 
  )
  ```

---

**🧠 Explanation of Complex Logics**

**Inventory Reconstruction (ABC/XYZ)**: These measures are computationally intensive because they require iterating through the entire product catalog and historical sales months to establish relative rankings and volatility. By combining ABC (Revenue value) and XYZ (Demand stability), we create a 9-cell matrix that allows for surgical inventory management—e.g., automated high-safety stock for "AX" items and "Order-to-Order" workflows for "CZ" items.

**Market Basket Affinity**: The Market Basket table uses a "Self-Join" logic in Power Query. By joining the sales lines to themselves on the `order_id`, we create every possible combination of products within a single cart. The filter `[Product A] < [Product B]` is a critical optimization; it ensures that we only count the pair (Apple & Banana) once, rather than also counting the duplicate pair (Banana & Apple).

**Context-Aware Volatility**: The `XYZ Class` calculation includes a "New Item" protection clause. If an item has less than 2 months of sales history, it is automatically assigned to class "Z." This prevents the model from labeling a new, high-growth item as "Stable" (X) based on insufficient data points, ensuring the risk assessment remains conservative.

**Pareto-Based Ranking**: The `Product Cumulative %` measure uses a `DENSE` rank. This ensures that even if multiple products have identical revenue, they don't skip numbers in the ranking sequence, providing a smoother cumulative curve for identifying the top 20% of products that typically drive 80% of company revenue.
