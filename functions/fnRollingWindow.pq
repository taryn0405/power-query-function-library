// fnRollingWindow
// Filters a table to a rolling window of the last N periods, including the
// current (possibly partial) period.
//
// Parameters:
//   Source     - table to filter
//   DateColumn - name of the date column to filter on
//   Periods    - number of periods in the window (for example, 4)
//   Grain      - "week", "month", or "quarter". Defaults to "quarter".
//   AsOf       - anchor date for the window. Defaults to today.
//
// Example: Periods = 4, Grain = "quarter", AsOf = 2026-10-20
//   Window runs 2026-01-01 through 2026-12-31 (Q1 through Q4 of 2026).
//
// Tip: pass a fixed AsOf date while testing so results are repeatable.
//
// Usage:
//   fnRollingWindow(MyTable, "Invoice Date", 4, "quarter", null)

(Source as table, DateColumn as text, Periods as number, optional Grain as nullable text, optional AsOf as nullable date) as table =>
let
    GrainValue = Text.Lower(if Grain = null then "quarter" else Grain),
    Anchor = if AsOf = null then Date.From(DateTime.LocalNow()) else AsOf,
    Back = Periods - 1,

    WindowStart =
        if GrainValue = "month" then Date.StartOfMonth(Date.AddMonths(Anchor, -Back))
        else if GrainValue = "quarter" then Date.StartOfQuarter(Date.AddQuarters(Anchor, -Back))
        else if GrainValue = "week" then Date.StartOfWeek(Date.AddWeeks(Anchor, -Back))
        else error "Grain must be week, month, or quarter",

    WindowEnd =
        if GrainValue = "month" then Date.EndOfMonth(Anchor)
        else if GrainValue = "quarter" then Date.EndOfQuarter(Anchor)
        else Date.EndOfWeek(Anchor),

    Filtered = Table.SelectRows(
        Source,
        each
            let
                d = Record.Field(_, DateColumn)
            in
                d <> null and Date.From(d) >= WindowStart and Date.From(d) <= WindowEnd
    )
in
    Filtered
