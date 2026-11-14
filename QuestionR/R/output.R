# output.R for QuestionR
# What the results are made of, as plain functions with no Shiny state and no model call: a
#   result is a list of blocks, drawn once as HTML for the page and for Word and once as plain
#   text, so the two can never say different things. Also the markdown pages, the drafted items
#   as the analyst edits them, and the run log. Function definitions and constants only.


# ---- the pages that are markdown files ---------------------------------------------------

METHODOLOGY_FILE <- file.path("www", "methodology.md")
START_FILE <- file.path("www", "start.md")

# A markdown file drawn as written (commonmark with GitHub tables). A file that cannot be read is
#   said in words, not a crash.
md_html <- function(txt)
  tagList(tags$style(paste(".qr-note table { border-collapse: collapse; margin: 1rem 0; }",
                           ".qr-note th, .qr-note td { border: 1px solid var(--bs-border-color); padding: 6px 10px; vertical-align: top; }",
                           ".qr-note blockquote { border-left: 3px solid var(--bs-border-color); padding-left: 0.75rem; }")),
          tags$div(class = "qr-note", HTML(shiny::markdown(txt))))

md_page <- function(path)
  tryCatch(md_html(paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")),
           error = function(e) warn_box(tags$strong(paste0("The page ", basename(path), " could not be shown. ")),
                                        substr(conditionMessage(e), 1, 400)))


# ---- a document as blocks, drawn twice ------------------------------------------------------

# Each block has a `type`: "h" (text, level), "p" (text; marks: words to highlight; em), "list"
#   (items; tags: a small tag before each item) or "table" (head, rows).
blk_h <- function(text, level = 2L) list(type = "h", text = text, level = level)
blk_p <- function(text, em = FALSE, marks = character(0), indent = FALSE)
  list(type = "p", text = text, em = em, marks = marks, indent = indent)
blk_list <- function(items, tags = NULL, indent = FALSE) list(type = "list", items = as.character(items), tags = tags, indent = indent)
blk_table <- function(head, rows) list(type = "table", head = head, rows = rows)

# A text with each of the marked words wrapped in <mark>, the rest escaped. A mark is found
#   whatever its case and spacing; one that is not in the text marks nothing.
marked_html <- function(text, marks) {
  marks = marks[nzchar(trimws(marks))]
  if (!length(marks)) return(htmltools::htmlEscape(text))
  escaped = gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", trimws(marks))
  pat = paste0("(", paste(gsub("\\s+", "\\\\s+", escaped), collapse = "|"), ")")
  pieces = regmatches(text, gregexpr(pat, text, ignore.case = TRUE, perl = TRUE), invert = NA)[[1]]
  paste0(purrr::imap_chr(pieces, function(x, i)
    if (i %% 2L == 0L) paste0("<mark>", htmltools::htmlEscape(x), "</mark>") else htmltools::htmlEscape(x)), collapse = "")
}

# The blocks as plain HTML: headings, paragraphs, lists and tables, which is what Word keeps when
#   it is pasted.
doc_html <- function(blocks)
  tagList(purrr::map(blocks, function(b) switch(b$type,
    h = if (b$level <= 2L) tags$h4(b$text) else tags$h5(b$text),
    p = tags$p(style = paste0("white-space: pre-line;", if (isTRUE(b$indent)) " margin-left: 2em;"),
               HTML(if (b$em) paste0("<em>", marked_html(b$text, b$marks), "</em>") else marked_html(b$text, b$marks))),
    list = tags$ul(style = if (isTRUE(b$indent)) "margin-left: 2em;", purrr::imap(b$items, function(x, i)
      tags$li(if (length(b$tags)) tags$span(class = "badge text-bg-light border me-1", b$tags[[i]]), x))),
    table = tags$table(class = "table table-sm", tags$thead(tags$tr(purrr::map(b$head, tags$th))),
                       tags$tbody(purrr::map(b$rows, function(r) tags$tr(purrr::map(r, tags$td))))))))

# The same blocks as plain text.
doc_text <- function(blocks)
  paste(purrr::map_chr(blocks, function(b) switch(b$type,
    h = paste0(b$text, "\n", strrep(if (b$level <= 2L) "=" else "-", nchar(b$text))),
    p = paste0(if (isTRUE(b$indent)) "    ", b$text),
    list = paste0(if (isTRUE(b$indent)) "    ", "- ", if (length(b$tags)) paste0("[", b$tags, "] "), b$items, collapse = "\n"),
    table = paste(purrr::map_chr(c(list(b$head), b$rows), function(r) paste(r, collapse = " | ")), collapse = "\n"))),
    collapse = "\n\n")


# ---- a review, as blocks ------------------------------------------------------------------

# One question's card: the question as pasted with the quoted words highlighted, one line per flag
#   (its why, with its stage as a tag, and "consider" or "not found" where they apply), and the
#   rewrite. levels says which flags it shows.
card_blocks <- function(q, levels = LEVELS) {
  fl = purrr::keep(q$flags, function(x) x$level %in% levels)
  tag = function(x) paste(c(x$stage, if (x$level == "consider" && length(levels) > 1L) "consider",
                            if (!isTRUE(x$found)) "quote not found in your text"), collapse = ", ")
  c(list(blk_h(paste("Question", q$id), 3L), blk_p(q$text, marks = purrr::map_chr(fl, "quote"))),
    if (!q$reviewed) list(blk_p("Not reviewed: its part did not come back.", em = TRUE))
    else if (!length(fl)) list(blk_p("None found by this review.", em = TRUE))
    else list(blk_list(purrr::map_chr(fl, "why"), tags = purrr::map_chr(fl, tag))),
    if (nzchar(q$rewrite) && "fix" %in% levels) rewrite_blocks(q$rewrite))
}

# A rewrite drawn as a question: the question on one line and each option on its own. The options are
#   its last line when that line holds " / ", else the text after its last "?"; they count as options
#   only when there are two or more and each is at most 8 words. Otherwise the rewrite is one paragraph.
rewrite_blocks <- function(rw) {
  lines = trimws(strsplit(gsub("\r\n?", "\n", rw), "\n", fixed = TRUE)[[1]])
  lines = lines[nzchar(lines)]
  last = lines[length(lines)]
  split_at = if (length(lines) > 1L) NA_integer_ else utils::tail(gregexpr("?", last, fixed = TRUE)[[1]], 1L)
  head = if (length(lines) > 1L) paste(lines[-length(lines)], collapse = " ") else if (split_at > 0L) substr(last, 1, split_at) else ""
  tail = if (length(lines) > 1L) last else if (split_at > 0L) substring(last, split_at + 1L) else ""
  opts = trimws(strsplit(tail, " / ", fixed = TRUE)[[1]])
  if (length(opts) < 2L || !nzchar(head) || any(purrr::map_int(opts, n_words) > 8L))
    return(list(blk_p(paste("Rewrite:", paste(lines, collapse = " ")))))
  list(blk_p(paste("Rewrite:", trimws(head))), blk_list(opts))
}

# The first words of a question, for the table.
first_words <- function(text, n = 8L) {
  w = strsplit(trimws(gsub("\\s+", " ", sub(QUESTION_LABEL, "", text, perl = TRUE))), " ", fixed = TRUE)[[1]]
  paste0(paste(utils::head(w, n), collapse = " "), if (length(w) > n) "..." else "")
}

# The review as the analyst reads it and copies it to Word: the bottom line; what to fix first (at
#   most five cards, fix-level flags only); and the table of all questions.
review_blocks <- function(sh)
  c(list(blk_h("Bottom line", 2L)), purrr::map(bottom_line(sh), blk_p),
    if (length(fix_first(sh))) c(list(blk_h("What to fix first", 2L)),
                                 unlist(purrr::map(fix_first(sh), card_blocks, levels = "fix"), recursive = FALSE)),
    list(blk_h("All questions", 2L),
         blk_table(c("Question", "Starts", "Fix", "Consider"),
                   purrr::map(sh$questions, function(q)
                     c(q$id, first_words(q$text), if (q$reviewed) c(n_level(q, "fix"), n_level(q, "consider")) else c("-", "-"))))))

# "How this was produced": date, model, reflex files and versions, number of calls, seconds.
produced_lines <- function(files, calls, m = APP_MODEL, time = Sys.time(), dir = REFLEXES_DIR) {
  versions = purrr::map_chr(files, function(x) paste0(x, " ", read_reflex_file(x, dir)$version))
  secs = sum(purrr::map_dbl(calls, function(x) as.numeric(x$seconds %||% 0)), na.rm = TRUE)
  c(paste0("Date: ", format(time, "%Y-%m-%d %H:%M")), paste0("Model: ", m$id, " (", llm_host(m), ")"),
    paste0("Reflex files and versions: ", paste(versions, collapse = "; ")),
    paste0("Calls: ", length(calls)), paste0("Seconds: ", round(secs)))
}


# ---- the drafted items, as the analyst has them -------------------------------------------

# state$items is the draft's items, each with every field (full_item()) and a uid, its place in the
#   draft, in the order shown; state$edits holds only what the analyst changed, by uid.
draft_items <- function(reply)
  purrr::imap(unname(reply$items %||% list()), function(it, i) c(full_item(it), list(uid = as.character(i))))

item_remove <- function(items, uid) purrr::discard(items, function(it) identical(it$uid, uid))

option_text <- function(o) paste(unlist(o), collapse = " ")

# An item with the analyst's changes put on it: `intro`, `stem` and `options` (new texts by the
#   option's number). An option whose text is cleared is taken out.
apply_edits <- function(it, ed) {
  if (is.null(ed)) return(it)
  if (!is.null(ed$intro)) it$intro = ed$intro
  if (!is.null(ed$stem)) it$stem = ed$stem
  if (!is.null(ed$options)) {
    now = purrr::imap_chr(purrr::map_chr(it$options, option_text), function(o, j) ed$options[[as.character(j)]] %||% o)
    it$options = as.list(now[nzchar(trimws(now))])
  }
  it
}

# The box ids on the page, and what the analyst changed in them: get(id) gives what is in a box.
edit_input_id <- function(uid, ...) paste(c("ed", uid, ...), collapse = "_")

edits_from_inputs <- function(items, get) {
  changed = function(id, old) { v = get(id); if (!is.null(v) && !identical(v, old)) v }
  out = purrr::map(items, function(it) {
    new = purrr::imap(purrr::map_chr(it$options, option_text), function(o, j) changed(edit_input_id(it$uid, paste0("o", j)), o))
    opts = purrr::set_names(new, seq_along(new))[!purrr::map_lgl(new, is.null)]
    ed = purrr::compact(list(intro = changed(edit_input_id(it$uid, "intro"), it$intro),
                             stem = changed(edit_input_id(it$uid, "stem"), it$stem), options = if (length(opts)) opts))
    if (length(ed)) ed
  })
  purrr::compact(purrr::set_names(out, purrr::map_chr(items, "uid")))
}

final_items <- function(items, edits)
  purrr::map(items, function(it) c(apply_edits(it, edits[[it$uid]]), list(edited = !is.null(edits[[it$uid]]))))

WRITE_NOTICE <- "Drafted by one AI model and edited by a second against written criteria. Not a pretest."

# What an open question collects, in plain words; a part's lead ("If Yes:").
answer_line <- function(open_format) paste("Answer:", open_format)
part_lead <- function(when) {
  w = trimws(when %||% "")
  if (!nzchar(w)) return("")
  w = paste0(toupper(substr(w, 1, 1)), substring(w, 2))
  if (grepl("[:.]$", w)) w else paste0(w, ":")
}

# One part as blocks, indented: its lead and stem, then its options or answer format.
part_blocks <- function(p) {
  opts = purrr::map_chr(p$options %||% list(), option_text)
  c(list(blk_p(trimws(paste(part_lead(p$when), p$stem)), indent = TRUE)),
    if (length(opts)) list(blk_list(opts, indent = TRUE))
    else if (nzchar(p$open_format %||% "")) list(blk_p(answer_line(p$open_format), indent = TRUE)))
}

# The final questions as blocks, under the one sentence, laid out the way each is asked: the intro,
#   the stem, the options (or what an open question collects), each part indented, the programming
#   line; then "Before you field these" when the editor left anything for the analyst.
draft_blocks <- function(chosen, needs = list())
  c(list(blk_p(WRITE_NOTICE, em = TRUE)),
    unlist(purrr::imap(chosen, function(it, i) {
      opts = purrr::map_chr(it$options, option_text)
      c(list(blk_h(paste("Question", i), 3L)),
        if (nzchar(it$intro)) list(blk_p(it$intro)),
        list(blk_p(it$stem)),
        if (length(opts)) list(blk_list(opts)) else list(blk_p(answer_line(it$open_format))),
        unlist(purrr::map(it$parts, part_blocks), recursive = FALSE),
        if (nzchar(it$programming)) list(blk_p(paste("Programming:", it$programming), em = TRUE)))
    }), recursive = FALSE),
    if (length(needs)) list(blk_h("Before you field these", 2L), blk_list(purrr::map_chr(needs, option_text))))


# ---- the run log and keys ------------------------------------------------------------------

# The key this session could have used, for scrub_secrets(). Nothing is ever written with it.
known_keys <- function() {
  k = llm_session_key() %||% ""
  k[nzchar(k)]
}

# Every occurrence of a key taken out of a text. A key shorter than eight characters is not a key and
#   would damage ordinary words, so it is left.
scrub_secrets <- function(text, secrets) {
  secrets = secrets[nchar(secrets) >= 8L]
  purrr::reduce(secrets, function(t, s) gsub(s, "[key removed]", t, fixed = TRUE), .init = text)
}

QUESTIONR_VERSION <- "0.10"

# The run log as JSON: every run as flow_round() made it, with the prompts and their hashes, the raw
#   and parsed replies, and the analyst's edits. Keys scrubbed.
run_log_json <- function(rounds, profile = APP_PROFILE, time = Sys.time(), secrets = character(0))
  scrub_secrets(as.character(flow_log_json(list(
    app = "QuestionR", version = QUESTIONR_VERSION, written = format(time, "%Y-%m-%dT%H:%M:%S%z"),
    profile = profile, rounds = unname(rounds)))), secrets)
