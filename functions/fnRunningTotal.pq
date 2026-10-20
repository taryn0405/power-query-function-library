// fnRunningTotal
// Adds a cumulative total column, restarting for each group.
//
// Performance notes:
//   - Table.Buffer holds the sorted table in memory so it is not re-evaluated.
//   - GroupKind.Local only compares neighboring rows, which is fast because
//     the table is already sorted by group.
//   - List.Generate builds the running total in one pass (linear time),
//     unlike List.Accumulate with list concatenation, which slows down badly
//     on large groups.
//
// Parameters:
//   Source       - table to process
//   GroupColumn  - column that defines each group (running total restarts here)
//   SortColumn   - column that sets the order within each group (for example, a date)
//   ValueColumn  - numeric column to accumulate (nulls are treated as 0)
//   OutputColumn - name of the new column. Defaults to "Running Total".
//
// Usage:
//   fnRunningTotal(MyTable, "Program", "Invoice Date", "Amount", null)

(Source as table, GroupColumn as text, SortColumn as text, ValueColumn as text, optional OutputColumn as nullable text) as table =>
let
    OutName = if OutputColumn = null then "Running Total" else OutputColumn,

    Sorted = Table.Buffer(
        Table.Sort(Source, {{GroupColumn, Order.Ascending}, {SortColumn, Order.Ascending}})
    ),

    AddTotals = (grp as table) as table =>
        let
            vals = List.Buffer(Table.Column(grp, ValueColumn)),
            n = List.Count(vals),
            cumulative = List.Generate(
                () => [i = 0, total = (vals{0}? ?? 0)],
                each [i] < n,
                each [i = [i] + 1, total = [total] + (vals{[i] + 1}? ?? 0)],
                each [total]
            )
        in
            Table.FromColumns(
                Table.ToColumns(grp) & {cumulative},
                Table.ColumnNames(grp) & {OutName}
            ),

    Grouped = Table.Group(
        Sorted,
        {GroupColumn},
        {{"Data", each AddTotals(_), type table}},
        GroupKind.Local
    ),

    Result = Table.Combine(Table.Column(Grouped, "Data"))
in
    Result
