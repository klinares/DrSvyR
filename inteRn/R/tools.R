# tools.R -- the tools the model may call, as ellmer::tool() definitions.
#
# Read-only tools return metadata or suppressed aggregates (metadata.R).
#   Tools that change something -- write_file, run_code -- show the user what
#   they will do and ask first (with_approval(), fs_guard.R), in the console
#   or in the Viewer depending on where the turn started. A refusal goes back
#   to the model as a plain result that says so, which works the same whether
#   the tool returned a value or a promise.
# Function definitions and constants only.

MAX_SOURCE_LINES <- 400L
MAX_SHARED_CHARS <- 4000L
MAX_LIST_FILES   <- 200L

# ---- function source ---------------------------------------------------

get_function_source_tool <- function(name) {
  fn = tryCatch({
    if (grepl(":::?", name)) {
      parts = strsplit(name, ":::?")[[1]]
      get(parts[2], envir = asNamespace(parts[1]), inherits = FALSE)
    } else get(name, envir = globalenv(), mode = "function")
  }, error = function(e) NULL)
  if (!is.function(fn)) return(paste0("No function called `", name, "` was found."))
  src = deparse(fn, control = "useSource")
  scrub_text(c(utils::head(src, MAX_SOURCE_LINES),
               if (length(src) > MAX_SOURCE_LINES)
                 paste0("# ... (", length(src) - MAX_SOURCE_LINES, " more lines)")))
}

# ---- files -------------------------------------------------------------

list_files_tool <- function(dir = ".") {
  d = intern_check_path(file.path(dir, "."), "write")   # a folder: same rules as writing
  d = dirname(d)
  files = list.files(d, recursive = TRUE, all.files = FALSE)
  files = files[!grepl("(^|/)(\\.git|renv|\\.Rproj\\.user)/", files)]
  if (!length(files)) return("No files there.")
  c(paste0(length(files), " files", if (length(files) > MAX_LIST_FILES)
             paste0(", first ", MAX_LIST_FILES, " shown"), ":"),
    utils::head(files, MAX_LIST_FILES)) |> paste(collapse = "\n")
}

# Credentials are scrubbed; paths are not, because the model may edit this
#   text and write it back (see write_file_tool).
read_file_tool <- function(path) {
  p = intern_check_path(path, "read")
  if (!file.exists(p)) return(paste0("There is no file '", path, "'."))
  if (file.size(p) > INTERN_MAX_READ)
    return(paste0("'", basename(p), "' is larger than ", INTERN_MAX_READ / 1024,
                  " KB; inteRn does not read files that size."))
  lines = readLines(p, warn = FALSE, encoding = "UTF-8")
  if (is_data_dict(p, lines)) return(redacted_dict_text(p))
  paste0("Contents of ", basename(p), ":\n", scrub_text(lines, paths = FALSE))
}

# A data-dict.yaml holds real values in `examples` and `range` (put there by
#   `data-dict draft`). The model gets it without them, and cannot overwrite
#   it: a rewrite from the redacted text would lose them.
is_data_dict <- function(p, lines = NULL) {
  ext = tolower(tools::file_ext(p))
  if (!ext %in% c("yaml", "yml")) return(FALSE)
  if (grepl("^data-dict", tolower(basename(p)))) return(TRUE)
  head = if (is.null(lines) && file.exists(p)) readLines(p, n = 5, warn = FALSE) else utils::head(lines, 5)
  any(grepl("^\\$version:", head))
}

redacted_dict_text <- function(p) {
  if (!requireNamespace("yaml", quietly = TRUE))
    return("This is a data dictionary; inteRn needs the yaml package to show it without its values.")
  d = yaml::read_yaml(p)
  d$tables = purrr::map(d$tables, function(t) {
    t$source = NULL
    t$columns = purrr::map(t$columns, function(col) {
      col[c("examples", "range")] = NULL
      col
    })
    t
  })
  paste0("Contents of ", basename(p), " (examples, ranges and source removed: they hold ",
         "values from the data):\n", scrub_text(yaml::as.yaml(d), paths = FALSE))
}

write_file_tool <- function(path, content) {
  p = intern_check_path(path, "write")
  if (is_data_dict(p) || is_data_dict(p, strsplit(content, "\r?\n")[[1]]))
    return(paste("Not written: inteRn does not overwrite a data dictionary, because the",
                 "version you can see has its examples and ranges removed. Tell the user",
                 "what to change, or re-run codebook_draft()."))
  if (has_scrub_marks(content))
    return(paste("Not written: the content contains a <redacted>, <path> or <email>",
                 "placeholder, which would replace the real value in the file.",
                 "Leave those lines out or ask the user for the value."))
  new = strsplit(content, "\r?\n")[[1]]
  old = if (file.exists(p)) readLines(p, warn = FALSE, encoding = "UTF-8") else character(0)
  with_approval(
    paste0("inteRn wants to ", if (length(old)) "change " else "create ", basename(p), "."),
    c("Write it", "Don't write it"),
    detail = diff_text(old, new, basename(p)),
    show = function() show_diff(old, new, basename(p)),
    then = function(choice) {
      if (!identical(choice, "Write it"))
        return(REFUSED("write this file"))
      con = file(p, open = "w", encoding = "UTF-8")
      on.exit(close(con), add = TRUE)
      writeLines(new, con)
      sprintf("Wrote %s (%d lines).", basename(p), length(new))
    })
}

# What the model is told when the user says no.
REFUSED <- function(what)
  paste0("The user chose not to ", what, ". Do not try again in another way; ",
         "ask what they would like instead.")

# ---- running code ------------------------------------------------------

# Class and shape of every workspace object, to report what code changed
#   without looking at values.
workspace_shape <- function(env = globalenv())
  purrr::map_chr(rlang::set_names(ls(env)), function(n) {
    x = get(n, envir = env, inherits = FALSE)
    paste0("<", class(x)[1], "> ", dims_text(x))
  })

shape_changes <- function(before, after) {
  new = setdiff(names(after), names(before))
  gone = setdiff(names(before), names(after))
  both = intersect(names(before), names(after))
  moved = both[before[both] != after[both]]
  c(if (length(new)) paste0("Created: ", paste(new, after[new], collapse = "; ")),
    if (length(gone)) paste0("Removed: ", paste(gone, collapse = ", ")),
    if (length(moved)) paste0("Changed shape: ", paste(moved, after[moved], collapse = "; ")))
}

# The user sees the output. The model sees whether it ran, the error, any
#   warnings, and what objects appeared or changed shape -- and the output
#   itself only if the user chose to share it.
run_code_tool <- function(code) {
  exprs = tryCatch(parse(text = code, keep.source = FALSE), error = function(e) e)
  if (inherits(exprs, "error"))
    return(paste("The code does not parse:", scrub_text(conditionMessage(exprs))))
  share = RUN_SHARE
  with_approval("inteRn wants to run this in your session:",
                c("Run", share, "Don't run"), detail = code,
                then = function(choice) {
                  if (!choice %in% c("Run", share)) return(REFUSED("run this code"))
                  run_approved(exprs, share = identical(choice, share))
                })
}

RUN_SHARE <- "Run and share the output with inteRn"

run_approved <- function(exprs, share) {
  before = workspace_shape()
  warns = character(0)
  res = NULL
  out = utils::capture.output(
    res <- tryCatch(
      withCallingHandlers({
        source(exprs = exprs, local = globalenv(), echo = FALSE, print.eval = TRUE)
        NULL
      }, warning = function(w) {
        warns <<- c(warns, conditionMessage(w))
        invokeRestart("muffleWarning")
      }),
      error = function(e) e))
  if (length(out)) cat(out, sep = "\n")
  if (length(warns)) message("Warnings:\n", paste0("  ", warns, collapse = "\n"))
  # The user sees the output in the Viewer too. It stays on this machine:
  #   the page is served from 127.0.0.1 and nothing here goes to the model.
  if (identical(.state$channel, "viewer"))
    viewer_send(list(type = "output",
                     text = paste(c(out, if (length(warns)) paste("Warning:", warns),
                                    if (inherits(res, "error")) paste("Error:", conditionMessage(res))),
                                  collapse = "\n")))

  status = if (inherits(res, "error"))
    paste("Error:", substr(scrub_text(conditionMessage(res)), 1, 300))
  else "Ran without error."
  paste(c(
    status,
    if (length(warns)) paste0(length(warns), " warning(s): ",
                              substr(scrub_text(utils::head(warns, 3)), 1, 300)),
    shape_changes(before, workspace_shape()),
    if (share)
      paste0("Output, shared by the user:\n",
             substr(scrub_text(out), 1, MAX_SHARED_CHARS))
    else "The printed output was shown to the user and not shared with you."),
    collapse = "\n")
}

# ---- registry ----------------------------------------------------------

intern_tools <- function() list(
  ellmer::tool(
    function() env_summary(),
    name = "env_summary",
    description = paste("List the objects in the user's R workspace with their class and",
                        "dimensions. No values."),
    arguments = list()),
  ellmer::tool(
    function(name) describe_object(name),
    name = "describe_object",
    description = paste("Structure of one workspace object: class, dimensions, column names",
                        "and types, variable labels, factor levels and value labels; for a",
                        "survey design, its call, strata and PSU counts. No values."),
    arguments = list(name = ellmer::type_string("Name of the object in the workspace."))),
  ellmer::tool(
    function(name) profile_object(name),
    name = "profile_object",
    description = paste("Unweighted aggregates for each column of a data frame or survey",
                        "design: valid and missing counts, frequency tables, mean, sd and",
                        "quartiles. Small counts are suppressed; min and max are never shown."),
    arguments = list(name = ellmer::type_string("Name of the data frame or design."))),
  ellmer::tool(
    function(name) get_function_source_tool(name),
    name = "get_function_source",
    description = paste("Source code of a function in the session, or of a package function",
                        "written pkg::fn. Credentials and paths are removed."),
    arguments = list(name = ellmer::type_string("Function name, or pkg::fn."))),
  ellmer::tool(
    function(dir = ".") list_files_tool(dir),
    name = "list_files",
    description = "File names (not contents) in an allowed folder, recursively.",
    arguments = list(dir = ellmer::type_string(
      "Folder, relative to the working directory. Default '.'.", required = FALSE))),
  ellmer::tool(
    function(path) read_file_tool(path),
    name = "read_file",
    description = paste("Read a code or text file (R, Quarto, markdown, YAML) in an allowed",
                        "folder. Data files are refused."),
    arguments = list(path = ellmer::type_string("File path, relative to the working directory."))),
  ellmer::tool(
    function(path, content) write_file_tool(path, content),
    name = "write_file",
    description = paste("Create or replace a file in an allowed folder with the full new",
                        "content. The user sees a diff and must approve."),
    arguments = list(
      path = ellmer::type_string("File path, relative to the working directory."),
      content = ellmer::type_string("The complete new file content."))),
  ellmer::tool(
    function(name, file = NULL) load_skill_tool(name, file),
    name = "load_skill",
    description = paste("Load a shared skill's instructions by name (see the Skills list),",
                        "or one file inside it, such as references/examples.md."),
    arguments = list(
      name = ellmer::type_string("Skill name."),
      file = ellmer::type_string("Optional file inside the skill folder.", required = FALSE))),
  ellmer::tool(
    function(code) run_code_tool(code),
    name = "run_code",
    description = paste("Run R code in the user's global environment after they approve it.",
                        "You get back success or the error and which objects changed; the",
                        "printed output only if the user shares it."),
    arguments = list(code = ellmer::type_string("R code to run."))))
