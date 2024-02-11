// This query creates the "genres-2023" table
let
    // Getting data from the csv file "genres.csv"
    Source = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Videogames Released in 2023\datasets\genres.csv"),
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
    // Changing the "id" column type to integer
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns", {{"id", Int64.Type}}),
    // Renaming the "id" and "name" columns to "genre_id" and "genre"
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", {{"id", "genre_id"}, {"name", "genre"}}),
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
    // Adding the "genre_id" column by splitting the "genres" column into rows
    #"Split Column to Rows" = Table.AddColumn(
        #"Promoted Headers1",
        "genre_id",
        each Text.Split(Text.AfterDelimiter(Text.BeforeDelimiter([genres], "]"), "["), ", ")
    ),
    // Expanding the "genre_id" column
    #"Expanded genre_id" = Table.ExpandListColumn(#"Split Column to Rows", "genre_id"),
    // Removing all columns except "id" and "genre_id"
    #"Removed Other Columns" = Table.SelectColumns(#"Expanded genre_id", {"id", "genre_id"}),
    // Renaming the "id" column to "game_id"
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Other Columns", {{"id", "game_id"}}),
    // Changing the "game_id" and "genre_id" columns type to integer
    #"Changed Type1" = Table.TransformColumnTypes(
        #"Renamed Columns1", {{"game_id", Int64.Type}, {"genre_id", Int64.Type}}
    ),
    // Merging the "genres-2023" and "videogames-2023" tables by "genre_id"
    #"Merged Queries" = Table.NestedJoin(
        #"Changed Type1", {"genre_id"}, #"Renamed Columns", {"genre_id"}, "merge", JoinKind.Inner
    ),
    // Expanding the merge
    #"Expanded merge" = Table.ExpandTableColumn(#"Merged Queries", "merge", {"genre"}, {"genre"}),
    // Removing the "genre_id" column
    #"Removed Columns1" = Table.RemoveColumns(#"Expanded merge", {"genre_id"})
in
    #"Removed Columns1"
