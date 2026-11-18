# chaRt

chaRt is a Shiny app that turns a data file into publishable charts. It builds a codebook, proposes
and draws charts that follow written visualization rules, lets the analyst refine a chart by chat,
and writes an HTML report of the charts the analyst chose, each with a short summary. The data are
general, not survey microdata: every chart and summary describes the file, not a population.

This is Phase 0: the skeleton, the key box, the connection check and the probe. `DESIGN.md` is the
whole design and `STATUS.md` says what is built.

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | The settings, the profiles, the packages check, the layout and the server |
| `R/llm.R` | From QuestionR: the session key, the model call, JSON repair, retry, the connection check and the key box |
| `R/ui.R` | The tab names, the shared helpers, the logo, Start here and the connection check |
| `tests/` | The smoke test and the live check, at home. Not deployed |
| `probe/app.R` | A separate one-page app, published once at work to learn what the server can do |
| `DESIGN.md`, `STATUS.md` | The design, and where the build stands |

## Install and run

```r
install.packages(c("shiny", "bslib", "purrr", "ellmer", "httr2", "jsonlite", "rlang", "S7"))
shiny::runApp("chaRt")
```

Built and tested with ellmer 0.4.2; the app stops at start-up, naming anything missing.

## The profiles

Everything an administrator may change is in `app.R`, section 1: the classification banner, the
logo, the upload limit, the Source code link, `APP_DEFAULT_PROFILE` and `APP_PROFILES`. A profile is
one model: `api` (`"anthropic"`, or `"openai"` for the OpenAI style), `base_url` (up to and
including `/v1`) and `id`. The environment variable `CHART_PROFILE` chooses a profile; when it is not
set, `APP_DEFAULT_PROFILE` does.

| Profile | What it is |
|---|---|
| `home` | `claude-sonnet-5-5` on Anthropic's API |
| `work` | The office endpoint, OpenAI style. `<work base url>` and `<model id at work>` are placeholders to fill in at work; until then Start here says so and nothing is called |

## The key

The key is pasted into the box on Start here and held for the session only, exactly as in
QuestionR. It is never saved, never written to a log, and never read from the environment: an
`ANTHROPIC_API_KEY` set in `.Renviron` is ignored by the app. Closing the tab discards it.

## Tests

From inside `chaRt/`:

```bash
Rscript --no-init-file tests/smoke.R       # no model calls
Rscript --no-init-file tests/llm_check.R   # live calls, at home; costs a little
```

The smoke test loads the app the way Connect does and checks the rules for `R/`, the loops and the
key. The live check reads `ANTHROPIC_API_KEY` and `OPENROUTER_API_KEY` from the environment (a test
may; the app never does), pings the home model, and asks for structured output in the Anthropic
style and, through OpenRouter, in the OpenAI style that stands in for the work endpoint.
`OPENROUTER_MODEL` overrides the small model it uses there.

## The probe

`probe/app.R` needs only shiny, makes no model calls and needs no key. Publish it once at work:

```r
rsconnect::deployApp("chaRt/probe", appName = "chaRt-probe")
```

Open it, wait for the table to fill in, and copy the text under "Copy results". It reports the
versions of R and the packages chaRt needs, whether Quarto is found and renders a small document to
self-contained HTML from inside the running app, whether a PNG draws with Cairo, and whether
`tempdir()` is writable.

## Publishing the app

```r
rsconnect::deployApp("chaRt", appName = "chaRt")
```

`.rscignore` keeps `tests/`, `build/`, `probe/` and the markdown files out of the bundle.
