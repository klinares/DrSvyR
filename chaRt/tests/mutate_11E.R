# Mutation runs for the Phase 11 Part E checks (tests/smoke.R, the part between `>>> 11E begin` and `<<< 11E end`). No model call.
#   Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_11E.R                 every mutation
#     Rscript --no-init-file tests/mutate_11E.R M01 M05         only these
# What it does: loads the app as Connect does, runs the 11E block once on the real code (the baseline: every check must pass), then, for each mutation,
#   sources a changed copy of one file of R/ (one piece of its text replaced) into the global environment, runs the block again and says which checks
#   failed; each mutation must make at least one fail (a block that stops is counted: the check it stopped in did not pass). The original file is sourced
#   again after each. Nothing on disk is changed. The safeguards mutated: a card dropped lands where it was put (before or after, in the section it lands in);
#   a section goes with its cards; a collapsed section's cards are not on the canvas but are still in the export; a section's switch leaves out its cards;
#   the export is given the order and the sections; the page writes a heading once, before the first card under it; an edit in place runs the number and
#   word checks and marks what fails; a title edited in place is marked; the FACTS go with the message of a chat turn with a chart selected, names as
#   placeholders, and a tell is checked against them (a number the model worked out is caught).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
exprs <- parse(text = smoke, keep.source = FALSE)
# the two helpers the block takes from the smoke test's top level: the planted value, and the messy file's maker
purrr::walk(purrr::keep(as.list(exprs), function(e) is.call(e) && identical(as.character(e[[1]]), "<-") && is.symbol(e[[2]]) && as.character(e[[2]]) %in% c("SECRET", "make_messy")),
            eval, envir = globalenv())
block <- parse(text = smoke[grep("^# >>> 11E begin", smoke):grep("^# <<< 11E end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(reflexes.R = read_file("reflexes.R"), ui.R = read_file("ui.R"))

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
mut <- function(id, what, file, from, to) list(id = id, what = what, file = file, from = from, to = to)
mutations <- list(
  mut("M01", "a card dropped 'after' lands before", "ui.R", "append(rest, moving, after = if (after) at else at - 1L)", "append(rest, moving, after = at - 1L)"),
  mut("M02", "a section dropped on a card lands inside that card's section", "ui.R", "    ref = if (after) utils::tail(block, 1L) else block[[1]]\n", "    ref = target\n"),
  mut("M03", "a section moved with Move up or Move down leaves its cards behind", "ui.R", "  blocks[c(at, to)] = blocks[c(to, at)]\n  unlist(blocks)", "  ids[c(match(id, ids), match(id, ids) + by)] = ids[c(match(id, ids) + by, match(id, ids))]\n  ids"),
  mut("M04", "a drop on the canvas is ignored by the server", "ui.R", "      state$canvas = canvas_reorder(ids, section_ids(), v$id, v$target, isTRUE(v$after))\n", "      NULL\n"),
  mut("M05", "a heading does not own the cards under it (every card belongs to no section)", "ui.R", "purrr::accumulate(ids, function(cur, i) if (i %in% secs) i else cur, .init = NA_character_)", "purrr::accumulate(ids, function(cur, i) NA_character_, .init = NA_character_)"),
  mut("M06", "a collapsed section still shows its cards on the canvas", "ui.R", "shown = if (head && b[[1]] %in% lay$collapsed) character(0) else cards", "shown = cards"),
  mut("M07", "a section that is switched off leaves its cards in the export", "ui.R", "in_dash(i) && (is.na(s) || in_dash(s)))\n      purrr::map2(ids[on]", "in_dash(i))\n      purrr::map2(ids[on]"),
  mut("M08", "the items for the export carry no section", "ui.R", "if (!is.na(s)) it$section = section_info(s); it })", "it })"),
  mut("M09", "the page writes the heading before every card of a section, not once", "ui.R", "first = !is.null(sec) && (k == 1L || !identical(items[[k - 1L]]$section$id, sec$id))", "first = !is.null(sec)"),
  mut("M10", "the page never writes a heading", "ui.R", "    tagList(if (first) dash_section_head(sec, style), card)", "    tagList(card)"),
  mut("M11", "a headline edited in place is not checked", "ui.R", "        return(invisible(set_story(id, recheck_story(st))))", "        return(invisible(set_story(id, st)))"),
  mut("M12", "a failing headline is marked on the card with nothing", "ui.R", "bad = bad_in(st$headline, NULL)", "bad = FALSE"),
  mut("M13", "a title edited in place is not marked", "ui.R", "bad = length(title_bad) > 0L)", "bad = FALSE)"),
  mut("M14", "a title edited in place is not the chart's title (it is dropped)", "ui.R", "      if (!identical(spec, ch$spec)) set_chart(chart_apply(ch, spec, notes_for(spec)))\n      invisible()", "      invisible()"),
  mut("M15", "a blank headline replaces the headline", "ui.R", "if (is.null(st) || !nzchar(value) || identical(st[[field]], value)) return(invisible())", "if (is.null(st)) return(invisible())"),
  mut("M16", "the chat message carries no FACTS", "reflexes.R", "  user_txt = assemble_chat(q, canvas, chart, cb, columns, last, facts = cf)", "  user_txt = assemble_chat(q, canvas, chart, cb, columns, last)"),
  mut("M17", "a tell is checked against DATA only, not the chart's facts", "reflexes.R", "  facts_text = paste(c(data_block(cb, columns), cf$text), collapse = \"\\n\")", "  facts_text = data_block(cb, columns)"),
  mut("M18", "the facts' placeholders are shown as they are (names not put back)", "reflexes.R", "        shown = if (!is.null(cf)) names_back(text, cf$map) else text", "        shown = text"),
  mut("M19", "the names of the facts are real names in the message", "reflexes.R", "  list(text = if (is.null(x$error)) x$facts$text, map = map)", "  list(text = if (is.null(x$error)) names_back(x$facts$text, x$facts$names), map = map)"),
  mut("M20", "the spec of the SELECTED block carries the real highlighted names", "reflexes.R", "  json = if (length(map)) design_spec_json(chart$spec, map) else", "  json = if (FALSE) design_spec_json(chart$spec, map) else"),
  mut("M21", "a spec the model sends back is not given its names back", "reflexes.R", "check_chart(if (!is.null(cf)) names_back_deep(obj[[\"spec\"]], cf$map) else obj[[\"spec\"]], cb, data, palette, rule_ids)", "check_chart(obj[[\"spec\"]], cb, data, palette, rule_ids)"),
  mut("M22", "the FACTS marker can be opened from inside", "reflexes.R", "(DATA|CANVAS|SELECTED|FACTS)>\", \"[\\\\U\\\\1]\"", "(DATA|CANVAS|SELECTED)>\", \"[\\\\U\\\\1]\""),
  mut("M23", "the dialog's switch on a card is not the card's own", "ui.R", "      if (!is.null(rv) && !identical(isolate(rv()), v)) {\n        rv(v)", "      if (!is.null(rv) && !identical(isolate(rv()), v)) {\n        NULL"),
  mut("M24", "a page layout that does not start again at a heading", "ui.R", "  runs = rep(seq_along(rle(section)$lengths), rle(section)$lengths)", "  runs = rep(1L, length(section))"))
wanted <- commandArgs(trailingOnly = TRUE)
if (length(wanted)) mutations <- purrr::keep(mutations, function(m) m$id %in% wanted)

base <- run_block()
cat("\nbaseline: ", base$total - length(base$failed), " of ", base$total, " checks pass", if (length(base$failed)) paste0(" (FAIL: ", paste(base$failed, collapse = ", "), ")"),
    if (!is.null(base$aborted)) paste0(" (ABORTED: ", base$aborted, ")"), "\n", sep = "")
results <- purrr::map(mutations, function(m) {
  txt <- texts[[m$file]]
  n <- lengths(regmatches(txt, gregexpr(m$from, txt, fixed = TRUE)))
  if (n != 1L) return(list(id = m$id, what = m$what, applied = n, failed = NA_character_, aborted = NULL))
  source_text(sub(m$from, m$to, txt, fixed = TRUE))
  t0 <- Sys.time()
  r <- run_block()
  source_text(txt)
  cat(sprintf("%s  %-72s %3d failed: %s%s  (%.0f s)\n", m$id, m$what, length(r$failed), paste(r$failed, collapse = " "),
              if (!is.null(r$aborted)) paste0("  [block stopped: ", substr(r$aborted, 1, 60), "]") else "", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  list(id = m$id, what = m$what, applied = n, failed = r$failed, aborted = r$aborted)
})
bad_apply <- purrr::keep(results, function(r) r$applied != 1L)
caught <- purrr::map_lgl(results, function(r) length(r$failed) > 0L || !is.null(r$aborted))
cat("\n", sum(caught), " of ", length(results), " mutations made at least one check fail", if (length(bad_apply)) paste0("; did not apply: ", paste(purrr::map_chr(bad_apply, "id"), collapse = ", ")), "\n", sep = "")
if (!all(caught) || length(bad_apply) || length(base$failed)) quit(status = 1)
