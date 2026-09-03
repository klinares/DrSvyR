# core.R for DrSvyR
# Paths, the repository guard, caching, the decision log, and every line of help text the analyst reads.

# Merged from: 
#   project.R
#   00_project.R
#   logging.R
#   help_text.R

# ---- project -----------------------------------------------------------

# Where the workflow is allowed to read and write, and what gets cached.

#   1. The repository boundary
#   2. The work folder
#   3. Remembering the work folder between sessions
#   4. Stage caching

# The repository holds code, templates and the material the language model
#   reads. Everything belonging to a dataset -- the file itself, the technical
#   report, the dictionary, the decision log, the cached fits and every output
#   -- lives in a folder the analyst owns, outside the repository. Nothing in
#   the workflow writes to the repository at run time.

# Requires: fs, digest, purrr, tibble


# Section 1 keeps outputs off the repository. .gitignore prevents committing,
#   which is not the same thing: a file written into the repo is still on disk,
#   still in the working tree, and still one `git add -f` from being published.
#   The guard is what actually prevents it.
#______________________________________________________________________________

# Stamped on every report so an analyst can say which version produced their
#   numbers, and so a reader can ask for that version rather than whatever is
#   current. Bump it when anything that changes a result changes.
WISE_VERSION <- "1.0"

repo_root <- function() {
  fs::path_real(here::here())
}

# Lexical normalisation rather than resolution, because the target usually does
#   not exist yet -- it is about to be written. A symlink or a Windows junction
#   pointing from outside the repo into it would defeat this; on a single
#   analyst machine that is a theoretical risk rather than a live one, and
#   resolving it would mean walking to the nearest existing ancestor on every
#   write.
# Outputs never land inside the clone. The work folder holds the decision log,
#   the cached fits, the scored survey file and the report, and a git status
#   that lists respondent-level data is one `git add .` away from a disclosure
#   no .gitignore is asked about. The refusal is here rather than only in the
#   screen that picks the folder, because wise_path() is the single place every
#   write is built.
assert_outside_repo <- function(path) {
  p = fs::path_abs(path)
  if (fs::path_has_parent(p, repo_root()))
    stop("That path is inside the repository: ", p, "\n",
         "The work folder holds your outputs and your scored data. Choose a ",
         "folder outside ", repo_root(), " -- something like D:/work/",
         "my_project.", call. = FALSE)
  invisible(path)
}


# Section 2 is the work folder. The analyst creates one folder and drops the
#   data file and the technical report into it; everything below is scaffolded
#   rather than required, because a half-built folder tree is a whole category
#   of failure that looks like a bug in the workflow.
#______________________________________________________________________________

WISE_SUBDIRS <- c("data", "docs", "dict", "decisions", "cache", "output")

.wise <- new.env(parent = emptyenv())
.wise$work_dir <- NULL      # the no-Shiny case: a script, a test, one user
.wise$sessions <- list()    # browser token -> folder, for a shared server
.wise$plan_workers <- NULL  # the worker count the future plan is currently set to


# How many workers, and where that number comes from.
#______________________________________________________________________________

# The worker count is a property of the machine the app is running on, not of
#   the analysis, so it is resolved in one place and every session in the
#   process gets the same answer.

# future::availableCores() describes the host. On a laptop that is the right
#   answer. On a Shiny server it is wrong twice over. The app's share of that
#   host is whatever the other analysts are not using at that moment, and
#   future::plan() sets the plan for the whole R process rather than for one
#   session -- so four workers each looks like four until five people are
#   working, and then it is twenty R processes, every one of them carrying
#   survey and the model, on a box sized for one analysis at a time.

# So the machine is asked what it has, and one is left for the session itself
#   so the screen keeps responding. availableCores() reads a container's CPU
#   quota where there is one, which is what a Connect deployment usually has,
#   and falls back to the physical count where there is not.

# DRSVYR_WORKERS overrides it. That is the lever for a shared server, where
#   the honest number is not "what this host has" but "what this host has
#   divided by how many analysts are on it" -- something no code can work out
#   for itself. DRSVYR_WORKERS=1 turns parallelism off entirely; there is no
#   second flag to keep in agreement with this one.
# Four, and it is a ceiling rather than a target. The deployment is a shared
#   Linux server with sixteen dedicated cores: at four workers each, three
#   analysts searching at once come to twelve and the box still has headroom
#   for the sessions themselves. Twelve was a laptop number and would let one
#   analyst take the whole machine.
# This does not change what the search produces. The two-stage start set picks
#   its survivors across the whole set rather than within each parallel block,
#   so the worker count changes how long the search takes and nothing else.
#   That invariant is the reason this can be tuned for a server without
#   anybody's results moving, and it is worth re-checking at 1, 2 and 4
#   workers -- parameters, not just the log-likelihood -- after any change to
#   the search.
WISE_WORKERS_CAP <- 4L

.wise_workers_resolve <- function() {
  host = suppressWarnings(as.integer(future::availableCores()))
  if (is.na(host) || host < 1L) host = 1L

  cap = function(n, src)
    list(n = max(1L, min(n, WISE_WORKERS_CAP, host)), source = src, host = host)

  n = suppressWarnings(as.integer(Sys.getenv("DRSVYR_WORKERS", "")))
  if (!is.na(n) && n >= 1L) return(cap(n, "DRSVYR_WORKERS"))

  o = getOption("drsvyr.workers", NULL)
  n = if (is.null(o)) NA_integer_ else suppressWarnings(as.integer(o))
  if (!is.na(n) && n >= 1L) return(cap(n, "options(drsvyr.workers)"))

  cap(host - 1L, "cores available")
}

wise_workers <- function() .wise_workers_resolve()$n

# Recorded in the configuration table rather than shown on the screen. It is
#   provenance for the decision log -- the same specification on a different
#   machine used a different number of workers and reached the same answer --
#   not something an analyst has to act on.
wise_workers_note <- function() {
  r = .wise_workers_resolve()
  paste0(r$n, " of ", r$host, " cores")
}

# The work folder has to be per analyst, not per process. On a laptop those
#   are the same thing. On Posit Connect one R process serves several people
#   at once, and a single folder held in this environment means the second
#   analyst to choose one silently redirects the first analyst's writes into
#   it -- scored respondent-level files included. That is a disclosure, not a
#   bug, so the folder is keyed on the Shiny session.

# Shiny hands the current session to anything called inside a reactive and
#   NULL to anything called outside one, so the single-user path is unchanged
#   and needs no flag to select it.
.wise_session <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) return(NULL)
  shiny::getDefaultReactiveDomain()
}

# Checked before anything is created, so a folder chosen by mistake fails on
#   selection rather than after the first stage has written to it.
scaffold_work_folder <- function(path) {
  path = fs::path_abs(path)

  # Checked here as well as in wise_path(), because this is where the folder
  #   is adopted. Refusing at the first write instead would leave the analyst
  #   several screens in before anything said so.
  assert_outside_repo(path)

  if (!fs::dir_exists(path))
    stop("No such folder: ", path, call. = FALSE)

  # The write probe stays. It catches a folder chosen by mistake at selection
  #   rather than after the first stage has tried to write to it, which is a
  #   different problem from where the folder sits.
  probe = fs::path(path, ".wise_write_probe")
  ok = try(fs::file_create(probe), silent = TRUE)
  if (inherits(ok, "try-error"))
    stop("Cannot write to ", path, ". Choose a folder you own.", call. = FALSE)
  fs::file_delete(probe)

  fs::dir_create(fs::path(path, WISE_SUBDIRS))

  s = .wise_session()
  if (is.null(s)) {
    .wise$work_dir <- path
  } else {
    tok = s$token
    .wise$sessions[[tok]] <- path
    # .wise is an environment, so the closure writes to it by reference and
    #   the registry does not grow across a day of sessions.
    s$onSessionEnded(function() .wise$sessions[[tok]] <- NULL)
  }
  invisible(path)
}

work_dir <- function() {
  s = .wise_session()
  p = if (is.null(s)) .wise$work_dir else .wise$sessions[[s$token]]
  if (is.null(p))
    stop("No work folder set. Call scaffold_work_folder() first.", call. = FALSE)
  p
}

# Every path the workflow writes to is built here, so the guard is applied once
#   rather than remembered at each call site.
wise_path <- function(...) {
  assert_outside_repo(fs::path(work_dir(), ...))
}

# The work folder, made rather than chosen.

# It used to be a path the analyst typed. On a shared server there is no such
#   path: the analyst has no filesystem to point at, and the one the server has
#   belongs to every other session at once. So the folder is a temporary one
#   per session, with the same layout as before, and the analyst receives its
#   contents as one archive from the Outputs screen.
# Everything downstream still goes through wise_path(), so this is the only
#   place that had to change. Nothing else knows where it is writing.
open_session_folder <- function() {
  path = fs::path(tempfile("drsvyr_"))
  fs::dir_create(fs::path(path, WISE_SUBDIRS))
  s = .wise_session()
  if (is.null(s)) {
    .wise$work_dir <- path
  } else {
    tok = s$token
    .wise$sessions[[tok]] <- path
    # Deleted when the session ends, not merely forgotten. A forgotten folder
    #   is respondent data left on a shared server with nobody's name on it.
    s$onSessionEnded(function() {
      .wise$sessions[[tok]] <- NULL
      try(fs::dir_delete(path), silent = TRUE)
    })
  }
  invisible(path)
}

# The demonstration survey, wherever it ended up. system.file() finds it once
#   this is a package; the demo/ folder is the fallback while it is not.
demo_survey_path <- function() {
  p = system.file("extdata", package = "drsvyr")
  cand = if (nzchar(p)) fs::dir_ls(p, regexp = "[.](sav|zsav|dta)$", fail = FALSE)
         else character(0)
  if (!length(cand)) {
    d = fs::path(repo_root(), "demo")
    cand = if (fs::dir_exists(d))
      fs::dir_ls(d, regexp = "[.](sav|zsav|dta)$", fail = FALSE) else character(0)
  }
  if (length(cand)) as.character(cand[[1]]) else NULL
}

# Everything the analyst leaves with, in one file.

# ZIP, not tar.gz, and the reason is where the file is opened rather than where
#   it is made. It is built on a Linux server and double-clicked on a Windows
#   desktop by someone who has never opened a terminal. Windows Explorer has
#   opened .zip natively since XP; .tar.gz it either cannot open at all or
#   unpacks in two steps, leaving the analyst holding a .tar and a question.

# zip::zip(), not utils::zip(). utils::zip() shells out to whatever R_ZIPCMD
#   points at, which is absent on a Windows box without Rtools and not
#   guaranteed in a slim conda environment either. zip:: carries its own
#   compressor, so there is nothing on the PATH to be missing, and it writes
#   forward-slash paths so the archive is portable both ways.

# What travels, and what does not:
#   report.html   every table, every figure, the decision log and the
#                 specification, all inside one file that opens in a browser.
#   *_wise.sav    the survey back with segments added. The only thing here
#                 the report cannot be.
#   cfg.R         the specification as a file you can source, which is not
#                 the same as the specification as text in a tab.
#   decisions/    the log as markdown. Also inside the report; kept because an
#                 audit trail should survive without a browser.
#   errors.log    only when something failed.
#   cache/        never. Fitted models keyed to this data, rebuildable, the
#                 largest thing here, and useless without the app.
#   the CSVs      no longer written. Every one of them was a copy of a table
#                 the report already carries, and the report will hand any of
#                 them back as CSV on a button.
bundle_outputs <- function(con) {
  root = work_dir()

  files = fs::path_rel(
    fs::dir_ls(root, recurse = TRUE, type = "file", all = FALSE), root)
  files = as.character(files)
  files = files[!grepl("^cache/", files)]
  # An empty errors.log means nothing went wrong, and shipping it invites the
  #   analyst to open a file with nothing in it and wonder what they missed.
  files = files[!(basename(files) == "errors.log" &
                    fs::file_size(fs::path(root, files)) == 0)]

  if (!length(files))
    stop("Nothing has been written yet. Prepare the outputs first.",
         call. = FALSE)

  if (!requireNamespace("zip", quietly = TRUE))
    stop("The zip package is needed to build the download and is not ",
         "installed here.", call. = FALSE)

  zip::zip(zipfile = con, files = files, root = root, mode = "cherry-pick")
  invisible(con)
}


# What the analyst actually dropped in. Extensions rather than fixed names,
#   and the whole folder rather than just data/, because an analyst who put the
#   file at the top level is not wrong -- they just have not read the layout.
survey_work_folder <- function(path = work_dir()) {
  found = function(glob) {
    fs::dir_ls(path, recurse = TRUE, type = "file", glob = glob) |>
      purrr::discard(function(f) fs::path_has_parent(f, fs::path(path, "output")))
  }
  tibble::tibble(
    kind = c(rep("data", length(found("*.sav")) + length(found("*.dta"))),
             rep("document", length(found("*.pdf")))),
    file = c(found("*.sav"), found("*.dta"), found("*.pdf")))
}


# Returns NULL rather than erroring when there is nothing remembered or the
#   folder has since moved, so the app can offer it as a default and fall back
#   to asking.



# What a domain variable is called on the page
#______________________________________________________________________________

# The variable name is the key and stays the key: cfg$aux, the scored frame,
#   svyby's by-formula and the indicator matrices are all built from it, and a
#   population share computed against a display name would be computed against
#   nothing. So the label is resolved at the moment of rendering and never
#   substituted into the data.

# Defaults to the variable name, so a configuration written before labels
#   existed reads exactly as it did.
aux_label <- function(cfg, v) {
  labs = cfg$aux_labels %||% character(0)
  lab = if (v %in% names(labs)) as.character(labs[[v]]) else NA_character_
  if (is.na(lab) || !nzchar(lab)) v else lab
}

# Headings carry both, because a reader needs the words and a methodologist
#   re-running this needs the column. Prose carries the label alone.
aux_heading <- function(cfg, v) {
  lab = aux_label(cfg, v)
  if (identical(lab, v)) v else paste0(lab, " (", v, ")")
}

# The order the analyst declared, or NULL where there is nothing to declare it
#   from. Every table and figure of a domain reads it from here, so they cannot
#   disagree about the order of the same categories.
aux_levels <- function(state, v) {
  d = state$demo_dat
  if (is.null(d) || !v %in% names(d)) NULL else levels(d[[v]])
}


# Errors that say where they came from
#______________________________________________________________________________

# try(expr, silent = TRUE) keeps the message and throws the call stack away.
#   That is why a failure in a results panel could report "non-conformable
#   arguments" and nothing else -- true, unhelpful, and impossible to place
#   without rerunning the whole session under a debugger.

# A calling handler runs at the moment the error is signalled, while the stack
#   is still standing, so the stack is captured there and the condition is let
#   through to tryCatch to unwind as usual. The app's own functions are the
#   ones in the global environment after R/ is sourced, so the deepest frame
#   that is one of ours is the place worth naming; everything below it is
#   dplyr or survey internals that mean nothing to an analyst.

# The returned object is shaped exactly like try()'s, so every existing call
#   site keeps working and simply gets a better message.
wise_try <- function(expr, what = "This step") {
  trace = NULL

  res = tryCatch(
    withCallingHandlers(
      expr,
      error = function(e) {
        trace <<- vapply(sys.calls(), function(cl)
          tryCatch(deparse(cl[[1]])[1], error = function(...) NA_character_),
          character(1))
      }),
    error = function(e) e)

  if (!inherits(res, "condition")) return(res)

  ours = if (is.null(trace)) character(0)
         else trace[!is.na(trace) & trace %in% ls(globalenv())]
  where = if (length(ours)) ours[length(ours)] else NA_character_

  msg = conditionMessage(res)
  res$message = paste0(
    what, " failed",
    if (!is.na(where)) paste0(" in ", where, "()") else "",
    ": ", msg)

  # The full stack goes to the work folder rather than into a notification an
  #   analyst cannot copy out of. Wrapped because a failure before the folder
  #   is chosen must not turn into a second failure about logging the first.
  try({
    p = fs::path(work_dir(), "errors.log")
    cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", res$message, "\n",
        if (length(trace)) paste0("  ", rev(trace), collapse = "\n") else "",
        "\n\n", sep = "", file = p, append = TRUE)
  }, silent = TRUE)

  invisible(structure(paste0("Error: ", res$message, "\n"),
                      class = "try-error", condition = res))
}

# Named dimension checks, so a mismatch reports the two things that disagreed
#   rather than "non-conformable arguments". Used at the points where a matrix
#   built from the respondents meets one built from the estimates: that is
#   where a domain level with no respondents, or a segment count that moved
#   under a refit, actually shows up.
check_dims <- function(n, expected, what, detail = NULL) {
  if (!isTRUE(n == expected))
    stop(what, ": expected ", expected, " but got ", n, ".",
         if (!is.null(detail)) paste0(" ", detail) else "",
         call. = FALSE)
  invisible(TRUE)
}


# Section 4 caches the expensive stages. The analyst's loop is drop an item,
#   refit, look, repeat: without caching, every pass re-runs the replicate
#   design and the whole dimension search, neither of which changed.
#______________________________________________________________________________

# The key covers only what a stage actually depends on, which is the point.
#   Changing the item list invalidates the search and everything after it and
#   leaves the design alone; changing the data file invalidates everything.
cache_key <- function(...) {
  digest::digest(list(...))
}

cache_file <- function(stage, key) {
  wise_path("cache", paste0(stage, "_", substr(key, 1, 12), ".rds"))
}

cache_read <- function(stage, key) {
  f = cache_file(stage, key)
  if (fs::file_exists(f)) readRDS(f) else NULL
}

cache_write <- function(stage, key, value) {
  saveRDS(value, cache_file(stage, key))
  invisible(value)
}

# The pattern every stage uses. Cached results are returned silently; a miss
#   says so, because a stage the analyst expected to be instant and was not is
#   usually a sign that something upstream changed when they did not mean it to.
cached <- function(stage, key, compute) {
  hit = cache_read(stage, key)
  if (!is.null(hit)) return(hit)
  message("Running ", stage, " (no cached result for this specification).")
  cache_write(stage, key, compute())
}

# Cached fits are keyed, so a stale one is never read -- but they accumulate
#   across an iterating session and each holds a fitted model. Called from the
#   app when the analyst finishes a run.
cache_clear <- function(stage = NULL) {
  files = fs::dir_ls(wise_path("cache"), glob = "*.rds")
  if (!is.null(stage))
    files = files[fs::path_file(files) |> startsWith(paste0(stage, "_"))]
  fs::file_delete(files)
  invisible(length(files))
}

# ---- logging -----------------------------------------------------------

# The decision log.

# Every choice the analyst makes is written to the work folder as it is made,
#   with the evidence that was in front of them at the time. Two reasons. The
#   analyst is not a modeller, so "the analyst decided" is only a real defence
#   if the basis for the decision travels with it. And a specification arrived
#   at through several rounds is defensible when the rounds are disclosed and
#   not otherwise.

# Append-only markdown rather than a structured format: it is read by people,
#   it diffs, and a corrupted line costs one entry rather than the file.

# Requires: fs, glue

WISE_LOGS <- c(
  scope      = "00_scope.md",
  design     = "01_design.md",
  recodes    = "02_recodes.md",
  iterations = "03_iterations.md",
  dimension  = "04_dimension.md",
  labels     = "05_labels.md")

log_path <- function(which) {
  wise_path("decisions", WISE_LOGS[[which]])
}

# stamp is passed in rather than taken from the clock, so a caller that needs
#   several entries to share a time can do that, and so this is testable.
log_decision <- function(which, heading, decision, evidence = NULL,
                         stamp = format(Sys.time(), "%Y-%m-%d %H:%M")) {
  f = log_path(which)
  if (!fs::file_exists(f)) {
    cat("# ", tools::toTitleCase(gsub("_", " ", which)), "\n\n",
        "Written by DrSvyR as decisions are made. Do not edit; it is the ",
        "record of what was chosen and why.\n", sep = "", file = f)
  }

  cat("\n## ", heading, "\n",
      "_", stamp, "_\n\n",
      decision, "\n",
      if (!is.null(evidence)) paste0("\n**Evidence at the time**\n\n", evidence, "\n")
        else "",
      sep = "", file = f, append = TRUE)

  invisible(f)
}

# A table rendered as markdown, for the evidence block. Kept here rather than
#   pulling in a formatting package for one job.
log_table <- function(df) {
  hdr = paste0("| ", paste(names(df), collapse = " | "), " |")
  sep = paste0("| ", paste(rep("---", ncol(df)), collapse = " | "), " |")
  rows = purrr::map_chr(seq_len(nrow(df)), function(i)
    paste0("| ", paste(as.character(unlist(df[i, ])), collapse = " | "), " |"))
  paste(c(hdr, sep, rows), collapse = "\n")
}

read_decisions <- function(which) {
  f = log_path(which)
  if (fs::file_exists(f)) paste(readLines(f, warn = FALSE), collapse = "\n") else ""
}

# How many times the analyst went back and refitted. Printed in the report,
#   because fit statistics reported after a search are optimistic and a reader
#   cannot discount what they are not told.
iteration_count <- function() {
  f = log_path("iterations")
  if (!fs::file_exists(f)) return(0L)
  sum(grepl("^## ", readLines(f, warn = FALSE)))
}

# ---- help_text ---------------------------------------------------------

# Every instruction the analyst reads, in one place.

# Kept together rather than scattered through the modules so the wording can be
#   revised without touching any logic, and so it is obvious at a glance what
#   the app claims to explain. Written for an analyst who designed the
#   questionnaire and does not fit latent variable models: say what the number
#   means for the decision in front of them, not what the statistic is.

WISE_HELP <- list(

  project = paste(
    "Point to a folder on your machine holding the survey file and the",
    "technical report. Results are written there too. Nothing is saved into",
    "the program's own folder."),

  design = paste(
    "Complex surveys are not simple random samples: people are selected in",
    "groups, and some count for more than others. Tell the app which columns",
    "record that, and it will check whether the specification holds together.",
    "The variable named 'strata' is not always the stratum -- read the labels."),

  na_codes = paste(
    "Answers like 'don't know' and 'refused' are stored as numbers. These were",
    "read from the file itself. Leave them checked to treat them as missing.",
    "Uncheck one only if you want it kept as a real answer category."),

  items = paste(
    "Choose the questions that belong to one battery -- items you would expect",
    "to hang together because they ask about the same underlying thing. Three",
    "at minimum, and more is usually better. You can change this later."),

  variation = paste(
    "The chart and table show how people actually answered. Look for an item",
    "where nearly everyone gave the same response: it will not help",
    "distinguish anyone from anyone else, however sensible the question. The",
    "Modal % column is that number. Anything above 85% is worth a second look.",
    "\n\nShared with fewest is how many respondents answered this item and the",
    "item it overlaps least with. A zero means the two were asked of different",
    "people -- a split ballot -- and no model can relate them however well they",
    "belong together."),

  domains_pick = paste(
    "Choose the background variables you want to compare across -- age, sex,",
    "region, education, and so on. These are not part of the model. They are",
    "how you will describe who ended up where. Items already in your battery",
    "are excluded."),

  recode_map = paste(
    "One box per answer category. Type the group you want it to belong to.",
    "Typing the same name against two categories merges them. Leaving a box",
    "empty treats that category as missing.",
    "\n\nThe reference level is the group later comparisons are read against.",
    "The dropdown offers whatever groups you have typed. This one is yours to",
    "choose -- it decides how the findings read, so it depends on what you",
    "want to say, not on anything in the data."),

  recode_cut = paste(
    "This variable is a number, so it is cut into bands. Give the cut points",
    "and a name for each band. There should be one fewer name than cut point.",
    "The distribution below is what people actually reported."),

  recode_result = paste(
    "Counts for each collapsed group. A group under about thirty respondents",
    "will produce an estimate with an interval too wide to act on -- merge it",
    "into a neighbour or accept that it cannot be reported."),

  recode_audit = paste(
    "What each original answer became. Read this once. It is the only place a",
    "mistake here would show: nothing will fail, no statistic will look wrong,",
    "and every later table would quietly be about the wrong people."),

  config = paste(
    "Everything you have decided, in the order you decided it. Read it as a",
    "whole rather than field by field: this is the analysis that is about to",
    "run, and it is the last point at which changing your mind is cheap."),

  config_commit = paste(
    "Approving writes the configuration and the data dictionary to your work",
    "folder, and starts the decision log. You can still go back afterwards,",
    "but going back means going back through the model search."),

  search = paste(
    "The model will be fitted at every plausible number of groups or factors.",
    "No number is correct in the abstract -- you are choosing between",
    "descriptions of the same people. The statistics support that choice; they",
    "do not make it."),

  profiles = paste(
    "Each line is one group, and the height at each item is where that group",
    "sits on it, rescaled so every item spans the same range. This is the",
    "picture to judge. Two lines that track each other describe the same",
    "people twice, which means the number is too high. Lines that cross --",
    "one group high where another is low -- are what distinct groups look",
    "like. If nothing crosses anywhere, people may differ in degree rather",
    "than in kind, and the other model would say so with far fewer numbers."),

  dimension_choice = paste(
    "Enter the number you want. Nothing is suggested and no number is",
    "pre-filled, because whichever appeared here first would become the",
    "answer. Your choice is recorded with the evidence above it before any",
    "interpretation is offered."),

  search_reading = paste(
    "Now that your choice is recorded, the methodologist will read the",
    "evidence and say what it supports. It cannot change what was logged. If",
    "it changes your mind, enter a different number -- both are recorded, and",
    "that is the honest record of how the decision was reached."),

  final_model = paste(
    "The search compared sizes. This fits the one you chose, properly, and",
    "reports what it does not account for. It is cached, so coming back to",
    "this screen does not refit and the group numbering cannot shift under",
    "your labels."),

  level_pattern = paste(
    "How much of the difference between groups is level and how much is",
    "pattern. Each item's expected answer is put on a 0-to-1 scale first, so a",
    "binary item and a seven-point item contribute the same possible spread.",
    "A ratio well under 1 says the groups differ mainly in how high they",
    "answer overall -- that is a continuum, and a class model is cutting it",
    "into slices rather than finding types. Near or above 1 says the groups",
    "reorder the items, which is structure no single scale holds. This is the",
    "number to look at before reporting groups as though they were kinds of",
    "people."),

  diagnostics = paste(
    "These say how well the model accounts for the answers people gave.",
    "\n\nEvery one of them ranks items or pairs. None is a test, none has a",
    "threshold, and an item at the bottom of a ranking is not thereby a bad",
    "item -- something has to be last. Whether an item belongs is a question",
    "about the question, which is yours and not the model's."),

  measurement_variance = paste(
    "Every number above is an estimate from a sample, so every one of them has",
    "a margin. Getting an honest margin under a complex design means refitting",
    "the whole model many times over -- once for each replicate of the sample",
    "-- and seeing how far the answer moves.",
    "\n\nThis is the reason the tool exists. Standard software computes that",
    "margin as if people had been picked one at a time and independently, and",
    "yours were not. How much difference that makes is a property of this",
    "survey and of the quantity being estimated, not a constant: the report",
    "states the factor it came to on your data. Where it is large, a",
    "difference that looks real under the independence assumption is not.",
    "\n\nWhat to do with it: where two groups' bands overlap on an item, the",
    "data do not separate them on that item, whatever the lines appear to do."),

  refit = paste(
    "You may go back once to remove an item. The limit is not about your",
    "judgement: a model narrating diagnostics will always find a plausible",
    "reason to drop something, and an unbounded loop ends with a battery",
    "selected to fit rather than one that measures.",
    "\n\nWhatever you do, the number of rounds appears in the report. Fit",
    "statistics reported after a search are optimistic, and a reader cannot",
    "discount what they are not told."),

  labels = paste(
    "Names are drafted one at a time from the response pattern and the question",
    "wording. The model sees no respondent records and no statistics -- only",
    "the pattern it is naming.",
    "\n\nNothing computed depends on these. A wrong name is a presentation",
    "error, not a statistical one, and every table stays checkable against the",
    "numbers above it."),

  labels_check = paste(
    "The profile sits beside each name because that is the check: does the",
    "name describe the shape next to it? A name that sounds right and does not",
    "match the picture is the failure this screen exists to catch.",
    "\n\nWhether you edited the names is recorded. Accepting all of them",
    "unchanged is not wrong, but the report will say so, because a reader",
    "should know whether a person looked."),

  scoring = paste(
    "The model was built on people who answered every item. Scoring extends to",
    "people who answered most of them, because item nonresponse is not random",
    "and leaving them out would select on the very thing being measured. The",
    "counts below say how many of each."),

  shares = paste(
    "A check on the scoring, not the figure to report. Assigned share is the",
    "weighted share of respondents placed in each segment. Model prevalence is",
    "the size of the segment in the population, estimated as a parameter of",
    "the model rather than by counting people into bins, and that is the one",
    "that belongs in a write-up: it is on the Segments tab of the report with",
    "its interval.",
    "\n\nThe gap is what to read here. Placing each respondent in their most",
    "likely segment flattens the differences between segments, so the assigned",
    "shares sit closer to even than the prevalences do. A large gap and a low",
    "entropy are the same finding twice: the segments overlap, and assignment",
    "is losing information the model has. That loss is what the corrected",
    "column in the domain tables puts back."),

  quality = paste(
    "How confidently each respondent was placed, against how many items they",
    "answered. Someone who answered everything is placed on more information",
    "than someone who answered half.",
    "\n\nA sharp fall at the low end means the floor is set too low: those",
    "respondents are being assigned on too little, and their scores carry more",
    "error than the rest. That error depends on item nonresponse, so it is not",
    "spread evenly across the sample."),

  domains = paste(
    "The same quantity three ways. Unweighted ignores the survey design.",
    "Design-based accounts for it. Corrected additionally removes the",
    "flattening that assigning people to groups introduces.",
    "\n\nThe gap between the first two is what ignoring the design costs. The",
    "gap between the last two is what the assignment costs. Neither is an",
    "error to be fixed; both are quantities worth knowing before you quote a",
    "number."),

  invariance = paste(
    "One assumption worth knowing before you quote any of this. Comparing",
    "groups takes for granted that each question works the same way in all of",
    "them -- that 'trust the courts' means the same thing to a 25-year-old and",
    "a 65-year-old, and is answered on the same footing.",
    "\n\nThat has not been tested here, and testing it is a separate piece of",
    "work. If an item is understood differently by one group, the difference",
    "you see may be about the question rather than about what it measures. The",
    "two look identical in this table. Where you have reason to suspect it, ask",
    "a methodologist trained in psychometrics."),

  estimator_gap = paste(
    "Read every shift against the design-based standard error underneath it.",
    "A shift well inside that error is not moving anything the data can",
    "resolve, whatever it looks like in the table.",
    "\n\nThe last row is the one to remember: it says how much wider the",
    "honest interval is than the one standard software would have given you.",
    "Where it is around two, a difference that looked significant under the",
    "defaults needs to be twice as large before it really is."),

  resolved = paste(
    "Which pairs of levels actually separate, worked out here rather than by",
    "eye. Each pair is a design-based test on the difference, adjusted for the",
    "number of comparisons within this domain.",
    "\n\nThe tests run on the design-based column deliberately. Assignment",
    "flattens differences, so a pair that separates there separates despite",
    "the flattening, and the corrected column can only widen the gap. A pair",
    "not listed is one the data do not separate -- which is not the same as",
    "saying the groups are alike."),

  report = paste(
    "The report is source material, not a finished argument: tables you can",
    "lift, findings you can quote, and the caveats attached to the numbers",
    "they belong to rather than collected at the back.",
    "\n\nYou also get your survey file back with the new columns added, and",
    "every table as a CSV. The caveats are assembled from what actually",
    "happened in this run, so one that does not apply to you will not be",
    "there."),

  report_save = paste(
    "Saving writes the report exactly as previewed, your survey file with the",
    "new columns added, and every table as a CSV. Nothing has been written",
    "yet.",
    "\n\nThe report is a single HTML file with the figures inside it, so it",
    "can be emailed as one attachment and opens in Word if a Word document is",
    "what someone wants."),

  finished = paste(
    "Two things to carry forward. The delivered file holds the posterior",
    "columns as well as the assignment: cross-tabulating the assignment on its",
    "own puts back the flattening the corrected column removed, and the",
    "variable label in the file says so.",
    "\n\nThe decision log is the record of how this analysis was reached. If",
    "anyone asks why this number of groups rather than another, the answer and",
    "the evidence behind it are both in there.")
)

# One consistent block. Muted rather than styled as an alert, because most of
#   this is orientation and an app that shouts at every step stops being read.

# Colours come from Bootstrap variables rather than fixed hex, so the same
#   markup reads correctly in light and dark without the module knowing which
#   is in use.
help_box <- function(key) {
  txt <- WISE_HELP[[key]]
  if (is.null(txt)) return(NULL)
  shiny::tags$div(
    style = paste("background: var(--bs-secondary-bg);",
                  "border-left: 3px solid var(--bs-border-color);",
                  "color: var(--bs-body-color);",
                  "padding: 8px 12px; margin: 6px 0 12px 0;",
                  "font-size: 90%; white-space: pre-line;"),
    txt)
}

# The model's own voice, distinguished from the app's. Same variables so it
#   follows the theme.
advice_box <- function(...) {
  shiny::tags$div(
    style = paste("background: var(--bs-tertiary-bg);",
                  "border-left: 3px solid var(--bs-primary);",
                  "color: var(--bs-body-color);",
                  "padding: 8px 12px; margin: 12px 0;"),
    ...)
}

# A consequence the analyst should see before they cause it. The fallbacks
#   matter: a fixed background with an inherited foreground is how a panel ends
#   up pale text on a pale block the moment the theme changes underneath it.
warn_box <- function(...) {
  shiny::tags$div(
    style = paste(
      "background: var(--bs-warning-bg-subtle, #fdf6ec);",
      "border-left: 3px solid var(--bs-warning, #d9a441);",
      "color: var(--bs-warning-text-emphasis, var(--bs-body-color));",
      "padding: 8px 12px; margin: 12px 0; font-size: 90%;"),
    ...)
}


# The demonstration folder ------------------------------------------------

# seed_demo_folder() was removed. It copied demo/ out of the repository into a
#   work folder the analyst owns, which existed to work around the repository
#   guard; the guard is gone, there is no demo/ in the repository, and nothing
#   in the app called it. cache_clear() -- its only remaining caller -- is
#   reachable from the app on its own.
