let
    // Extracted the customer master data from the BanglaBazaar local directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the customer dimension file.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Master Data\",Name="dim_customers.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 5-column schema.
    Imported_Customer_Data = Csv.Document(File_Content,[Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify unique customers and their demographics.
    Promote_Headers = Table.PromoteHeaders(Imported_Customer_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to facilitate segmentation and cohort analysis by join date.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"customer_id", Int64.Type}, 
        {"first_name", type text}, 
        {"customer_segment", type text}, 
        {"district_location", type text}, 
        {"join_date", type date}
    }),

    // Renamed technical headers to professional labels for marketing and sales reporting.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"customer_id", "Customer ID"}, 
        {"first_name", "Customer Name"}, 
        {"customer_segment", "Segment"}, 
        {"district_location", "District"}, 
        {"join_date", "Join Date"}
    })
in
    Renamed_Columns
