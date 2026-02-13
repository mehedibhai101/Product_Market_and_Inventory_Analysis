let
    // Extracted the granular transaction records from the Sales and Commercial directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the sales line items.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Sales and Commercial\",Name="fact_sales_lines.csv"]}[Content],

    // Imported the CSV document with a 12-column schema and standard encoding.
    Imported_Sales_Data = Csv.Document(File_Content,[Delimiter=",", Columns=12, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify order details and financial metrics.
    Promote_Headers = Table.PromoteHeaders(Imported_Sales_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support revenue, margin, and return rate analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"order_id", type text}, {"order_date_time", type date}, {"customer_id", Int64.Type}, 
        {"product_sk_id", Int64.Type}, {"quantity_sold", Int64.Type}, {"unit_mrp_bdt", Int64.Type}, 
        {"unit_cost_bdt", type number}, {"discount_id", Int64.Type}, {"is_returned", type logical}, 
        {"warehouse_id", Int64.Type}
    }),

    // Added a unique primary key for each row to distinguish individual items within a single order.
    Add_Order_Line_ID = Table.AddIndexColumn(Set_Data_Types, "order_line_id", 1, 1, Int64.Type),

    // Reordered and renamed columns for clarity and consistency across the data model.
    Refine_Columns = let
        Reorder = Table.ReorderColumns(Add_Order_Line_ID,{"order_line_id", "order_id", "order_date_time", "customer_id", "product_sk_id", "warehouse_id", "quantity_sold", "unit_mrp_bdt", "unit_cost_bdt", "discount_id", "is_returned"}),
        Rename = Table.RenameColumns(Reorder,{
            {"order_line_id", "Order Line ID"}, {"order_id", "Order ID"}, {"order_date_time", "Order Date"}, 
            {"customer_id", "Customer ID"}, {"product_sk_id", "Product SK ID"}, {"warehouse_id", "Warehouse ID"}, 
            {"quantity_sold", "Quantity"}, {"unit_mrp_bdt", "Unit MRP (BDT)"}, {"unit_cost_bdt", "Unit Cost (BDT)"}, 
            {"discount_id", "Discount ID"}, {"is_returned", "Is Returned"}
        })
    in
        Rename,

    // Converted the boolean 'Is Returned' to an integer (0/1) to allow for easy summation and Return Rate % measures.
    Final_Formatting = Table.TransformColumnTypes(Refine_Hierarchy,{{"Is Returned", Int64.Type}})
in
    Final_Formatting
