# chaRt: status

Version 1.0, tag `chart-v1.0` on branch `chart-v1` (from `main`), 2026-11-27. Not pushed. Built and
tested at home on R 4.6.1 under Windows 11. No test makes a model call.

## What the app does

chaRt turns one data file (CSV, TSV, or a sheet of an Excel workbook) into charts, a dashboard page
and a codebook. It reads the file, builds a data dictionary, and gives a chat beside a canvas: ask a
question, change a chart in words, or press a button. The model proposes chart specs, headlines and
summaries; R draws every chart, computes every number, and checks every number and word the model
writes against the chart's own facts. R writes a headline for every chart itself, and the model's
replaces it only when it passes the checks. The export is a zip with `dashboard.html` (picture,
interactive or animated cards), `codebook.html`, the pictures, the tables behind them and
`charts.R`, which redraws every chart, all under the classification marking.

What it says about survey data: values that look like codes for missing (98, 99, -9 ...) are named
on the card, on the exported page and in FACTS until the analyst enters them as missing or keeps
them as values (one click each); R's headline then opens "With 98, 99, -9 counted as values,". A
weight or design column is named when the file is read; nothing applies them. A group of fewer than
5 rows has no interval in the summary table, is never named highest or lowest in R's headline, and
carries its count on its axis label.

## Test counts

- On the final code before the folder was cleaned (commit 6e0122e): `[fast] 678 of 678 checks passed.`
  `[heavy] 35 of 35 checks passed.`
- On the cleaned folder (commit dd9d277): `[fast] 678 of 678 checks passed.`
  `[heavy] 35 of 35 checks passed.` The app loads with `shiny::runApp()` (Start here, no script errors).
- From a fresh clone at the tag `chart-v1.0`, with no git-ignored file: the count lines are in the
  tag's message (`git tag -n20 chart-v1.0`). Check 7b-11 reads one saved model reply on the invented
  orders from `tests/reply_7b11.rds`, which is committed; the full live-run file stays git-ignored.
- Each mutation script run once on 6e0122e. The scripts were then removed with the folder's other
  working files; they are in the history at that commit. Every mutation that applied made a check fail:

| Script | Baseline | Mutations caught |
|---|---|---|
| 11A | 16 of 16 | 44 of 44 |
| 11B | 18 of 18 | 16 of 16 |
| 11C | 10 of 10 | 17 of 17 |
| 11D | 14 of 14 | 16 of 16 |
| 11E | 16 of 16 | 23 of 23 (M12 no longer applies: its line was rewritten in Phase 13) |
| 12 | 6 of 6 | 12 of 12 |
| 12b | 4 of 4 | 8 of 8 (M03 no longer applies: its line was rewritten in night task 03) |
| 12c | 4 of 4 | 10 of 10 |
| 13 | 13 of 13 | 15 of 15 |
| night02 | 3 of 3 | 6 of 6 |
| night03 | 9 of 9 | 15 of 15 |
| night05 (designed charts) | 5 of 5 | 8 of 8 |
| task07 (survey fixes) | 8 of 8 | 17 of 17 |

## What was seen, and by whom

- **Claude Code, for version 1.0** (in-app browser, 1400 px, a copy of the app with a stand-in model):
  the read message ending with the weights sentence; the trust histogram's card with its opening,
  its note on 98, 99 and -9 and both links, and each link removing the note; the team chart naming
  Shipping, with "Escalations (3 rows)" on its axis and the note under it. The designed picture in
  `charts/` with a 26-point headline of 105 characters: four lines, the description once.
  Not looked at by eye: the codes note on the exported page and under the summary table (checked
  by T7-B1 and T7-B2 only).
- **The manager (Claude, Chrome, 1400 px, 27 November, on cb417de):** the animated five-chart page;
  the survey rehearsal page before this fix (bars at 98 and 99, no warning); all 39 of R's headlines.
- **Claude Code, Phases 1 to 13:** each phase's pages in Chrome 157 (headless and headed) and the
  in-app browser; the heavy run takes its own screenshots in Chrome. What each phase looked at is in
  the history of this file (`git show cb417de:chaRt/STATUS.md`).
- **Kevin** gave rulings from the reports (no bands inside a card, no Quarto or pandoc); there is no
  record here of Kevin looking at a page of version 1.0.

## What nobody has seen

- **The work server.** The probe (`probe/`) has not been published there, nor has the app. Unknown:
  the graphics device, the fonts, ggiraph's system libraries (gdtools, cairo, freetype), and how long
  the 44 frames of an animated chart take there.
- **Firefox and Safari.** Every page was looked at in Chrome or Chromium only.
- **A real file of Kevin's.** Every run used invented data (`tests/data/orders.csv` and the files the
  tests make). Nobody has run the app on a real file and exported it.
- A live model on the version 1.0 changes: no model call was made for them.

## How to run the tests

From inside `chaRt/`, in PowerShell or the RStudio terminal, one run after the other, never together
(a second R process can leave an `Rplots.pdf` and fail 8A-1):

```
Rscript --no-init-file tests/smoke.R
$env:CHART_SMOKE = "heavy"; Rscript --no-init-file tests/smoke.R; Remove-Item Env:CHART_SMOKE
```

The first is the fast run (about 25 minutes here), the second the heavy run (about 25 minutes:
Chrome, Node and the drawn frames). Each prints one line per check and ends with its count line. Two
checks have time limits (11C-6, 9B-15): they fail when another program loads the machine, so run
them on a quiet machine. The heavy run needs Chrome and Node 22 or later.
