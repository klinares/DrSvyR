# install.R -- set up inteRn with one command. Run once, in RStudio's console:
#
#   source("<path to>/inteRn/install.R")
#
# It (1) installs the few packages inteRn needs, if missing, (2) adds one line
#   to your .Rprofile so inteRn loads every time R starts (your old .Rprofile
#   is backed up first), (3) checks for your API key, and (4) loads inteRn now,
#   so you can use it straight away. Running it again changes nothing.

local({
  # Where this file is.
  frames = rev(sys.frames())
  hit = Filter(function(f) exists("ofile", envir = f, inherits = FALSE) ||
                 exists("fileName", envir = f, inherits = FALSE), frames)
  if (!length(hit)) stop("Run this file with source(\"<path>/install.R\").", call. = FALSE)
  file = get0("ofile", envir = hit[[1]], inherits = FALSE,
              ifnotfound = get0("fileName", envir = hit[[1]], inherits = FALSE))
  home = normalizePath(dirname(file), winslash = "/")
  entry = file.path(home, "inteRn.R")
  say = function(...) cat(..., "\n", sep = "")

  say("\nSetting up inteRn from ", home)

  # 1. Packages.
  need = c("ellmer", "purrr", "rlang", "httpuv", "promises", "later", "jsonlite",
           "commonmark", "lintr", "diffobj", "yaml")
  missing = need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    say("1. Installing: ", paste(missing, collapse = ", "))
    utils::install.packages(missing)
  } else say("1. Packages: all installed.")

  # 2. .Rprofile: the file R reads at startup.
  rprof = Sys.getenv("R_PROFILE_USER", path.expand("~/.Rprofile"))
  line = sprintf('if (interactive()) source("%s")', entry)
  old = if (file.exists(rprof)) readLines(rprof, warn = FALSE) else character(0)
  if (any(grepl("inteRn.R", old, fixed = TRUE))) {
    say("2. Startup: already in ", rprof)
  } else {
    if (length(old)) file.copy(rprof, paste0(rprof, ".before-intern"), overwrite = TRUE)
    writeLines(c(old, "", "# inteRn, the AI coding intern (added by inteRn/install.R)", line), rprof)
    say("2. Startup: added one line to ", rprof,
        if (length(old)) paste0(" (backup: ", basename(rprof), ".before-intern)") else "")
  }

  # 3. The key.
  if (nzchar(Sys.getenv("ANTHROPIC_API_KEY"))) {
    say("3. API key: found.")
  } else {
    say("3. API key: NOT found. Add this line to the file that opens next, save it,",
        "\n   and restart R:   ANTHROPIC_API_KEY=your-key-here")
    renv = path.expand("~/.Renviron")
    if (interactive()) {
      if (!file.exists(renv)) file.create(renv)
      utils::file.edit(renv)
    } else say("   (the file is ", renv, ")")
  }

  # 4. Load it now.
  source(entry)
  say("Done. From now on inteRn loads by itself when R starts.",
      "\nTry it in the console:   ask(\"What can you help me with?\")\n")
})
