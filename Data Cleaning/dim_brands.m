let
    // Extracted the FMCG brand and manufacturer data from the BanglaBazaar local directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the brand dimension file.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Master Data\",Name="dim_brands.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 3-column schema.
    Imported_Brand_Data = Csv.Document(File_Content,[Delimiter=",", Columns=3, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify brands and their respective manufacturers.
    Promote_Headers = Table.PromoteHeaders(Imported_Brand_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to ensure reliable relationship mapping.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"brand_id", Int64.Type}, 
        {"brand_name", type text}, 
        {"manufacturer_name", type text}
    }),

    // Renamed technical headers to professional labels for supply chain and market share analysis.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"brand_id", "Brand ID"}, 
        {"brand_name", "Brand"}, 
        {"manufacturer_name", "Manufacturer"}
    })
in
    Renamed_Columns
