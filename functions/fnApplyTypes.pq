// fnApplyTypes
// Applies column data types from a type map, skipping columns that do not
// exist and optionally converting conversion errors to null.
//
// Why: upstream type mismatches are a common source of null and logical
// errors that surface far downstream. Typing in one controlled step makes
// those problems visible and easy to trace.
//
// Parameters:
//   Source      - table to type
//   TypeMap     - list of {columnName, type} pairs
//   ErrorsToNull - replace conversion errors with null. Defaults to true.
//   Culture     - optional culture code such as "en-US"
//
// Usage:
//   fnApplyTypes(
//       MyTable,
//       {{"Invoice Date", type date}, {"Amount", type number}, {"Vendor", type text}},
//       true,
//       "en-US"
//   )

(Source as table, TypeMap as list, optional ErrorsToNull as nullable logical, optional Culture as nullable text) as table =>
let
    ReplaceErrors = if ErrorsToNull = null then true else ErrorsToNull,
    ExistingColumns = Table.ColumnNames(Source),

    ValidMap = List.Select(TypeMap, each List.Contains(ExistingColumns, _{0})),
    ValidNames = List.Transform(ValidMap, each _{0}),

    Typed = Table.TransformColumnTypes(Source, ValidMap, Culture),

    Result =
        if ReplaceErrors
        then Table.ReplaceErrorValues(Typed, List.Transform(ValidNames, each {_, null}))
        else Typed
in
    Result
