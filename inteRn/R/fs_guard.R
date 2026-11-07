# fs_guard.R -- which files the intern may read or write, and how a user
#   approves a tool call. Function definitions and constants only.

# Data files are never read, even inside allow_dirs: microdata does not go to
#   the API. Code, Quarto, markdown and YAML are fine.
INTERN_DATA_EXT <- c("csv", "tsv", "gz", "zip", "sav", "zsav", "por",
                     "dta", "sas7bdat", "xpt", "rds", "rda", "rdata", "parquet",
                     "feather", "arrow", "xlsx", "xls", "ods", "sqlite", "db",
                     "duckdb", "json", "jsonl", "ndjson", "dat",
                     # rendered reports can print rows of data
                     "html", "htm", "pdf", "docx")

# Files that hold keys or history, never read or written.
INTERN_SECRET_FILES <- c(".renviron", ".rprofile", ".env", ".rhistory",
                         ".netrc", ".git-credentials", "id_rsa", "id_ed25519")

INTERN_MAX_READ <- 200 * 1024    # bytes

on_windows <- function() identical(.Platform$OS.type, "windows")

# The absolute form of a path whose parent folder exists. normalizePath()
#   cannot be trusted on a file that does not exist yet, so the parent is
#   resolved (which also resolves "..") and the file name put back.
resolve_path <- function(path) {
  parent = dirname(path)
  if (!dir.exists(parent)) stop("The folder ", parent, " does not exist.", call. = FALSE)
  file.path(normalizePath(parent, winslash = "/", mustWork = TRUE), basename(path))
}

inside <- function(path, dirs) {
  norm = function(x) if (on_windows()) tolower(x) else x
  p = norm(path)
  any(purrr::map_lgl(norm(sub("/+$", "", dirs)), function(d) startsWith(p, paste0(d, "/"))))
}

# The resolved path if the intern may use it, else an error that says why.
#   The reason goes back to the model, so it names no absolute path.
intern_check_path <- function(path, mode = c("read", "write")) {
  mode = match.arg(mode)
  if (!is_string(path)) stop("No path given.", call. = FALSE)
  p = resolve_path(path)
  name = tolower(basename(p))
  if (!inside(p, intern_allow_dirs()))
    stop("'", basename(p), "' is outside the folders inteRn may use (allow_dirs in config.R).",
         call. = FALSE)
  if (name %in% INTERN_SECRET_FILES || grepl("/\\.git/", p))
    stop("'", basename(p), "' may hold keys or history; inteRn does not touch it.",
         call. = FALSE)
  if (mode == "read" && tools::file_ext(name) %in% INTERN_DATA_EXT)
    stop("'", basename(p), "' looks like a data file. Data never goes to the model; ",
         "describe the object in R instead (describe_object).", call. = FALSE)
  p
}

# ---- approvals ---------------------------------------------------------

# Every tool call that changes something asks first. The last choice is
#   always the refusal, and it is what happens when nobody can be asked.

# Ask, then carry on with then(choice). In a turn that started in the Viewer
#   the question goes to the Viewer and this returns a promise: ellmer awaits
#   a tool's promise, so the console stays free while the user decides. In a
#   console turn (ask()) it asks in the console and returns the value.
#   `show` prints the detail richly in the console (a coloured diff);
#   `detail` is the plain text the Viewer shows.
with_approval <- function(what, choices, then, detail = NULL, show = NULL) {
  if (identical(.state$channel, "viewer") && !is.null(.state$ws))
    return(promises::then(viewer_ask(what, choices, detail), then))
  if (is.function(show)) show() else if (length(detail)) cat("
", detail, sep = "
")
  then(intern_approve(what, choices))
}

# The console question. Tests swap in .state$approver.
intern_approve <- function(what, choices = c("Yes", "No")) {
  approver = .state$approver %||% console_approver
  approver(what, choices)
}

# Non-interactive sessions (tests) refuse unless the option
#   intern.auto_approve names one of the choices.
console_approver <- function(what, choices) {
  refuse = choices[length(choices)]
  if (!interactive()) {
    auto = getOption("intern.auto_approve")
    return(if (is_string(auto) && auto %in% choices) auto else refuse)
  }
  cat("
", what, "
", sep = "")
  i = utils::menu(choices, title = "inteRn asks:")
  if (i == 0L) refuse else choices[i]
}

# ---- diffs -------------------------------------------------------------

diff_banners <- function(label) list(tar.banner = paste(label, "(now)"),
                                     cur.banner = paste(label, "(proposed)"))

# For the console: diffobj in colour if installed, else the new text.
show_diff <- function(old, new, label) {
  if (requireNamespace("diffobj", quietly = TRUE)) {
    b = diff_banners(label)
    print(diffobj::diffChr(old, new, mode = "unified", pager = "off",
                           tar.banner = b$tar.banner, cur.banner = b$cur.banner))
  } else {
    cat(diff_text(old, new, label), sep = "
")
  }
  invisible(NULL)
}

# For the Viewer: the same diff as plain lines.
diff_text <- function(old, new, label) {
  if (!requireNamespace("diffobj", quietly = TRUE))
    return(c(paste("---", label, if (length(old)) "(replacing the current file)" else "(new file)"),
             new))
  b = diff_banners(label)
  as.character(diffobj::diffChr(old, new, format = "raw", mode = "unified", pager = "off",
                                tar.banner = b$tar.banner, cur.banner = b$cur.banner))
}
