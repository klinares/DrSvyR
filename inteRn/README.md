# inteRn

An AI coding assistant in RStudio, powered by Claude Opus. Built by a survey
methodologist, for survey methodologists. It sees the names, types and labels
of the objects in your R session, never their values, and asks before it runs
code or writes a file.

## Set up (once)

You need an Anthropic API key. In RStudio's **Console**, run:

```r
source("D:/repos/DrSvyR/inteRn/install.R")
```

(use the path to your copy). It installs what is missing, makes inteRn load
every time R starts, and, if no key is set, opens the file to paste
`ANTHROPIC_API_KEY=...` into.

## Use it

Type in RStudio's **Console**:

```r
ask("How do I set up a survey design for my data?")   # ask anything
my_data %ask% "Which variables need recoding?"        # ask about one object
open_intern()                                          # chat in the Viewer pane
```

In the Viewer chat your console stays free while it thinks; when it wants to
run code or write a file, buttons appear for you to approve. Code blocks have
Copy, Insert (at your cursor) and To console buttons.

A short guide prints when R starts; `intern_help()` shows it again.
`intern_reset()` starts a new conversation.

## What it will and won't do

- **Sees:** object names, classes, column types, variable and value labels,
  and counts with anything under 10 hidden. Never rows or values.
- **Won't read** data files (`.csv`, `.sav`, `.rds`, ...), reports, or
  `.Renviron`; only works inside your current project folder.
- **Asks first** before running code (you choose whether it sees the output)
  or writing a file (you see the change).
- **Checks its code** before you see it: tidyverse style with no loops, ggplot2
  only, colourblind-safe colours. Code it hasn't run is marked `# UNTESTED`.

## Change a setting

Create `inteRn/config.R` with only what you want to change, for example:

```r
INTERN_LLM$pm <- "claude-sonnet-5-5"   # a faster, cheaper model
INTERN_LLM$allow_dirs <- c(".", "D:/shared/code")
```

All settings and their defaults are at the top of `inteRn.R`.

## Files

`inteRn.R` (the tool), `install.R` (setup), `system.md` (its instructions,
editable), `www/` (the chat page), and two tests:

- `tests/smoke.R`: `Rscript --no-init-file inteRn/tests/smoke.R`. No API
  calls; run it after any change.
- `tests/live.R`: `Rscript --no-init-file inteRn/tests/live.R`. Asks the real
  model about 40 questions on toy data (privacy, approvals, the code check,
  survey designs, the Viewer) and writes a transcript. Needs the key and costs
  a little; run it after changing the model or `system.md`. Add case letters
  (`... live.R B K`) to run only some.
