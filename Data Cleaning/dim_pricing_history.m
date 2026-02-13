let
    // Extracted historical pricing records from the Sales and Commercial directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the pricing history dimension.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Sales and Commercial\",Name="dim_pricing_history.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 7-column schema.
    Imported_Pricing_Data = Csv.Document(File_Content,[Delimiter=",", Columns=7, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify price validity periods and values.
    Promote_Headers = Table.PromoteHeaders(Imported_Pricing_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support date-range lookups and price delta calculations.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"price_change_id", Int64.Type}, 
        {"product_sk_id", Int64.Type}, 
        {"valid_from", type date}, 
        {"valid_to", type date}, 
        {"old_price_bdt", Int64.Type}, 
        {"new_price_bdt", Int64.Type}, 
        {"change_reason", type text}
    }),

    // Renamed technical headers to professional labels for commercial and audit reporting.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"price_change_id", "Price Change ID"}, 
        {"product_sk_id", "Product SK ID"}, 
        {"valid_from", "Valid From"}, 
        {"valid_to", "Valid To"}, 
        {"old_price_bdt", "Previous Price (BDT)"}, 
        {"new_price_bdt", "Current Price (BDT)"}, 
        {"change_reason", "Change Reason"}
    })
in
    Renamed_Columns
