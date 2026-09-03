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

# The engine calls survey, dplyr, purrr and the rest by bare name, so those
#   packages have to be attached here or every one of their functions reads as
#   a missing name. The list is taken from app.R rather than repeated, so a
#   library() added there does not quietly turn that package's functions into
#   forty findings in this report.

# Parsed rather than grepped. app.R's own comment explains why tidyverse is
#   deliberately NOT attached, and a regex over the text obediently found
#   library(tidyverse) inside that sentence.
libs <- if (file.exists("app.R")) {
  unique(unlist(lapply(as.list(parse("app.R")), function(x)
    if (is.call(x) && identical(as.character(x[[1]])[1], "library"))
      as.character(x[[2]])[1] else NULL)))
} else character(0)

absent <- libs[!vapply(libs, requireNamespace, logical(1), quietly = TRUE)]
if (length(absent))
  message("Not installed here, so their functions will appear below as ",
          "undefined names: ", paste(absent, collapse = ", "),
          "\n  Run setup.R first, or read past them.")

invisible(lapply(setdiff(libs, absent), function(p)
  suppressPackageStartupMessages(library(p, character.only = TRUE))))

# Source into a clean environment whose parent is the search path, so anything
#   the packages export resolves and anything only R/ should define does not.
env <- new.env(parent = globalenv())
invisible(lapply(files, sys.source, envir = env))

fns <- Filter(function(n) is.function(get(n, envir = env)), ls(env, all.names = TRUE))

# codetools says two different things and they need different treatment.

#   "no visible global function definition for 'X'"  -- X was CALLED. A
#      data-masked column is never called, so there is no noise here at all and
#      every one of these is reported.

#   "no visible binding for global variable 'X'"     -- X was READ. This is
#      where the column names live, and they cannot be told apart from a
#      genuinely missing object, so these are filtered.

# The previous version filtered both against a hand-written list of the
#   project's function prefixes. That list rotted exactly as such lists do: by
#   the time it was checked, 116 of the 222 names defined in R/ did not match
#   it -- every mod_*() module, work_dir(), parse_json_block(). A deleted
#   function was filed under "further notes" and this script exited 0.
seen_fn <- new.env(parent = emptyenv())
seen_var <- new.env(parent = emptyenv())
invisible(lapply(fns, function(f)
  codetools::checkUsage(
    get(f, envir = env), name = f,
    report = function(msg) {
      if (grepl("no visible global function", msg))
        assign(msg, TRUE, envir = seen_fn)
      else if (grepl("no visible binding for global variable", msg))
        assign(msg, TRUE, envir = seen_var)
    },
    all = FALSE, suppressLocal = TRUE)))

name_of <- function(m)
  sub(".*(variable|function) [‘'\"]([^’'\"]+).*", "\\2", m)

# A constant is the case this script was written for: BOUNDARY_TOL was deleted,
#   nothing referenced it at parse time, and it surfaced three screens later.
#   ALL CAPS is what a constant looks like here and is not what a survey column
#   looks like.
var_msgs <- ls(seen_var)
var_nm <- if (length(var_msgs)) {
  vapply(var_msgs, name_of, character(1))
} else character(0)
var_real <- grepl("^[.]?[A-Z][A-Z0-9_.]*$", var_nm)

msgs <- c(ls(seen_fn), var_msgs[var_real])
real <- rep(TRUE, length(msgs))

cat("names used but not defined in R/ and not exported by a package\n")
cat("------------------------------------------------------------\n")
if (any(real)) {
  cat(paste0("  ", msgs[real], "\n"), sep = "")
  cat("\n", sum(real), " to look at.\n", sep = "")
} else {
  cat("  none.\n")
}

other <- var_msgs[!var_real]
cat("\n", length(other),
    " further notes, almost all data-masked column names.\n", sep = "")
cat("Set VERBOSE <- TRUE before sourcing to see them.\n")
if (isTRUE(get0("VERBOSE", ifnotfound = FALSE)))
  cat(paste0("  ", other, "\n"), sep = "")

invisible(if (any(real)) stop("Undefined names above.", call. = FALSE))