// This query creates the "platforms-2023" table
let
    // Getting data from the csv file "platforms.csv"
    Source = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Videogames Released in 2023\datasets\platforms.csv"),
        [
            Delimiter = ",",
            Columns = 3,
            Encoding = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),
    // Promoting the headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Removing the "" column
    #"Removed Columns" = Table.RemoveColumns(#"Promoted Headers", {""}),
    // Adding the "platform_family" column by checking the values in "name"
    #"Added platform_family" = Table.AddColumn(
        #"Removed Columns",
        "platform_family",
        each
            if [name] = "Android" or [name] = "iOS" then
                "Mobile"
            else if [name] = "PC (Microsoft Windows)" or [name] = "Linux" or [name] = "Mac" then
                "PC"
            else if [name] = "PlayStation 4" or [name] = "PlayStation 5" then
                "PlayStation"
            else if [name] = "Nintendo Switch" then
                "Nintendo"
            else if [name] = "Xbox One" or [name] = "Xbox Series X|S" then
                "Xbox"
            else
                "VR",
        type text
    ),
    // Adding the "platform_order" column by manually setting an order based on the platform family
    #"Added platform_order" = Table.AddColumn(
        #"Added platform_family",
        "platform_order",
        each
            if [platform_family] = "Nintendo" then
                0
            else if [platform_family] = "PlayStation" then
                1
            else if [platform_family] = "Xbox" then
                2
            else if [platform_family] = "PC" then
                3
            else if [platform_family] = "VR" then
                4
            else if [platform_family] = "Mobile" then
                5
            else
                null,
        Int64.Type
    ),
    // Changing the "id" column type to integer
    #"Changed Type" = Table.TransformColumnTypes(#"Added platform_order", {{"id", Int64.Type}}),
    // Renaming the "id" and "name" columns to "platform_id" and "platform"
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", {{"id", "platform_id"}, {"name", "platform"}}),
    // Getting data from the csv file "videogames-2023"
    #"Source videogames-2023" = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Videogames Released in 2023\datasets\videogames-2023.csv"),
        [
            Delimiter = ",",
            Columns = 9,
            Encoding = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),
    // Promoting the headers
    #"Promoted Headers1" = Table.PromoteHeaders(#"Source videogames-2023", [PromoteAllScalars = true]),
    // Adding the "platform_id" column by splitting the "platforms" column into rows
    #"Split Column to Rows" = Table.AddColumn(
        #"Promoted Headers1",
        "platform_id",
        each Text.Split(Text.AfterDelimiter(Text.BeforeDelimiter([platforms], "]"), "["), ", ")
    ),
    // Expanding the "platform_id" column
    #"Expanded platform_id" = Table.ExpandListColumn(#"Split Column to Rows", "platform_id"),
    // Removing all columns except "id" and "platform_id"
    #"Removed Other Columns" = Table.SelectColumns(#"Expanded platform_id", {"id", "platform_id"}),
    // Renaming the "id" column to "game_id"
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Other Columns", {{"id", "game_id"}}),
    // Changing the "game_id" and "platform_id" columns type to integer
    #"Changed Type1" = Table.TransformColumnTypes(
        #"Renamed Columns1", {{"game_id", Int64.Type}, {"platform_id", Int64.Type}}
    ),
    // Merging the "platforms-2023" and "videogames-2023" tables by "platform_id"
    #"Merged Queries" = Table.NestedJoin(
        #"Changed Type1", {"platform_id"}, #"Renamed Columns", {"platform_id"}, "merge", JoinKind.Inner
    ),
    // Expanding the merge
    #"Expanded merge" = Table.ExpandTableColumn(
        #"Merged Queries",
        "merge",
        {"platform", "platform_family", "platform_order"},
        {"platform", "platform_family", "platform_order"}
    ),
    // Removing the "platform_id" column
    #"Removed Columns1" = Table.RemoveColumns(#"Expanded merge", {"platform_id"})
in
    #"Removed Columns1"
