// fnCleanText
// Cleans text columns: removes non-printable characters, trims the ends,
// and collapses repeated internal spaces into one.
//
// Parameters:
//   Source  - table to clean
//   Columns - list of column names to clean
//
// Usage:
//   fnCleanText(MyTable, {"Vendor", "Cost Center", "Description"})

(Source as table, Columns as list) as table =>
let
    CleanOne = (value as any) as nullable text =>
        if value = null then null
        else
            let
                asText = Text.Clean(Text.From(value)),
                parts = List.Select(Text.Split(Text.Trim(asText), " "), each _ <> "")
            in
                Text.Combine(parts, " "),

    ExistingColumns = List.Select(Columns, each List.Contains(Table.ColumnNames(Source), _)),

    Result = Table.TransformColumns(
        Source,
        List.Transform(ExistingColumns, each {_, CleanOne, type nullable text})
    )
in
    Result
