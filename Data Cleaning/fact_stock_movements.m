let
    // Extracted the stock movement logs from the Supply Chain directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for stock transfers and adjustments.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Supply Chain\",Name="fact_stock_movements.csv"]}[Content],

    // Imported the CSV document with a 7-column schema.
    Imported_Movement_Data = Csv.Document(File_Content,[Delimiter=",", Columns=7, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify movement types (Inbound, Outbound, Transfer).
    Promote_Headers = Table.PromoteHeaders(Imported_Movement_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to facilitate stock reconciliation and turnover calculations.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"movement_id", Int64.Type}, 
        {"product_sk_id", Int64.Type}, 
        {"movement_type", type text}, 
        {"quantity", Int64.Type}, 
        {"reason_code", type text}, 
        {"movement_date", type date}, 
        {"warehouse_id", Int64.Type}
    }),

    // Removed the 'reason_code' column as per your current reporting requirements.
    Remove_Reason_Code = Table.RemoveColumns(Set_Data_Types,{"reason_code"}),

    // Organized columns to place spatial keys (Product/Warehouse) before the metrics.
    Reorder_Columns = Table.ReorderColumns(Remove_Reason_Code, {
        "movement_id", "product_sk_id", "warehouse_id", "movement_type", "quantity", "movement_date"
    }),

    // Renamed technical headers to professional labels for operational dashboards.
    Renamed_Final_Columns = Table.RenameColumns(Reorder_Columns,{
        {"movement_id", "Movement ID"}, 
        {"product_sk_id", "Product SK ID"}, 
        {"warehouse_id", "Warehouse ID"}, 
        {"movement_type", "Movement Type"}, 
        {"quantity", "Quantity Changed"}, 
        {"movement_date", "Movement Date"}
    })
in
    Renamed_Final_Columns
