let
    // Extracted granular batch-level inventory records from the Supply Chain directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for inventory batches and stock on hand.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Supply Chain\",Name="fact_inventory_batches.csv"]}[Content],

    // Imported the CSV document with a 9-column schema, covering dates and stock counts.
    Imported_Inventory_Data = Csv.Document(File_Content,[Delimiter=",", Columns=9, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify Batch IDs and milestone dates.
    Promote_Headers = Table.PromoteHeaders(Imported_Inventory_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support expiry tracking and inventory valuation (Quantity * Cost).
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"batch_id", type text}, {"product_sk_id", Int64.Type}, {"warehouse_id", Int64.Type}, 
        {"grn_date", type date}, {"mfg_date", type date}, {"expiry_date", type date}, 
        {"quantity_on_hand", Int64.Type}, {"quantity_reserved", Int64.Type}, {"unit_cost_bdt", type number}
    }),

    // Renamed headers to follow professional business terminology for logistics and finance.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"batch_id", "Batch ID"}, 
        {"product_sk_id", "Product SK ID"}, 
        {"warehouse_id", "Warehouse ID"}, 
        {"grn_date", "Received Date (GRN)"}, 
        {"mfg_date", "Manufacturing Date"}, 
        {"expiry_date", "Expiry Date"}, 
        {"quantity_on_hand", "Stock On Hand"}, 
        {"quantity_reserved", "Stock Reserved"}, 
        {"unit_cost_bdt", "Unit Cost (BDT)"}
    })
in
    Renamed_Columns
