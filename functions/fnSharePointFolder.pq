// fnSharePointFolder
// Navigates directly to one SharePoint folder instead of crawling the whole
// site. SharePoint.Files(site) enumerates every file on the site, which makes
// refreshes slow. Drilling folder by folder only reads the path you need.
//
// Parameters:
//   SiteUrl    - root URL of the SharePoint site (no trailing library path)
//   FolderPath - list of folder names, starting with the document library
//   Extension  - optional file extension filter such as ".xlsx"
//
// Returns a table of the files in that folder (Name, Content, Extension,
// Date modified, and so on), ready for Excel.Workbook(Content) or similar.
//
// Usage:
//   fnSharePointFolder(
//       "https://contoso.sharepoint.com/sites/Reporting",
//       {"Shared Documents", "Monthly Reports", "2026"},
//       ".xlsx"
//   )

(SiteUrl as text, FolderPath as list, optional Extension as nullable text) as table =>
let
    Site = SharePoint.Contents(SiteUrl, [ApiVersion = 15]),

    DrillDown = List.Accumulate(
        FolderPath,
        Site,
        (state, folderName) => state{[Name = folderName]}[Content]
    ),

    Result =
        if Extension = null
        then DrillDown
        else Table.SelectRows(DrillDown, each Text.Lower([Extension]) = Text.Lower(Extension))
in
    Result
