# chaRt, Phase 11: design rights for the model, Excel, and a dashboard you can arrange

Reviewers at Kevin's office called the charts "clunky and not publication ready"; the visuals
their own AI skills produce are better. The cause is the architecture, not the styling: here the
model fills in a form and R draws from fixed rules, so every chart looks like the rules. Kevin's
rulings for this phase:

1. **The model designs, R computes.** R still decides nothing about what is true: the spec, the
   plotted table and the facts are computed and checked as now. The model then writes the
   drawing code for that table, following a design skill, and R runs it under an allow-list.
2. **The model may look at its own chart.** The rendered picture of any chart, including one
   drawn from rows, may be sent back to the model to review and revise. (Rows are still never
   sent as text.)
3. **Skills.** Design skills are markdown files the analyst chooses between; an office's own
   skills are read from a folder on its machine.
4. **Excel files are read.**
5. **The dashboard is arranged by the analyst:** order, sections, titles, what is exported, and
   questions about a chart answered from its facts.

The rule-drawn chart from Phases 1 to 10 stays as the instant first drawing and the fallback, so
the app is never worse than it is today.

## Read first

`CLAUDE.md`; `chaRt/STATUS.md` (current state); `chaRt/DESIGN.md`; the manager's new files, not
yours to edit: `www/reflexes/design.md`, `www/skills/README.md`, `www/skills/editorial.md`; in
`R/spec.R`: `spec_table`, `spec_facts`, `spec_plot`, `drawn_text_faults`, `spec_frames`,
`spec_video`; `R/llm.R`; `R/reflexes.R` (`assemble_system`, `check_numbers`); the Explore server.

## How

You are the lead; one Sonnet worker per part, no mailbox; both smoke runs yourself after each
part (in the background if the machine is slow). First commit the three manager's files with
checksums and add `phase11_prompt.md` to `.rscignore`. Report to `manager/done-11.md` and the top
of `STATUS.md`. Rules as Phase 10 (branch `chart`, no push, only `chaRt/`, PowerShell, Sonnet
only, no Quarto, pandoc or X11, every device through `chart_device()`, no `for` loops, no new
files in `R/`, look before you say done, do not start WSL). Ask Kevin in the chat before
installing a package (`readxl`, `png`, `ggtext` and `patchwork` are the likely ones; say which
are already installed first). Live calls: at most 60 Sonnet calls in the whole phase, counted;
the key is in `.Renviron`, read only by test scripts run from PowerShell.

## Part A. Running the model's drawing code safely

This is the part that must be right. The model's code is text from outside; column names and
labels can carry instructions; the app runs on a server with the analyst's data.

1. `design_guard(code)` in `R/spec.R`: parse the text (a parse error is a refusal); walk the
   whole syntax tree; every function called must be on `DESIGN_TOOLKIT`, every symbol must be
   one of the provided objects, a toolkit function, a column of `d`, or a variable the code
   itself assigned with `<-` or `=` at top level or inside its own anonymous function. Refused
   outright, with the reason named: `::`, `:::`, `@`, `<<-`, `$<-` on anything but its own
   variables, `function` definitions with default arguments that call non-toolkit code, strings
   that are then called, and any name on a deny list kept for clarity (`eval`, `parse`,
   `get`, `mget`, `assign`, `do.call`, `match.fun`, `Recall`, `system`, `system2`, `shell`,
   `file`, `url`, `download.file`, `source`, `library`, `require`, `loadNamespace`,
   `Sys.setenv`, `Sys.getenv`, `options`, `setwd`, `unlink`, `readRDS`, `saveRDS`, `sink`,
   `environment`, `globalenv`, `parent.frame`, `sys.call`, `body`, `formals`, `attr<-` on
   functions, `.Internal`, `.Call`, `.External`). Length limit 6,000 characters.
2. `DESIGN_TOOLKIT`: built explicitly, as a named list of functions, from: ggplot2's exported
   `ggplot`, `aes`, `after_stat`, `after_scale`, `vars`, `labs`, `guides`, `annotate`, `theme`,
   `rel`, `margin`, `unit`, `arrow`, `expansion`, and every exported `geom_*`, `stat_*`,
   `scale_*`, `coord_*`, `facet_*`, `position_*`, `guide_*`, `element_*`, `theme_*` (leave out
   `sec_axis`, `dup_axis`, `coord_polar`, `coord_radial`, `ggsave`, `geom_sf` and its kin,
   anything that reads a file); scales' exported `label_*`, `breaks_*`, `alpha`, `comma`,
   `percent`, `dollar`, `rescale`; ggrepel's two geoms, ggtext's `element_markdown`,
   `element_textbox_simple`, `geom_richtext` and patchwork's operators and `plot_layout`,
   `plot_annotation` when those packages are installed; dplyr's `mutate`, `filter`, `arrange`,
   `group_by`, `ungroup`, `summarise`, `slice_max`, `slice_min`, `slice_head`, `desc`, `n`,
   `if_else`, `case_when`, `lag`, `lead`, `row_number`, `first`, `last`; forcats' `fct_reorder`,
   `fct_rev`, `fct_inorder` when installed; and a fixed list of base functions (arithmetic,
   comparison and logic operators, `c`, `list`, `length`, `rev`, `seq`, `seq_len`, `seq_along`,
   `rep`, `max`, `min`, `range`, `sum`, `mean`, `median`, `round`, `signif`, `abs`, `sqrt`,
   `log`, `log10`, `exp`, `paste`, `paste0`, `sprintf`, `format`, `formatC`, `nchar`, `toupper`,
   `tolower`, `substr`, `trimws`, `ifelse`, `is.na`, `factor`, `levels`, `as.character`,
   `as.numeric`, `as.Date`, `which.max`, `which.min`, `unique`, `sort`, `order`, `head`,
   `tail`, `nrow`, `ncol`, `names`, `[`, `[[`, `$`, `(`, `{`, `<-`, `=`, `if`, `function`,
   `|>`). Put the list in the report. Print it for the model as TOOLKIT.
3. `design_run(code, d, facts, txt, tok, pal)`: evaluates the guarded code in a fresh
   environment whose parent is `emptyenv()` and which holds only the toolkit and the five
   objects (so a name the guard missed does not resolve), under `setTimeLimit(elapsed = 20)`
   and with warnings caught; the result must be a ggplot (or patchwork) object; building and
   drawing it is inside the same limits; the picture is drawn through `chart_device()`.
4. `tok`: the chosen style's values as a plain list (ground, panel, text, muted, accent, slate,
   grid, title_family, body_family, base_size); `pal(n)`: the chosen qualitative palette's
   first n usable colours; `txt`: the spec's title, subtitle, caption, x and y titles after the
   app's own rules (heading stop, upper case by style); `facts`: a named list of the chart's
   facts as strings, each also with its number and label as R values.
5. **After it draws, before anyone sees it,** these must hold or the design is refused:
   - every number written as text on the chart (titles, labels, annotations: read from the
     built plot as `drawn_text_faults` does) is in the facts or in `d`, by `check_numbers`;
   - no text box is clipped or overlaps another (`drawn_text_faults`);
   - bars, columns and areas include zero on their value scale; no second axis; the built
     layers plot the same number of rows per data layer as `d` has for that layer or fewer by
     an explained filter (state your rule and test it; a design that drops rows is refused);
   - the scale type of each axis (continuous, log, discrete, date) is what the spec says;
   - text against its background is at 4.5 to 1.
   Each refusal is one plain sentence the model can act on.
6. **Adversarial checks** (no model call; the heart of the smoke test for this part): at least 40
   hostile codes, each refused by the guard or harmless in the run, among them: `system("x")`,
   ``base::system``, `get("sys" %+% "tem")`, `do.call("system", ...)`, `(function() eval(...))()`,
   a call through `match.fun`, `Reduce(`, `environment(ggplot)`, `ggplot2:::x`, writing a file
   through `ggsave` or `png`, reading one through `read.csv`/`readRDS`/`file`/`url`, an infinite
   loop (`repeat`, `while (TRUE)`), a 10^9-element vector, a deparse-and-eval, `Sys.getenv` of
   the key, redefining `c` or `ggplot` then calling it, `attributes<-`, `body<-`, `trace`, an
   `on.exit`, `Sys.sleep(60)`, a recursive anonymous function, a label built from a column name
   that is itself code, `library(x)`, `requireNamespace`, `options(error = ...)`,
   `reg.finalizer`, `quit()`, `q()`. Say plainly in the report what this is: an allow-list
   interpreter, not a proven sandbox, and what a determined attacker would still try.

## Part B. The design call and the review by looking

1. `CALL_FILES$design` is `core.md` (persona and prohibitions only, if the parser can take a
   section; else whole) and `design.md`; the user message carries SKILL (the chosen skill file,
   whole), TOOLKIT, SPEC (the checked spec as JSON), TABLE (the plotted table's columns with
   type, n, and range or levels; and the table itself when it is aggregated and has at most 60
   rows; never rows of the analyst's file), FACTS, TOKENS and TEXT. Through `llm_json()`.
2. `design_chart(chart, skill, ...)`: call; guard; run; the Part A checks; on a refusal, one
   repair call with the sentence; then the review: the picture (PNG, at most 1,200 pixels wide)
   is sent with the skill's checklist and the code (confirm how the installed ellmer sends an
   image with a message, and that `llm_json`'s path can carry it); the reply is `ok` or new
   code, which goes through the guard, the run and the checks again; at most two review rounds.
   Whatever fails at any point, the chart keeps its rule-drawn picture and the card says in one
   line why the design was not used. Every call is recorded as now, and counted.
3. **Privacy statement, changed truthfully.** Start here, the Methodology page and the README
   say today that the model never sees the data. After this phase: rows are never sent as text;
   an aggregated table of at most 60 rows is sent to design a chart; and the picture of a
   chart, which for a scatter, bubble, box or violin shows individual rows as marks, is sent
   when "Design" is used. A setting `APP_DESIGN_IMAGES` in `app.R` (`"all"`, `"aggregated"`,
   `"none"`; default `"all"` by Kevin's ruling) limits it, and the review is skipped where the
   setting forbids the picture. `www/methodology.md` is the manager's: do not edit it; put the
   sentence in the page around it and tell the manager the exact words used.
4. **In the app.** A chart appears at once in its rule-drawn form, as now. Each card has
   "Design" (one design, with the working line saying what stage it is at), and the canvas has
   "Design all". The Style dialog gains "Design skill" (the skills found, with each skill's
   Intent line) and "Design new charts automatically" (off by default: each design costs two to
   four calls). A designed card shows a small "Designed with <skill>" mark, a switch between the
   designed and the standard drawing, and "Code" shows the design code with the table it draws.
   In the chat, with a chart selected, "redesign this", "make it look better", "make it
   publication ready" and "design this" are handled by R (no chat call) by starting a design; a
   message that asks for a specific look ("put the legend inside", "make the title bigger",
   "use a darker background") goes to the design call as an added line WISH, after the skill.
5. **Skills.** `www/skills/*.md` and, when `APP_SKILLS_DIR` is set and exists, the files there;
   parsed for title, version and Intent; a skill over 120 lines is refused with a sentence. An
   office skill is never committed, logged or written to a report.
6. **What carries a design:** the export (picture, 300 dpi file, the printed code as
   `charts.R` with the table written beside it as CSV so the script runs alone), the
   classification bands, the codebook untouched. The interactive view of a designed chart: build
   it with ggiraph only if the design's layers can be given tooltips mechanically (say how you
   decide); otherwise the card offers the picture and the standard interactive view, labelled
   as such.
7. Checks (stand-in replies): each path of `design_chart` (good first time; refused then
   repaired; refused twice; review changes it; review breaks it and the earlier good design is
   kept; no picture allowed); the message holds no row of the messy file and no
   `SECRET_VALUE_123`; the skill choice reaches the message; an office skill's text is in no
   log.

## Part C. Motion for any chart

Family-specific motion needs to know the chart. A designed chart can be anything, so its motion
is made from the finished picture.

1. `design_video()`: draw the finished design three times at the video size, as PNG with a
   transparent or ground-colour background: (a) the frame (everything but the data and text
   layers: axes, grid, titles), (b) the data layers, (c) the text and annotation layers (decide
   layer membership from the built plot's geoms; say how). Compose the frames as arrays (the
   `png` package if installed; else ask Kevin) and encode with `av` as now: the data layer is
   revealed by the `motion` the model chose (`draw` and `wipe`: a soft-edged mask moving left
   to right; `rise`: bottom to top, or left to right for horizontal bars; `fade`: opacity), with
   the same easing and timings as Phase 9; then the text layer fades in; then the hold. No frame
   is re-drawn by ggplot, so a video should take a few seconds: measure and report.
2. The last frame must equal the finished picture, pixel for pixel; the classification bands
   and the card proportions as in Phase 10b.
3. If the three drawings cannot be separated cleanly for a design (say when), the motion is a
   whole-chart wipe.
4. (look) One video for each motion kind in Editorial and Dark: first, middle and last frames.

## Part D. Excel

1. Find out whether `readxl` is installed; ask Kevin if not. `read_data()` takes `.xlsx` and
   `.xls`: a sheet picker when there is more than one sheet (names and row counts), the header
   row found as the first row with text in most columns (shown, and changeable: "Header is on
   row n"), blank leading rows and columns skipped, merged header cells filled forward and
   joined to the row below, Excel dates read as dates, numbers stored as text offered for
   conversion in the chat as missing codes are, formulas read as their values, a sheet with two
   tables side by side or stacked detected by a blank column or row and the analyst asked which
   (do not guess). Hidden sheets are listed as hidden. Nothing is written to the file.
2. The problems list and the chat setup work for a sheet as for a CSV. The source line names
   the file and the sheet.
3. Checks with small workbooks built in the test by `writexl` if installed, else committed
   fixtures made once by hand (say which): two sheets, an offset header, merged headers, dates,
   text numbers, two tables on a sheet, a hidden sheet, an `.xls` if a fixture can be made.

## Part E. A dashboard the analyst arranges, and questions about a chart

1. **Order by dragging,** with plain HTML drag events and a few lines of script (no package),
   keyboard reachable through the existing Move buttons. **Sections:** "Add a section" puts a
   heading card (title and an optional line of text) on the canvas; cards under it belong to it
   until the next heading; a section can be collapsed, moved with its cards, and left out of
   the export as a whole.
2. **Edit in place:** click a card's headline, title or subtitle to edit it there (Enter to
   keep, Escape to leave); the number and word checks run on a headline or summary as they do
   in the Edit text dialog, and a text that fails is kept but marked.
3. **The export dialog** shows the dashboard as it will be: sections and cards as a list with a
   small picture of each, a switch on each and on each section, the per-card form (picture,
   interactive, video), designed or standard where both exist.
4. **Questions about a chart.** With a card selected, the chat's message to the model carries
   that chart's FACTS (it has only the spec today), so "what is the highest month?", "how much
   higher is West than East?" and "what does this chart show?" are answered as `tell`, checked
   by `check_numbers` against those facts. A question the facts cannot answer gets a chart or
   "the chart's facts do not say"; the model does not compute. If this needs a line in a reflex
   file, tell the manager the gap; do not edit the file.
5. (look) The canvas with two sections and six cards, dragging one, editing a title in place,
   the export dialog; light and dark.

## Part F. Live: is it better?

At most 45 of the 60 calls. On `tests/data/orders.csv` with the saved dictionary, eight charts
from the chat (a ranked bar, a monthly line with several series, a scatter of 3,000 points, a
dumbbell, an indexed line, a box by group, a heatmap, a histogram), each then designed with
Editorial. Write `tests/designed.html`: for each, the standard drawing and the designed one side
by side at card size, the design's `say`, the rounds it took, the refusals with their sentences,
the calls and seconds, and the design code. Then export a dashboard of the eight designed charts
in Briefing tokens, two as video, to `tests/dashboard_designed/`, and look at it at 1400 and
500 pixels. Report honestly: how many designs were accepted, how many fell back and why, and
whether each accepted one is better than the standard drawing in your judgement, and where it
is worse.

## Report (`manager/done-11.md`)

1. Files changed; checks; both smoke totals; calls used of 60.
2. Part A: the toolkit list; the adversarial checks and what each showed; what is not covered.
3. Part B: the message's sections with their sizes in tokens; cost and seconds per design; the
   privacy sentences as written.
4. Part C: seconds per video; what the frames showed; where separation failed.
5. Part D: what Excel shapes are read and which are refused.
6. Part E: what was seen.
7. Part F: the table of eight, with your judgement of each.
8. What nobody has seen, what could not be confirmed, every choice you made.
