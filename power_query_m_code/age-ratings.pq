// This query creates the "age-ratings" table
let
    // Getting data from the csv file "age-ratings.csv"
    Source = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Videogames Released in 2023\datasets\age-ratings.csv"),
        [
            Delimiter = ",",
            Columns = 3,
            Encoding = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),
    // Promoting the headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Removing the characters "[", "]", "{" and "}" from each row in the "age_rating" column
    #"Cleansed age-ratings" = Table.ReplaceValue(
        #"Promoted Headers",
        each [age_ratings],
        each Text.AfterDelimiter(Text.BeforeDelimiter([age_ratings], "}]"), "[{"),
        Replacer.ReplaceValue,
        {"age_ratings"}
    ),
    // Splitting the "age_ratings" column into rows
    #"Split Column to Rows" = Table.ExpandListColumn(
        Table.TransformColumns(
            #"Cleaned age-ratings",
            {
                {
                    "age_ratings",
                    Splitter.SplitTextByDelimiter("}, {", QuoteStyle.Csv),
                    let
                        itemType = (type nullable text) meta [Serialized.Text = true]
                    in
                        type {
                            itemType
                        }
                }
            }
        ),
        "age_ratings"
    ),
    // Adding the "age_rating" column by replacing the values of "age_ratings"
    #"Added age_rating" = Table.AddColumn(
        #"Split Column to Rows",
        "age_rating",
        each
            if Text.AfterDelimiter([age_ratings], "'rating': ") = "6" then
                "Rating Pending"
            else if Text.AfterDelimiter([age_ratings], "'rating': ") = "7" then
                "Early Childhood"
            else if Text.AfterDelimiter([age_ratings], "'rating': ") = "8" then
                "Everyone"
            else if Text.AfterDelimiter([age_ratings], "'rating': ") = "9" then
                "Everyone 10+"
            else if Text.AfterDelimiter([age_ratings], "'rating': ") = "10" then
                "Teen"
            else if Text.AfterDelimiter([age_ratings], "'rating': ") = "11" then
                "Mature 17+"
            else if Text.AfterDelimiter([age_ratings], "'rating': ") = "12" then
                "Adults Only 18+"
            else
                null,
        type text
    ),
    // Removing rows with null values
    #"Filtered Nulls" = Table.SelectRows(#"Added age_rating", each [age_rating] <> null),
    // Adding the "mature_game" column by checking the values in "age_rating"
    #"Added mature_game" = Table.AddColumn(
        #"Filtered Nulls",
        "mature_game",
        each if [age_rating] = "Mature 17+" or [age_rating] = "Adults Only 18+" then "Yes" else "No",
        type text
    ),
    // Removing the "" and "age_ratings" columns
    #"Removed Columns" = Table.RemoveColumns(#"Added mature_game", {"", "age_ratings"}),
    // Changing the "id" column type to integer
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns", {{"id", Int64.Type}}),
    // Renaming the "id" column to "game_id"
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", {{"id", "game_id"}})
in
    #"Renamed Columns"
