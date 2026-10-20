// fnFiscalCalendar
// Builds a daily calendar table with fiscal year, quarter, month, and week columns.
//
// Parameters:
//   StartDate        - first date in the calendar
//   EndDate          - last date in the calendar
//   FiscalStartMonth - month number the fiscal year begins (1-12). Defaults to 1.
//
// Convention: the fiscal year is named for the calendar year in which it ENDS.
//   Example: FiscalStartMonth = 10 -> Oct 2025 through Sep 2026 is FY2026.
//
// Fiscal week is derived from the actual fiscal year start date, so there are
// no hardcoded week assumptions. Week 1 begins on the fiscal year start date.
//
// Usage:
//   fnFiscalCalendar(#date(2023, 1, 1), #date(2027, 12, 31), 10)

(StartDate as date, EndDate as date, optional FiscalStartMonth as nullable number) as table =>
let
    FYStartMonth = if FiscalStartMonth = null then 1 else FiscalStartMonth,

    ValidMonth =
        if FYStartMonth < 1 or FYStartMonth > 12
        then error "FiscalStartMonth must be between 1 and 12"
        else FYStartMonth,

    DayCount = Duration.Days(EndDate - StartDate) + 1,
    DateList = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
    ToTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    TypedDate = Table.TransformColumnTypes(ToTable, {{"Date", type date}}),

    AddFYStart = Table.AddColumn(
        TypedDate,
        "Fiscal Year Start",
        each #date(
            if Date.Month([Date]) >= ValidMonth then Date.Year([Date]) else Date.Year([Date]) - 1,
            ValidMonth,
            1
        ),
        type date
    ),

    AddFY = Table.AddColumn(
        AddFYStart,
        "Fiscal Year",
        each if ValidMonth = 1 then Date.Year([Date]) else Date.Year([Fiscal Year Start]) + 1,
        Int64.Type
    ),

    AddFiscalMonth = Table.AddColumn(
        AddFY,
        "Fiscal Month",
        each Number.Mod(Date.Month([Date]) - ValidMonth + 12, 12) + 1,
        Int64.Type
    ),

    AddFiscalQuarter = Table.AddColumn(
        AddFiscalMonth,
        "Fiscal Quarter",
        each Number.RoundUp([Fiscal Month] / 3),
        Int64.Type
    ),

    AddFiscalWeek = Table.AddColumn(
        AddFiscalQuarter,
        "Fiscal Week",
        each Number.RoundDown(Duration.Days([Date] - [Fiscal Year Start]) / 7) + 1,
        Int64.Type
    ),

    AddLabels = Table.AddColumn(
        AddFiscalWeek,
        "Fiscal Period Label",
        each "FY" & Text.From([Fiscal Year]) & " Q" & Text.From([Fiscal Quarter]),
        type text
    ),

    Result = Table.AddColumn(
        AddLabels,
        "Fiscal Sort Key",
        each [Fiscal Year] * 100 + [Fiscal Month],
        Int64.Type
    )
in
    Result

