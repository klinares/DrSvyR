# chaRt, Phase 6b: more palettes, a "working" signal, and a clean folder

Three things Kevin asked for after Phase 6. Small phase: no mailbox, no workers. You do the work
yourself and stop once, at the point marked STOP, for Kevin's "go".

## Read first

`CLAUDE.md`; `chaRt/STATUS.md` (the Phase 6 sections); `chaRt/R/theme.R`; the Explore part of
`chaRt/R/ui.R`; `chaRt/.gitignore` and `chaRt/.rscignore`.

## Rules

As before: branch `chart`, small commits, no push, nothing outside `chaRt/` is created, edited or
deleted, tests from PowerShell, no model call in this phase, the reflex files are not yours to
edit, every function and argument confirmed in the installed package, no `for` loops, no
em-dashes in prose. `git status` before any checkout, stash or restore. No new package is
installed; if something below needs a package that is not installed, say so at the STOP.

## Part 1. Palettes through paletteer

Today `CHART_PALETTES` in `R/theme.R` is a short list (Okabe-Ito, Paul Tol, viridis, ColorBrewer).
Kevin wants a wider, more modern choice, all drawn through `paletteer`.

1. List what the installed paletteer offers (`paletteer::palettes_d_names`,
   `paletteer::palettes_c_names`, and whatever else it exports; confirm the names). From it, build
   a candidate table for these sources, where the installed paletteer has them: MetBrewer,
   NatParksPalettes, rcartocolor, scico, khroma, PNWColors, nord, ggthemes (the Tableau sets),
   wesanderson. Do not assume a palette exists because it is named here; take names only from
   the installed tables.
2. For each candidate record: its paletteer name, kind (qualitative, sequential, diverging),
   how many colours it has, and the result of the colour-vision check `R/theme.R` already uses
   for the present list. If there is no such check in code, write one function in `R/theme.R`:
   simulate deutan, protan and tritan vision with the `colorspace` package if it is installed
   (confirm the functions), take the smallest pairwise difference between the palette's first
   `n` colours with `farver::compare_colour()` (confirm the method names), for `n` = 3, 5 and 7,
   and report the numbers. Do not pick a pass mark yourself: print the table sorted by that
   number and propose one, saying it is a proposal.
3. Also record, for a qualitative palette, the largest `n` it can serve, and for every palette
   whether its lightest colour is readable on the white and on the dark background.
4. The design, to build after the "go":
   - The three Style selects (qualitative, sequential, diverging) list palettes grouped by
     source, with a short mark beside each that passes the colour-vision check.
   - The defaults stay as they are.
   - A palette that does not pass may be chosen; the canvas then shows one line under Style,
     "This palette is hard to tell apart for some readers with colour-vision differences."
   - A qualitative palette with fewer colours than a chart needs is not stretched: that chart
     falls back to the default palette and its notes say so.
   - A swatch strip beside each name in the select if the installed shiny or bslib select can
     show one (confirm how); otherwise a swatch row under the select for the chosen palette.
   - The app still starts without paletteer, with the built-in palettes only.
5. Checks: every listed palette resolves through paletteer; the marks match the table; the
   fallback for too few colours; the warning line; the app with paletteer absent.

## Part 2. A signal that the chat is working

A model call takes 2 to 30 seconds and the screen gives no sign. The server is busy during the
call, so nothing the server sends can arrive until the call ends: the signal has to start in the
browser.

1. Find out what is already there. Does shinychat 0.4.0 show anything while a reply is pending
   (read its JS)? Does the installed shiny have `useBusyIndicators()` and
   `busyIndicatorOptions()` (confirm the version and the arguments)? Report both at the STOP.
2. The design, to build after the "go":
   - On a chat send, a suggestion click, Suggest charts, Write headlines, Label the columns and
     a card's Headline button, the page script that already disables the call buttons also
     shows, at once and without the server, a line at the foot of the chat: three moving dots
     and words that fit the action ("Thinking", "Writing headlines", "Labelling columns").
   - After 8 seconds the words add "still working". The line carries `role="status"` so a
     screen reader announces it, and the dots do not move when the reader's system asks for
     reduced motion.
   - The line goes when the server re-enables the buttons (the same message), and also when the
     call fails.
   - If shiny's busy indicators exist, turn on the page-level pulse as a second signal; do not
     put spinners on the chart cards.
3. Checks: the script and the status element are in the page; every call path sets and clears
   busy (already tested; extend to the new words); nothing is appended to the chat's message
   list by the signal, so LAST EXCHANGE is unchanged.
4. Say plainly in the report that the moving line was or was not seen in the browser. With no
   key, a send ends at once with "a key is needed", so it may flash too briefly to see.

## Part 3. A clean folder

Kevin: "Clear the repo of files we do not need." Scope: `chaRt/` only.

1. Build an inventory of every file under `chaRt/`, tracked and untracked: path, size, tracked
   or not, ignored or not, what refers to it (grep the R code, tests, README, STATUS, DESIGN,
   `.rscignore`), and your proposal: keep, remove, or ignore.
2. Proposals to start from; change any you can show is wrong:
   - Keep: `app.R`, `R/`, `www/` (reflex files), `probe/` (still to be published at work),
     `tests/smoke.R`, `tests/llm_check.R`, `tests/live_gallery.R`, `tests/data/`, the fixtures
     the smoke test reads, `README.md`, `STATUS.md`, `DESIGN.md`, `manager/README.md`,
     `.gitignore`, `.rscignore`.
   - Remove from the repository: `phase0_prompt.md` to `phase5_prompt.md` and the lettered ones
     between (they are kept in the Claude project); generated output (`tests/live_gallery.html`,
     `tests/live_replies.rds`, `tests/live_run_6.out`, gallery pages and images, anything a test
     writes) and add each pattern to `.gitignore`; scratch and mutation files; fixtures and
     helpers that nothing reads since Phase 6.
   - Keep for now: `phase6_prompt.md`, `phase6b_prompt.md`.
   - STATUS.md: propose (do not do) a shorter file that keeps the current state and the standing
     findings and moves the phase-by-phase history under one "History" heading.
3. Nothing is removed before the "go". After it: `git rm` for tracked files, in one commit whose
   message lists them, so each can be restored from history. Untracked files are removed only if
   Kevin's "go" names them; otherwise they are listed and left. `manager/q-*.md`, `a-*.md` and
   `done-6.md` are untracked: list them and leave them.
4. Outside `chaRt/`: touch nothing. If you see files there that look left over from chaRt work,
   name them in the report.
5. After the removal, run the smoke test, load the app, and check that the `.rscignore` still
   keeps tests, prompts, the mailbox and the probe out of a deployment of the app.

## STOP

Before building or removing anything, show Kevin, in the chat:

1. The palette table (Part 1, items 1 to 3) and your proposed pass mark and list.
2. What shinychat and shiny already offer for a pending call (Part 2, item 1).
3. The inventory with a proposal for each file (Part 3, items 1 and 2).

Then wait for his "go", and build exactly what he approves.

## Report back (in the chat, and as a new section of `STATUS.md`)

1. Files changed and removed, with line counts.
2. The smoke total and the new checks' lines.
3. The palettes now offered, by source and kind, with the mark.
4. What was seen in the browser (the Style dialog; the working line), and what was not.
5. Everything you could not confirm, and every departure and why.
