let
    // Extracted the digital engagement data from the Marketing directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the product traffic and clickstream summary.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Marketing\",Name="fact_product_traffic.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 7-column funnel schema.
    Imported_Traffic_Data = Csv.Document(File_Content,[Delimiter=",", Columns=7, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify impressions and conversion metrics.
    Promote_Headers = Table.PromoteHeaders(Imported_Traffic_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support funnel analysis and conversion calculations.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"date", type date}, 
        {"product_sk_id", Int64.Type}, 
        {"impression_count", Int64.Type}, 
        {"page_view_count", Int64.Type}, 
        {"add_to_cart_count", Int64.Type}, 
        {"cart_abandonment_count", Int64.Type}, 
        {"conversion_rate", type number}
    }),

    // Renamed headers to follow professional e-commerce and marketing terminology.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"date", "Date"}, 
        {"product_sk_id", "Product SK ID"}, 
        {"impression_count", "Impressions"}, 
        {"page_view_count", "Page Views"}, 
        {"add_to_cart_count", "Add to Cart"}, 
        {"cart_abandonment_count", "Cart Abandonments"}, 
        {"conversion_rate", "Conversion Rate"}
    })
in
    Renamed_Columns
