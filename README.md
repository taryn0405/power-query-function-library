<h1 align="center">Power Query Function Library</h1>

<p align="center">
  Reusable, documented M functions for fiscal calendars, rolling windows,
  type-safe cleanup, running totals, and faster SharePoint sourcing.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Power%20Query-M-F2C811?style=for-the-badge&logo=powerbi&logoColor=black" alt="Power Query M" />
  <img src="https://img.shields.io/badge/Data-100%25%20Mock-2EA44F?style=for-the-badge" alt="Mock data only" />
</p>

---

> **Tested:** all functions except `fnSharePointFolder` were tested in Power BI Desktop (October 2026) using the mock data in this repo. `fnSharePointFolder` needs a real SharePoint site, so it is not covered by the demo file.

## What's Inside

| Function | What it does |
| --- | --- |
| [`fnFiscalCalendar`](functions/fnFiscalCalendar.pq) | Daily calendar with fiscal year, quarter, month, and week for any fiscal start month |
| [`fnRollingWindow`](functions/fnRollingWindow.pq) | Filters a table to the last N weeks, months, or quarters |
| [`fnApplyTypes`](functions/fnApplyTypes.pq) | Applies column types from a map, skips missing columns, converts errors to null |
| [`fnCleanText`](functions/fnCleanText.pq) | Removes non-printable characters, trims, and collapses repeated spaces |
| [`fnRunningTotal`](functions/fnRunningTotal.pq) | Cumulative totals by group, built in a single pass for speed |
| [`fnSharePointFolder`](functions/fnSharePointFolder.pq) | Drills straight to a SharePoint folder instead of crawling the whole site |

## How to Use a Function

1. In Power BI Desktop, open **Transform data** to launch Power Query.
2. Choose **New Source > Blank Query**, then open the **Advanced Editor**.
3. Paste the full contents of a `.pq` file, replacing the default text.
4. Rename the query to match the function name (for example, `fnFiscalCalendar`).
5. Call it from any other query.

See [`samples/SampleUsage.pq`](samples/SampleUsage.pq) for a full example that chains several functions together on mock data.

Prefer to see it running? Open [`samples/PowerQueryFunctionLibrary_Demo.pbix`](samples/PowerQueryFunctionLibrary_Demo.pbix) in Power BI Desktop. It includes every function plus a working sample query and a fiscal calendar, all on mock data.

## Design Notes

- **Fiscal year naming:** the fiscal year is named for the calendar year in which it ends. A fiscal year starting in October 2025 is FY2026.
- **No hardcoded week assumptions:** fiscal week is calculated from the real fiscal year start date.
- **Fail loudly on bad input:** functions raise clear error messages for invalid arguments instead of returning quiet nulls.
- **Performance:** `fnRunningTotal` uses `Table.Buffer`, local grouping, and `List.Generate` to stay fast on large tables.
- **Repeatable testing:** `fnRollingWindow` accepts a fixed `AsOf` date so results do not change from day to day while you test.

## About the Data

All sample data in this repository is fabricated. No client, employer, or production data is included.

## Author

**Taryn Ledford**
[LinkedIn](https://www.linkedin.com/in/taryn-ledford)
