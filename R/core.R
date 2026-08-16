# core.R for DrSvyR
# Paths, the repository guard, caching, the decision log, and every line of help text the analyst reads.

# Merged from: 
#   project.R
#   00_project.R
#   logging.R
#   help_text.R

# ---- project -----------------------------------------------------------

# project.R for WISE repo
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

# Requires: fs, digest, rappdirs, purrr, tibble


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
assert_outside_repo <- function(path) {
  if (fs::path_has_parent(fs::path_abs(path), repo_root())) {
    stop("Refusing to write inside the repository: ", path, "\n",
         "Outputs belong in the work folder. If this path came from a config, ",
         "the work folder is probably unset.", call. = FALSE)
  }
  invisible(path)
}


# Section 2 is the work folder. The analyst creates one folder and drops the
#   data file and the technical report into it; everything below is scaffolded
#   rather than required, because a half-built folder tree is a whole category
#   of failure that looks like a bug in the workflow.
#______________________________________________________________________________

WISE_SUBDIRS <- c("data", "docs", "dict", "decisions", "cache", "output")

.wise <- new.env(parent = emptyenv())
.wise$work_dir <- NULL

# Checked before anything is created, so a folder chosen by mistake fails on
#   selection rather than after the first stage has written to it.
scaffold_work_folder <- function(path) {
  path = fs::path_abs(path)

  if (!fs::dir_exists(path))
    stop("No such folder: ", path, call. = FALSE)
  if (fs::path_has_parent(path, repo_root()))
    stop("The work folder cannot sit inside the repository.\n",
         "Choose a folder outside ", repo_root(), call. = FALSE)

  probe = fs::path(path, ".wise_write_probe")
  ok = try(fs::file_create(probe), silent = TRUE)
  if (inherits(ok, "try-error"))
    stop("Cannot write to ", path, ". Choose a folder you own.", call. = FALSE)
  fs::file_delete(probe)

  fs::dir_create(fs::path(path, WISE_SUBDIRS))
  .wise$work_dir <- path
  invisible(path)
}

work_dir <- function() {
  if (is.null(.wise$work_dir))
    stop("No work folder set. Call scaffold_work_folder() first.", call. = FALSE)
  .wise$work_dir
}

# Every path the workflow writes to is built here, so the guard is applied once
#   rather than remembered at each call site.
wise_path <- function(...) {
  assert_outside_repo(fs::path(work_dir(), ...))
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


# Section 3 remembers the folder between sessions, outside the repository so
#   there is nothing repo-adjacent to commit by accident.
#______________________________________________________________________________

.wise_config_file <- function() {
  fs::path(rappdirs::user_config_dir("wise"), "last_work_folder")
}

remember_work_folder <- function(path = work_dir()) {
  fs::dir_create(fs::path_dir(.wise_config_file()))
  writeLines(as.character(path), .wise_config_file())
  invisible(path)
}

# Returns NULL rather than erroring when there is nothing remembered or the
#   folder has since moved, so the app can offer it as a default and fall back
#   to asking.
last_work_folder <- function() {
  f = .wise_config_file()
  if (!fs::file_exists(f)) return(NULL)
  p = readLines(f, warn = FALSE)[1]
  if (!length(p) || !nzchar(p) || !fs::dir_exists(p)) NULL else p
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
#   app when the analyst finishes an arm.
cache_clear <- function(stage = NULL) {
  files = fs::dir_ls(wise_path("cache"), glob = "*.rds")
  if (!is.null(stage))
    files = files[fs::path_file(files) |> startsWith(paste0(stage, "_"))]
  fs::file_delete(files)
  invisible(length(files))
}

# ---- logging -----------------------------------------------------------

# logging.R for WISE repo
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
        "Written by WISE as decisions are made. Do not edit; it is the record ",
        "of what was chosen and why.\n", sep = "", file = f)
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

# help_text.R for WISE repo
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

  arm_intro = paste(
    "Two different models answer two different questions about the same",
    "battery. Which one fits is a property of the data, not a preference,",
    "so say what you expect and then check it against the evidence."),

  arm_choice = paste(
    "Distinct groups: people fall into types that answer in different",
    "patterns. One group might agree with items A and B and reject C, while",
    "another does the reverse. The result is a group label for each person.",
    "\n\nDegrees of one thing: everyone sits somewhere on a single scale, from",
    "low to high. People differ in how much, not in which. The result is a",
    "score for each person."),

  arm_evidence = paste(
    "The eigenvalues describe how much of the pattern in the answers a single",
    "underlying scale can account for. A large first value relative to the",
    "second points toward one continuum. Values closer together point toward",
    "several distinct patterns. Mixed response formats across unrelated topics",
    "also point away from a single scale. There is no threshold that settles",
    "it, which is why the next step is to ask."),

  arm_ask = paste(
    "The methodologist reads the numbers above and your stated goal, and gives",
    "an opinion once. It cannot see your data and it does not decide. Whatever",
    "you choose is what runs, and a disagreement is recorded in the report."),

  estimator = paste(
    "Your questions have ordered answer categories, and there are two ways to",
    "treat them.",
    "\n\nAs ordered categories is the more exact description of what the",
    "respondent actually did. Its cost is coverage: the method can only give a",
    "score to someone who answered every question in the battery, so anyone",
    "who skipped one gets nothing.",
    "\n\nAs a continuous scale treats the rungs of the ladder as evenly spaced,",
    "which they are not quite. Its benefit is that a respondent who answered",
    "most of the questions can still be scored from those. Since people who",
    "skip questions are not a random slice of the sample, that coverage is",
    "worth something.",
    "\n\nThis option only appears when the scales have five or more points. On",
    "a yes/no question the approximation would not be defensible."),

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

  diagnostics = paste(
    "These say how well the model accounts for the answers people gave.",
    "\n\nEvery one of them ranks items or pairs. None is a test, none has a",
    "threshold, and an item at the bottom of a ranking is not thereby a bad",
    "item -- something has to be last. Whether an item belongs is a question",
    "about the question, which is yours and not the model's."),

  cfa_diagram = paste(
    "The measurement model as a picture. Each factor is on the left, each",
    "question on the right, and a line joins them when the question tracks",
    "that factor. Thicker and darker means it tracks it more strongly.",
    "\n\nWhat to look for: a question with only thin lines is not measuring",
    "much of anything here, and a question with thick lines to two factors is",
    "measuring both, which usually means it is asking about two things.",
    "\n\nThe curve on the left joining the factors is how far the two things",
    "they measure travel together. Near zero means they are separate; near one",
    "means they are close enough that one factor might describe both."),

  measurement_variance = paste(
    "Every number above is an estimate from a sample, so every one of them has",
    "a margin. Getting an honest margin under a complex design means refitting",
    "the whole model many times over -- once for each replicate of the sample",
    "-- and seeing how far the answer moves.",
    "\n\nThis is the reason the tool exists. Standard software would report a",
    "margin roughly half this size, because it assumes people were picked one",
    "at a time and independently, and yours were not. Differences that look",
    "real under that assumption often are not.",
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
    "The size of each group, counted two ways. Unweighted is the share of",
    "respondents. Weighted is the share of the population they represent. A",
    "gap between them means the groups are not evenly spread across the design",
    "-- which is the whole reason the weights exist."),

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

  factor_scale = paste(
    "A factor score has no natural units, so it is centred: zero is the",
    "average across the population, positive is above it, negative is below.",
    "Half the groups will be negative and that carries no bad news.",
    "\n\nWhat matters is the distance between groups, not the sign. Read a",
    "difference of 0.2 as a fifth of a standard deviation, and read it against",
    "the interval around it before treating it as real."),

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
    "Saving writes the Word document exactly as previewed, your survey file",
    "with the new columns added, and every table as a CSV. Nothing has been",
    "written yet."),

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

# demo/ ships with the tool so a live demonstration runs from a clean clone.
#   It is read from and never written to. Rather than carving an exception
#   into the repository guard, the demonstration material is copied out into
#   an ordinary work folder the analyst owns. One rule about the boundary with
#   no exceptions to reason about, a working tree that stays clean, and -- the
#   part that actually matters -- every demonstration starts from an empty
#   cache instead of quietly replaying the fits from the last one.
seed_demo_folder <- function(path = fs::path(fs::path_home(), "DrSvyR-demo")) {
  src = fs::path(repo_root(), "demo")
  if (!fs::dir_exists(src))
    stop("No demo/ folder in this repository.", call. = FALSE)

  files = fs::dir_ls(src, recurse = TRUE, type = "file",
                     regexp = "[.](sav|dta|pdf)$")
  if (!length(files))
    stop("demo/ contains no .sav, .dta or .pdf to copy.", call. = FALSE)

  path = fs::path_abs(path)
  fs::dir_create(path)

  # The guard still applies. Naming a path inside the repository here fails
  #   exactly as it would for an analyst's own data, which is the point of
  #   not making demo/ a special case.
  scaffold_work_folder(path)

  # Routed the way an analyst would have dropped them in, so the folder the
  #   demonstration runs from is the same shape as a real one.
  purrr::walk(files, function(f)
    fs::file_copy(
      f,
      fs::path(path,
               if (fs::path_ext(f) %in% c("sav", "dta")) "data" else "docs",
               fs::path_file(f)),
      overwrite = TRUE))

  n = cache_clear()

  message("Demo folder ready: ", path,
          "\n  copied ", length(files), " file(s) out of demo/",
          if (n) paste0(", cleared ", n, " cached fit(s)") else "",
          "\n  demo/ itself was not written to.")
  invisible(path)
}
