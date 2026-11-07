# config_load.R -- checks INTERN_LLM (config.R) and resolves its folders.
# Function definitions and constants only.

`%||%` <- function(x, y) if (is.null(x)) y else x

# What the user sees after sourcing inteRn.R. Everything else stays private.
INTERN_EXPORTS <- c("ask", "%ask%", "open_intern", "close_intern", "intern_reset",
                    "intern_source_skill", "intern_complete", "reflex_add",
                    "intern_config", "intern_help")

# Per-session state: the conversation, a key typed in "analyst" mode, and the
#   function that asks the user to approve a tool call. An environment, so a
#   stray options() call cannot reset it.
.state <- new.env(parent = emptyenv())

is_string <- function(x) is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
is_count  <- function(x) is.numeric(x) && length(x) == 1L && !is.na(x) && x >= 1

# One check per field: a test and what to say when it fails.
INTERN_CHECKS <- list(
  base_url    = list(is_string, "a URL in quotes"),
  key_var     = list(is_string, "the NAME of the environment variable holding the key"),
  pm          = list(is_string, "a model ID in quotes"),
  worker      = list(is_string, "a model ID in quotes"),
  pm_fallback = list(function(x) is.null(x) || is_string(x), "NULL or a model ID"),
  key_source  = list(function(x) is_string(x) && x %in% c("server", "analyst"),
                     "\"server\" or \"analyst\""),
  timeout     = list(is_count, "a number of seconds"),
  max_tokens  = list(is_count, "a whole number"),
  temperature = list(function(x) is.null(x) || (is.numeric(x) && length(x) == 1L),
                     "NULL or a number"),
  cache       = list(function(x) is_string(x) && x %in% c("5m", "1h", "none"),
                     "\"5m\", \"1h\" or \"none\""),
  skills_dir  = list(function(x) is.null(x) || is_string(x), "NULL or a folder path"),
  allow_dirs  = list(function(x) is.character(x) && length(x) >= 1L && all(nzchar(x)),
                     "one or more folder paths"),
  suppress_n  = list(is_count, "a whole number, 1 or more"),
  lint        = list(function(x) is.null(x) || isTRUE(x) || isFALSE(x), "TRUE or FALSE"),
  lint_retries = list(function(x) is.null(x) || (is.numeric(x) && length(x) == 1L && x >= 0),
                      "a whole number, 0 or more"))

# Fields added after the first release: a config.R without them still works.
INTERN_OPTIONAL <- c("pm_fallback", "temperature", "skills_dir", "lint", "lint_retries")

# Problems as sentences; character(0) when the config is usable.
intern_config_problems <- function(cfg = get0("INTERN_LLM", inherits = TRUE)) {
  if (!is.list(cfg)) return("config.R must define a list called INTERN_LLM.")
  bad = purrr::imap(INTERN_CHECKS, function(chk, field) {
    if (!field %in% names(cfg) && !field %in% INTERN_OPTIONAL)
      return(paste0("`", field, "` is missing; it should be ", chk[[2]], "."))
    if (!chk[[1]](cfg[[field]]))
      return(paste0("`", field, "` should be ", chk[[2]], "."))
    NULL
  })
  # A key pasted where its variable name belongs would be sent to no one, but
  #   it would sit in a file that gets copied around.
  leak = if (is_string(cfg$key_var) && grepl("^(sk-|sk_|ghp_|Bearer )", cfg$key_var))
    "`key_var` looks like a key. Put the key in .Renviron and its variable name here."
  c(unlist(purrr::compact(bad), use.names = FALSE), leak)
}

intern_model <- function(role = "pm") {
  m = INTERN_LLM[[role]]
  if (!is_string(m)) stop("No model configured for role '", role, "' in config.R.",
                          call. = FALSE)
  m
}

# The skills folder: as configured, or ai_skills next to the inteRn folder.
intern_skills_dir <- function()
  normalizePath(INTERN_LLM$skills_dir %||% file.path(dirname(.home), "ai_skills"),
                winslash = "/", mustWork = FALSE)

# allow_dirs, resolved now: "." is whatever the working directory is at the
#   time of the call.
intern_allow_dirs <- function()
  unique(normalizePath(INTERN_LLM$allow_dirs, winslash = "/", mustWork = FALSE))

# Whether a key would be found, without making a call or showing the key.
intern_key_status <- function() {
  if (identical(INTERN_LLM$key_source, "analyst"))
    return(if (is.null(.state$key)) "asked for on first use (analyst mode)"
           else "typed this session (analyst mode)")
  if (nzchar(Sys.getenv(INTERN_LLM$key_var))) paste0(INTERN_LLM$key_var, " is set")
  else paste0(INTERN_LLM$key_var, " is NOT set: add it to .Renviron and restart R")
}

# Exported. The settings in use, with the key reported as set or not, never
#   shown.
intern_config <- function() {
  cfg = INTERN_LLM
  shown = purrr::imap_chr(cfg, function(v, k)
    sprintf("  %-12s %s", k, if (is.null(v)) "NULL" else paste(v, collapse = ", ")))
  problems = intern_config_problems(cfg)
  cat("inteRn settings (", file.path(.home, if (file.exists(file.path(.home, "config.R")))
        "config.R" else "config.example.R"), ")\n",
      paste(shown, collapse = "\n"), "\n\n",
      "  key          ", intern_key_status(), "\n",
      "  skills       ", intern_skills_dir(),
      if (!dir.exists(intern_skills_dir())) " (not found)", "\n",
      "  may read and write in: ", paste(intern_allow_dirs(), collapse = "; "), "\n",
      if (length(problems)) paste0("\nProblems:\n", paste0("  - ", problems, collapse = "\n"), "\n"),
      sep = "")
  invisible(cfg)
}
