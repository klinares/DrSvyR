# check_globals.R for DrSvyR
# Every name the code in R/ uses that nothing in R/ defines and no attached
# package exports. This is the check that would have caught BOUNDARY_TOL going
# missing before the app was ever started: a deleted constant is invisible to
# parse(), invisible to a call-graph walk over functions, and shows up only
# when the one line that reads it happens to run.
#
# Run from the repository root:  source("check_globals.R")

if (!requireNamespace("codetools", quietly = TRUE))
  stop("codetools is needed. It ships with R.", call. = FALSE)

files <- list.files("R", pattern = "[.][Rr]$", full.names = TRUE)
if (!length(files)) stop("No R/ folder here. Run from the repository root.",
                         call. = FALSE)

# This script sources R/. A copy of it left in R/ would therefore source
#   itself, and so would any other script put there -- which is exactly how
#   the app came to die at startup with "evaluation nested too deeply".
#   Refused here rather than recursed into.
runs <- vapply(files, function(f)
  sum(!vapply(as.list(parse(f)), function(x)
    is.call(x) && as.character(x[[1]])[1] %in% c("<-", "=", "<<-"),
    logical(1))), integer(1))
if (any(runs > 0L))
  stop("These are scripts, not definition files, and do not belong in R/:\n  ",
       paste(names(runs)[runs > 0L], collapse = "\n  "),
       "\nMove them to the repository root.", call. = FALSE)

# Source into a clean environment whose parent is the search path, so anything
#   the packages export resolves and anything only R/ should define does not.
env <- new.env(parent = globalenv())
invisible(lapply(files, sys.source, envir = env))

fns <- Filter(function(n) is.function(get(n, envir = env)), ls(env, all.names = TRUE))

seen <- new.env(parent = emptyenv())
invisible(lapply(fns, function(f)
  codetools::checkUsage(
    get(f, envir = env), name = f,
    report = function(msg) {
      if (grepl("no visible (binding for global variable|global function)", msg))
        assign(msg, TRUE, envir = seen)
    },
    all = FALSE, suppressLocal = TRUE)))

msgs <- ls(seen)

# Data-masked columns are the noise here: dplyr verbs reference column names
#   that are not objects, and codetools cannot tell those from a real missing
#   symbol. Anything ALL_CAPS or matching the project's own prefixes is worth
#   reading; the rest almost always is not.
name_of <- function(m) sub(".*variable [‘'\"]([^’'\"]+).*", "\\1", m)
nm <- vapply(msgs, name_of, character(1))

PREFIX <- paste0("^(wise_|llm_|prompt_|persona_|rules_|check_|fit_|search_|",
                 "score_|domain|report_|plot_|build_|format_|item_|design_|",
                 "em_|make_|share_|bch_|predict_|profile_|entropy_|df_k|",
                 "align_|posterior_|replicate_|start_|in_blocks|cached|",
                 "log_|read_|write_|label_|n_verb|blk|html_|id_key)")
real <- grepl("^[A-Z][A-Z0-9_]+$", nm) | grepl(PREFIX, nm, perl = TRUE)

cat("names used but not defined in R/ and not exported by a package\n")
cat("------------------------------------------------------------\n")
if (any(real)) {
  cat(paste0("  ", msgs[real], "\n"), sep = "")
  cat("\n", sum(real), " to look at.\n", sep = "")
} else {
  cat("  none.\n")
}

other <- msgs[!real]
cat("\n", length(other),
    " further notes, almost all data-masked column names.\n", sep = "")
cat("Set VERBOSE <- TRUE before sourcing to see them.\n")
if (isTRUE(get0("VERBOSE", ifnotfound = FALSE)))
  cat(paste0("  ", other, "\n"), sep = "")

invisible(if (any(real)) stop("Undefined names above.", call. = FALSE))
