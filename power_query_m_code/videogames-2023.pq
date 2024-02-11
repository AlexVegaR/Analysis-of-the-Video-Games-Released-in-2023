// This query creates the "videogames-2023" table
let
    // Getting data from the csv file "videogames-2023.csv"
    Source = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Videogames Released in 2023\datasets\videogames-2023.csv"),
        [
            Delimiter = ",",
            Columns = 9,
            Encoding = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),
    // Promoting the headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Adding the "release_date" column by converting "first_release_date" to a date
    #"Added release_date" = Table.AddColumn(
        #"Promoted Headers",
        "release_date",
        each #datetime(1970, 1, 1, 0, 0, 0) + #duration(0, 0, 0, Number.FromText([first_release_date])),
        type date
    ),
    // Adding the "release_month_no" column by extracting the month number from "release_date"
    #"Added release_month_no" = Table.AddColumn(
        #"Added release_date", "release_month_no", each Date.Month([release_date]), Int64.Type
    ),
    // Adding the "release_month" column by extracting the month name from "release_date"
    #"Added release_month" = Table.AddColumn(
        #"Added release_month_no", "release_month", each Date.MonthName([release_date]), type text
    ),
    // Renaming the "id" and "total_rating" columns to "game_id" and "rating"
    #"Renamed Columns" = Table.RenameColumns(#"Added release_month", {{"id", "game_id"}, {"total_rating", "rating"}}),
    // Changing the "game_id" and "rating" columns type to integer
    #"Changed Type" = Table.TransformColumnTypes(
        #"Renamed Columns", {{"game_id", Int64.Type}, {"rating", Int64.Type}}
    ),
    // Merging the "videogames-2023" and "age-ratings" tables by "game_id"
    #"Merged Queries" = Table.NestedJoin(
        #"Changed Type", {"game_id"}, #"age-ratings", {"game_id"}, "age-ratings", JoinKind.LeftOuter
    ),
    // Expanding the merge
    #"Expanded merge" = Table.ExpandTableColumn(#"Merged Queries", "age-ratings", {"mature_game"}, {"mature_game"}),
    // Removing all columns except "game_id", "rating", "name", "release_month", "release_month_no", "mature_game"
    #"Removed Other Columns" = Table.SelectColumns(
        #"Expanded merge", {"game_id", "rating", "name", "release_month", "release_month_no", "mature_game"}
    )
in
    #"Removed Other Columns"
