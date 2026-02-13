let
    // Extracted customer feedback and sentiment data from the Marketing directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the product reviews and return reasons.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\Marketing\",Name="fact_reviews_feedback.csv"]}[Content],

    // Imported the CSV document with an 8-column schema.
    Imported_Review_Data = Csv.Document(File_Content,[Delimiter=",", Columns=8, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify ratings and sentiment scores.
    Promote_Headers = Table.PromoteHeaders(Imported_Review_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support weighted average ratings and sentiment analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"review_id", Int64.Type}, {"product_sk_id", Int64.Type}, {"rating_stars", Int64.Type}, 
        {"review_text", type text}, {"sentiment_score", type number}, {"return_reason_tag", type text}
    }),

    // Removed the heavy 'review_text' column to optimize data model size for Power BI.
    Remove_Text_Field = Table.RemoveColumns(Set_Data_Types,{"review_text"}),

    // Standardized the return reason tags for cleaner categorical reporting.
    Clean_Reason_Tags = Table.TransformColumns(Remove_Text_Field, {
        {"return_reason_tag", each if _ = "Quality - Near Expiry" then "Near Expiry" 
            else if _ = "Service - Logistics" then "Logistic Issue" 
            else if _ = "Damaged - Crushed" then "Damaged" 
            else if _ = "Damaged - Leaked" then "Damaged" 
            else if _ = "None" then "" 
            else _, type text}
    }),

    // Renamed headers to follow a professional, business-friendly convention.
    Renamed_Final_Columns = Table.RenameColumns(Clean_Reason_Tags,{
        {"review_id", "Review ID"}, 
        {"product_sk_id", "Product SK ID"}, 
        {"rating_stars", "Star Rating"}, 
        {"sentiment_score", "Sentiment Score"}, 
        {"return_reason_tag", "Feedback Category"}
    })
in
    Renamed_Final_Columns
