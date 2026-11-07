# inteRn.R -- the entry point. An AI coding intern for survey research in R.
#
# Add one line to ~/.Rprofile (usethis::edit_r_profile() opens it):
#
#   if (interactive()) source("<path to>/inteRn/inteRn.R")
#
# What this file does, and nothing else:
#   1. Finds its own folder (or INTERN_HOME, if set).
#   2. Reads config.R, or config.example.R with a note if there is no config.R.
#   3. Sources every file in R/ into one private environment. Those files hold
#      function definitions and constants only.
#   4. Attaches a small environment named "inteRn" holding the handful of
#      functions a user calls, so ls() stays clean and none of the user's
#      objects are overwritten. Sourcing again replaces it.
#
# It is not a package on purpose: a git-tracked folder that each user pulls.
# Nothing in it names a person, a path, a key or a model; those are in config.R.

local({
  # ---- 1. where am I ----------------------------------------------------
  # source() keeps the file name in its frame as `ofile`; RStudio's
  #   debugSource() as `fileName`. INTERN_HOME overrides both.
  home = Sys.getenv("INTERN_HOME")
  if (!nzchar(home)) {
    frames = rev(sys.frames())
    hit = Filter(function(f) exists("ofile", envir = f, inherits = FALSE) ||
                   exists("fileName", envir = f, inherits = FALSE), frames)
    # No %||% here: base R has it only from 4.4.
    file = if (length(hit))
      get0("ofile", envir = hit[[1]], inherits = FALSE,
           ifnotfound = get0("fileName", envir = hit[[1]], inherits = FALSE))
    if (is.null(file)) {
      message("inteRn: could not tell which folder inteRn.R is in. ",
              "Set INTERN_HOME in .Renviron to that folder.")
      return(invisible(NULL))
    }
    home = dirname(file)
  }
  home = normalizePath(home, winslash = "/", mustWork = FALSE)

  # ---- 2. packages ------------------------------------------------------
  need = c("ellmer", "purrr", "rlang")
  missing = need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    message("inteRn: not loaded. Install first: install.packages(c(\"",
            paste(missing, collapse = "\", \""), "\"))")
    return(invisible(NULL))
  }

  # ---- 3. private environment -------------------------------------------
  # Parent is base, so every other function is written pkg::fn(). That keeps
  #   the code working from .Rprofile, before utils and stats are attached,
  #   and stops it picking up a user's object by accident.
  core = new.env(parent = baseenv())
  core$.home = home

  cfg = file.path(home, "config.R")
  if (!file.exists(cfg)) {
    cfg = file.path(home, "config.example.R")
    message("inteRn: no config.R, using config.example.R. Copy it to ",
            "config.R and edit the copy.")
  }
  sys.source(cfg, envir = core)

  files = sort(list.files(file.path(home, "R"), pattern = "[.]R$",
                          full.names = TRUE))
  purrr::walk(files, sys.source, envir = core, keep.source = TRUE)

  problems = core$intern_config_problems()
  if (length(problems))
    message("inteRn: config.R needs attention:\n",
            paste0("  - ", problems, collapse = "\n"))

  # ---- 4. what the user sees --------------------------------------------
  if ("inteRn" %in% search()) detach("inteRn", character.only = TRUE)
  pub = attach(NULL, name = "inteRn", warn.conflicts = FALSE)
  exports = core$INTERN_EXPORTS
  purrr::walk(exports, function(n) assign(n, get(n, envir = core), envir = pub))
  registerS3method("print", "intern_reply", core$print.intern_reply,
                   envir = core)

  if (!isTRUE(getOption("intern.quiet")))
    message("inteRn ready: ask(\"...\"), obj %ask% \"...\", intern_config().")
  invisible(NULL)
})
