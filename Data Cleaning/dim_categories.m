let
    // Extracted the FMCG category hierarchy from the BanglaBazaar local directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the category dimension file.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Master Data\",Name="dim_categories.csv"]}[Content],

    // Imported the CSV document with a 5-column schema.
    Imported_Category_Data = Csv.Document(File_Content,[Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify the multi-level product classification.
    Promote_Headers = Table.PromoteHeaders(Imported_Category_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support category-based filtering and manager reporting.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"category_id", Int64.Type}, 
        {"level_1_category", type text}, 
        {"level_2_subcategory", type text}, 
        {"level_3_segment", type text}, 
        {"category_manager_name", type text}
    }),

    // Renamed levels to business-friendly headers and removed the subcategory column per requirement.
    // This creates a streamlined Category -> Segment hierarchy.
    Refine_Hierarchy = let
        Rename_Levels = Table.RenameColumns(Set_Data_Types,{
            {"level_1_category", "Category"}, 
            {"level_3_segment", "Segment"},
            {"category_manager_name", "Category Manager"}
        }),
        Remove_Subcategory = Table.RemoveColumns(Rename_Levels,{"level_2_subcategory"})
    in
        Remove_Subcategory,

    // Finalized table for relationship mapping to the Product Dimension.
    Renamed_Final_Columns = Table.RenameColumns(Refine_Hierarchy,{
        {"category_id", "Category ID"}
    })
in
    Renamed_Final_Columns
