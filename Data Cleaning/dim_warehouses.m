let
    // Extracted warehouse infrastructure data from the BanglaBazaar local directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the warehouse dimension file.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Master Data\",Name="dim_warehouses.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 4-column schema.
    Imported_Warehouse_Data = Csv.Document(File_Content,[Delimiter=",", Columns=4, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify facility names and capacities.
    Promote_Headers = Table.PromoteHeaders(Imported_Warehouse_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support spatial analysis and capacity planning.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"warehouse_id", Int64.Type}, 
        {"warehouse_name", type text}, 
        {"location_area", type text}, 
        {"storage_capacity_units", Int64.Type}
    }),

    // Renamed technical headers to professional labels for supply chain stakeholders.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"warehouse_id", "Warehouse ID"}, 
        {"warehouse_name", "Warehouse Name"}, 
        {"location_area", "Location/Area"}, 
        {"storage_capacity_units", "Storage Capacity (Units)"}
    })
in
    Renamed_Columns
