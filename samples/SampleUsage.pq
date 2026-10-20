// SampleUsage
// Demonstrates the library functions against a small mock dataset.
// Everything here is fake data, safe to share publicly.
//
// To run: create the functions first (see the repo README), then paste this
// into a new Blank Query in the Advanced Editor.

let
    // 1. Mock data with messy text, text-typed values, and a bad date
    MockData = #table(
        {"Program", "Invoice Date", "Vendor", "Amount"},
        {
            {"Program A", "2026-01-15", "  Acme   Staffing ", "1200.50"},
            {"Program A", "2026-02-20", "Acme Staffing", "800"},
            {"Program A", "not a date", "Acme Staffing", "300"},
            {"Program A", "2026-07-03", "Acme  Staffing", "950.25"},
            {"Program B", "2026-03-11", "Globex Talent", "2100"},
            {"Program B", "2025-06-30", "Globex Talent", "400"},
            {"Program B", "2026-09-18", " Globex   Talent", "1750.75"}
        }
    ),

    // 2. Clean text
    Cleaned = fnCleanText(MockData, {"Vendor"}),

    // 3. Apply types (the bad date becomes null instead of an error)
    Typed = fnApplyTypes(
        Cleaned,
        {{"Invoice Date", type date}, {"Amount", type number}, {"Vendor", type text}},
        true,
        "en-US"
    ),

    // 4. Keep the last 4 quarters, anchored to a fixed date so results repeat
    Windowed = fnRollingWindow(Typed, "Invoice Date", 4, "quarter", #date(2026, 10, 20)),

    // 5. Add a running total per program
    WithTotals = fnRunningTotal(Windowed, "Program", "Invoice Date", "Amount", "Cumulative Amount")
in
    WithTotals

// Calendar example (use in its own query):
//   fnFiscalCalendar(#date(2024, 1, 1), #date(2027, 12, 31), 10)
