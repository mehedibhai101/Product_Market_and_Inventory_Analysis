let
    // Extracted the FMCG product master data from the BanglaBazaar local directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the binary content for the product dimension, ensuring UTF-8 encoding (65001) for multilingual support.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Master Data\",Name="dim_products.csv"]}[Content],

    // Imported the CSV document with an 18-column schema and QuoteStyle handling.
    Imported_Product_Data = Csv.Document(File_Content,[Delimiter=",", Columns=18, Encoding=65001, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers for field identification.
    Promote_Headers = Table.PromoteHeaders(Imported_Product_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support price modeling and perishable inventory tracking.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"product_sk_id", Int64.Type}, {"sku_code", type text}, {"product_name_en", type text}, 
        {"product_name_bn", type text}, {"brand_id", Int64.Type}, {"category_id", Int64.Type}, 
        {"barcode_ean", Int64.Type}, {"uom", type text}, {"pack_size_value", Int64.Type}, 
        {"pack_size_unit", type text}, {"mrp_bdt", Int64.Type}, {"vat_percentage", Int64.Type}, 
        {"shelf_life_days", Int64.Type}, {"storage_type", type text}, {"is_perishable", type logical}, 
        {"is_private_label", type logical}, {"launch_date", type date}, {"product_status", type text}
    }),

    // Removed technical or localized columns not required for core FMCG reporting.
    Remove_Unnecessary_Columns = Table.RemoveColumns(Set_Data_Types, {
        "product_name_bn", "sku_code", "barcode_ean", "pack_size_unit", "storage_type", "product_status"
    }),

    // Renamed technical headers to professional, business-friendly labels.
    Renamed_Final_Columns = Table.RenameColumns(Remove_Unnecessary_Columns, {
        {"product_sk_id", "Product SK ID"}, 
        {"product_name_en", "Product Name"}, 
        {"brand_id", "Brand ID"}, 
        {"category_id", "Category ID"}, 
        {"uom", "UOM"}, 
        {"pack_size_value", "Pack Size"}, 
        {"mrp_bdt", "MRP (BDT)"}, 
        {"vat_percentage", "VAT %"}, 
        {"shelf_life_days", "Shelf Life (Days)"}, 
        {"is_perishable", "Perishable"}, 
        {"is_private_label", "Private Label"}, 
        {"launch_date", "Launch Date"}
    })
in
    Renamed_Final_Columns
