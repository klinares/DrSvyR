# Mutation runs for the Phase 11 Part A checks (tests/smoke.R, the part between `>>> 11A begin` and `<<< 11A end`). No model call.
#   Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_11A.R                 every mutation
#     Rscript --no-init-file tests/mutate_11A.R M06 M09         only these
# What it does: loads the app as Connect does, runs the 11A block once on the real code (the baseline: every check must pass), then, for each
#   mutation, sources a changed copy of R/spec.R (one piece of its text replaced) into the global environment, runs the block again and says which
#   checks failed; each mutation must make at least one fail. The original R/spec.R is sourced again after each. Nothing on disk is changed.
#   The block is run with a 10^7-element vector where the real run has 10^9 (a mutation that removes the size limits then allocates 80 MB, not 8 GB).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
a11_big_override <- "10^7"
a11_orig_read <- get("read_image", envir = asNamespace("gridtext"))   # gridtext's own reader, for mutation M29
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 11A begin", smoke):grep("^# <<< 11A end", smoke)], keep.source = FALSE)
spec_file <- file.path("R", "spec.R")
spec_text <- paste(readLines(spec_file, encoding = "UTF-8"), collapse = "\n")

hits <- new.env()
check <- function(what, cond) {
  pass <- isTRUE(tryCatch(cond, error = function(e) FALSE))
  hits$all <- c(hits$all, stats::setNames(pass, sub(":.*$", "", what)))
  invisible(pass)
}
run_block <- function() {
  hits$all <- logical(0)
  err <- tryCatch({ eval(block, globalenv()); NULL }, error = function(e) conditionMessage(e))
  setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
  list(failed = names(hits$all)[!hits$all], total = length(hits$all), aborted = err)
}
source_text <- function(txt) {
  f <- tempfile(fileext = ".R")
  writeLines(txt, f, useBytes = TRUE)
  on.exit(unlink(f))
  sys.source(f, envir = globalenv(), keep.source = FALSE)
}
mut <- function(id, what, from, to, all = FALSE) list(id = id, what = what, from = from, to = to, all = all)
mutations <- list(
  mut("M01", "the deny list says nothing (reasons that name the danger gone)", "design_deny_reason <- function(name) {", "design_deny_reason <- function(name) {\n  return(NULL)"),
  mut("M02", "the allow-list of called functions removed", "if (!(name %in% cx$callable || name %in% cx$funs))", "if (FALSE)"),
  mut("M03", "a call whose function is a call is no longer named as such", "  if (is.call(fn)) {\n    op =", "  if (is.call(fn) && FALSE) {\n    op ="),
  mut("M04", "the run environment's parent is the global environment, not emptyenv()", "e = new.env(parent = emptyenv())\n  list2env(toolkit, envir = e)", "e = new.env(parent = globalenv())\n  list2env(toolkit, envir = e)"),
  mut("M05", "no `::` in the run environment (an operator on a ggplot cannot dispatch)", "  list2env(list(`::` = design_ns_get), envir = e)\n", ""),
  mut("M06", "a time limit of 60 seconds, not 20", "DESIGN_TIME_LIMIT <- 20       #", "DESIGN_TIME_LIMIT <- 60       #"),
  mut("M07", "the time limit is not reset afterwards", "}, error = function(e) e, finally = reset())", "}, error = function(e) e, finally = NULL)"),
  mut("M08", "the size-limited c(), paste(), rep(), seq() and `:` removed", "fns = design_screened(utils::modifyList(fns, design_limited()))", "fns = design_screened(fns)"),
  mut("M09", "the screens on the arguments that become functions, facets and sizes removed", "fns = design_screened(utils::modifyList(fns, design_limited()))", "fns = utils::modifyList(fns, design_limited())"),
  mut("M10", "the markup check before drawing removed", "      if (!is.null(markup)) stop(markup, call. = FALSE)\n", ""),
  mut("M11", "the check for a function that calls itself removed", "  loop = if (!length(why) && length(funs)) design_cycle(exprs, funs)", "  loop = NULL"),
  mut("M12", "toolkit names, base R's and the provided objects may be assigned to", "reserved = c(cx$provided, names(DESIGN_CONSTANTS), DESIGN_BASE, if (fn_value) cx$callable)", "reserved = character(0)"),
  mut("M13", "a string given as a function, a method or a transformation passes the guard", "      here = design_string_args(e, name, cx)", "      here = character(0)"),
  mut("M14", "any number of bins or points", "DESIGN_COUNT_MAX <- 10000 ", "DESIGN_COUNT_MAX <- 1e12 "),
  mut("M15", "rows dropped without a filter() are not refused", "if (mark && n < nd && !filtered)", "if (FALSE)"),
  mut("M16", "a layer may have more rows than d", "if (n > nd + if (mark) 0L else DESIGN_ROW_EXTRA)", "if (FALSE)"),
  mut("M17", "bars and areas need not include zero", "if (!inherits(l$geom, c(\"GeomBar\", \"GeomArea\"))) return(NA_character_)", "if (TRUE) return(NA_character_)"),
  mut("M18", "a second axis is not refused", "if (any(second))", "if (FALSE)"),
  mut("M19", "the scale types are not compared with the spec's", "if (!ok) paste0(\"The axes are \"", "if (FALSE) paste0(\"The axes are \""),
  mut("M20", "text contrast 1.1 to 1, not 4.5", "ratio < 4.5", "ratio < 1.1", all = TRUE),
  mut("M21", "texts are not measured (clipped and overlapping texts pass)", "tf = if (text) tryCatch(design_text_faults(plot, size)", "tf = if (FALSE) tryCatch(design_text_faults(plot, size)"),
  mut("M22", "numbers written on the chart are not checked", "if (length(bad)) paste0(\"The chart writes \"", "if (FALSE) paste0(\"The chart writes \""),
  mut("M23", "code of 60,000 characters allowed", "DESIGN_MAX_CODE <- 6000L", "DESIGN_MAX_CODE <- 60000L"),
  mut("M24", "a number written in the code may be of any size", "DESIGN_MAX_NUM <- 1e7 ", "DESIGN_MAX_NUM <- 1e12 "),
  mut("M25", "rows removed by a scale's limits are not refused", "if (length(hit)) paste0(\"ggplot2 left rows out", "if (FALSE) paste0(\"ggplot2 left rows out"),
  mut("M26", "the provided objects may be changed", "if (nm %in% cx$provided) return(paste0(", "if (FALSE) return(paste0("),
  mut("M27", "`<<-` is no longer named as refused", "`<<-` = , `->>` =", "`<<-x` = , `->>x` ="),
  mut("M28", "the run environment's `::` finds any base function", "if (identical(p, \"base\") && identical(n, \"chooseOpsMethod\")) base::chooseOpsMethod else stop(", "if (TRUE) get(n, envir = baseenv()) else stop("),
  # the lead's review (check 11A-13). M29 puts gridtext's own image reader back, since an earlier run in this process has replaced it.
  mut("M29", "gridtext's image reader is not replaced (markup made while the plot is built reads a picture)", "  design_block_images()\n  .design_cache$image_hit = FALSE",
      "  utils::assignInNamespace(\"read_image\", a11_orig_read, ns = \"gridtext\"); .design_cache$images_blocked = FALSE\n  .design_cache$image_hit = FALSE"),
  mut("M30", "the limited replacement forms removed (a far index makes the vector)", "  list2env(design_replace(), envir = e)\n", ""),
  mut("M31", "a bare name in aes() or a dplyr verb is refused unless it is a column of d", "  if (name %in% DESIGN_MASKED) return(", "  if (FALSE) return("),
  # after the first live run (check 11A-14)
  mut("M32", "Inf is refused as a number too large", "any(is.finite(e) & abs(e) >= DESIGN_MAX_NUM, na.rm = TRUE)", "any(abs(e) >= DESIGN_MAX_NUM, na.rm = TRUE)"),
  mut("M33", "a factory's function called at once is refused", "  if (is.call(fn) && is.symbol(fn[[1]]) && as.character(fn[[1]]) %in% DESIGN_FACTORIES", "  if (FALSE && is.call(fn) && is.symbol(fn[[1]]) && as.character(fn[[1]]) %in% DESIGN_FACTORIES"),
  mut("M34", "a column the code makes is not a name of its own", "  c(here, cols, unlist(", "  c(here, unlist("),
  mut("M35", "the tokens' slate grey is the style's, whatever its contrast", "slate = rd(st$slate)", "slate = st$slate"),
  # the second round of fixes after the live run (check 11A-15)
  mut("M36", "a variable of the code's own may not have a deny-listed name", "    else if (fn_value) design_deny_reason(nm)", "    else design_deny_reason(nm)"),
  mut("M37", "any factory called at once, not only label_ and breaks_", "as.character(fn[[1]]) %in% DESIGN_FACTORIES && as.character(fn[[1]]) %in% cx$callable)", "TRUE)"),
  mut("M38", "all text on layers needs only 3 to 1", "need = ifelse(series, 3, 4.5)", "need = 3"),
  mut("M39", "a series name need not be in a series colour for 3 to 1", "series = norm(col) %in% series_cols & (same | label %in% series_names)", "series = (same | label %in% series_names)"),
  mut("M40", "R does not add the source line", "if (isTRUE(caption) && is_text1(txt$caption) && design_no_caption(plot))", "if (FALSE)"),
  mut("M41", "TOOLKIT does not say what is refused", "\"\", design_refused_text()), collapse", "\"\"), collapse"),
  mut("M42", "the source line is added without the braces", "paste0(\"{\\n\", code, \"\\n} +\\n  labs(caption = txt$caption)\")", "paste0(code, \" +\\n  labs(caption = txt$caption)\")"))
wanted <- commandArgs(trailingOnly = TRUE)
if (length(wanted)) mutations <- purrr::keep(mutations, function(m) m$id %in% wanted)

base <- run_block()
cat("\nbaseline: ", base$total - length(base$failed), " of ", base$total, " checks pass", if (length(base$failed)) paste0(" (FAIL: ", paste(base$failed, collapse = ", "), ")"),
    if (!is.null(base$aborted)) paste0(" (ABORTED: ", base$aborted, ")"), "\n", sep = "")
results <- purrr::map(mutations, function(m) {
  n <- lengths(regmatches(spec_text, gregexpr(m$from, spec_text, fixed = TRUE)))
  if (n < 1L || (!m$all && n > 1L)) return(list(id = m$id, what = m$what, applied = n, failed = NA_character_, aborted = NULL))
  source_text(if (m$all) gsub(m$from, m$to, spec_text, fixed = TRUE) else sub(m$from, m$to, spec_text, fixed = TRUE))
  t0 <- Sys.time()
  r <- run_block()
  source_text(spec_text)
  cat(sprintf("%s  %-72s %3d failed: %s%s  (%.0f s)\n", m$id, m$what, length(r$failed), paste(r$failed, collapse = " "),
              if (!is.null(r$aborted)) paste0("  [block stopped: ", substr(r$aborted, 1, 60), "]") else "", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  list(id = m$id, what = m$what, applied = n, failed = r$failed, aborted = r$aborted)
})
bad_apply <- purrr::keep(results, function(r) r$applied != 1L && !identical(r$id, "M20"))
caught <- purrr::map_lgl(results, function(r) length(r$failed) > 0L || !is.null(r$aborted))
cat("\n", sum(caught), " of ", length(results), " mutations made at least one check fail", if (length(bad_apply)) paste0("; did not apply: ", paste(purrr::map_chr(bad_apply, "id"), collapse = ", ")), "\n", sep = "")
if (!all(caught) || length(bad_apply) || length(base$failed)) quit(status = 1)
