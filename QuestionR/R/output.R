# output.R for QuestionR
# What the Output tab and the Methodology tab are made of (DESIGN.md sections 8
#   and 14), as plain functions with no Shiny state and no model call in them, so a
#   test can build every output without a browser: the reflexes as a table, the items
#   in the set or the review as one document that renders both as HTML that pastes
#   into Word and as plain text, the disclosure block, and the run log.
#   The screens that show them are the last part of ui_generate.R. Function
#   definitions and constants only.


# ---- the reflex table, and the pages that are markdown files ---------------------------------------------------------------------------

# One row per reflex of every reflex file, in the order of REFLEX_FILES: file, id, when
#   it applies, and its source ("" when a reflex gives none). Read from the files as
#   the prompts are, so the table cannot say something the prompts do not.
reflexes_table <- function(dir = REFLEXES_DIR) {
  rfiles = purrr::map(purrr::set_names(REFLEX_FILES), function(f) read_reflex_file(f, dir))
  rows = purrr::list_flatten(unname(purrr::imap(rfiles, function(s, file)
    purrr::map(unname(s$reflexes), function(r)
      list(file = file, id = r$id, when = r$when, source = if (is.na(r$source)) "" else r$source)))))
  data.frame(file = purrr::map_chr(rows, "file"), id = purrr::map_chr(rows, "id"),
             when = purrr::map_chr(rows, "when"), source = purrr::map_chr(rows, "source"),
             stringsAsFactors = FALSE)
}


# The pages that are a markdown file, Start here's welcome and the Methodology tab (DESIGN.md
#   section 16), drawn as the file is written: shiny::markdown() (commonmark with the GitHub
#   extensions, so its tables are tables). A file that is missing is said in words, not a crash:
#   the pages are built when the app starts.
METHODOLOGY_FILE <- file.path("www", "methodology.md")
START_FILE <- file.path("www", "start.md")

md_page <- function(path)
  tryCatch(
    tagList(tags$style(paste0(".qr-note table { border-collapse: collapse; margin: 1rem 0; } ",
                              ".qr-note th, .qr-note td { border: 1px solid var(--bs-border-color); padding: 6px 10px; vertical-align: top; } ",
                              ".qr-note th { background: var(--bs-tertiary-bg); }")),
            tags$div(class = "qr-note",
                     HTML(shiny::markdown(paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n"))))),
    error = function(e)
      warn_box(tags$strong(paste0("The page ", basename(path), " could not be shown. ")), substr(conditionMessage(e), 1, 400)))


# The reflex files in the order of the table on the Methodology page.
REFLEX_PANEL_ORDER <- c("core.md", "generate.md", "attitudinal.md", "behavioral.md", "sensitive.md",
                       "mode.md", "evaluate.md")

# One closed panel for each reflex file, under the Methodology page: the file's title and version, and
#   on opening the file as markdown with its HTML comments removed. It is read by read_reflex_file(), the
#   one reader of the reflex files (so the page and the prompts cannot read them differently); the
#   README of the folder is for maintainers and is not drawn. A file that cannot be read is said so
#   in words, as md_page() does.
reflex_panels <- function(dir = REFLEXES_DIR)
  tryCatch(
    tags$div(class = "qr-note", purrr::map(REFLEX_PANEL_ORDER, function(f) {
      s = read_reflex_file(f, dir)
      tags$details(class = "mb-2",
                   tags$summary(tags$strong(paste0(s$title, ", version ", s$version))),
                   HTML(shiny::markdown(s$text)))
    })),
    error = function(e)
      warn_box(tags$strong("The reflex files could not be shown. "), substr(conditionMessage(e), 1, 400)))


# ---- a document as blocks, drawn twice ------------------------------------------------------

# An output is a list of blocks, so the HTML for Word and the plain text can never say
#   different things. Each block is a list with `type`: "h" (text, level 2 or 3), "p"
#   (text, em, indent) or "list" (items, ordered, indent).
blk_h <- function(text, level = 2L) list(type = "h", text = text, level = level)
blk_p <- function(text, em = FALSE, indent = FALSE) list(type = "p", text = text, em = em, indent = indent)
blk_list <- function(items, ordered = FALSE, indent = FALSE)
  list(type = "list", items = as.character(items), ordered = ordered, indent = indent)

# The blocks as plain HTML, nothing but headings, paragraphs, lists and block quotes, which
#   is what Word keeps, numbering and emphasis included, when it is selected and pasted.
doc_html <- function(blocks)
  tagList(purrr::map(blocks, function(b) {
    node = switch(b$type,
      h = if (b$level <= 2L) tags$h4(b$text) else tags$h5(b$text),
      p = tags$p(if (b$em) tags$em(b$text) else b$text),
      list = (if (b$ordered) tags$ol else tags$ul)(purrr::map(b$items, tags$li)))
    if (isTRUE(b$indent)) tags$blockquote(node) else node
  }))

# The same blocks as plain text: a heading underlined, a numbered list as "1. ", a bullet
#   list as "- ", an indented block four spaces in, a blank line between blocks.
doc_text <- function(blocks) {
  lines = purrr::map_chr(blocks, function(b) {
    pad = if (isTRUE(b$indent)) "    " else ""
    body = switch(b$type,
      h = paste0(b$text, "\n", strrep(if (b$level <= 2L) "=" else "-", nchar(b$text))),
      p = paste0(pad, b$text),
      list = paste0(pad, if (b$ordered) paste0(seq_along(b$items), ". ") else "- ", b$items, collapse = "\n"))
    body
  })
  paste(lines, collapse = "\n\n")
}


# ---- the drafted items, as the analyst has them ---------------------------------------------

# state$items is the draft's items, each with every field (full_item()) and a uid, its place in the
#   draft, in the order shown; state$edits holds only what the analyst changed, by uid. The draft
#   itself stays as the model wrote it.
draft_items <- function(reply)
  purrr::imap(unname(reply$items %||% list()), function(it, i) c(full_item(it), list(uid = as.character(i))))

# An item taken out.
item_remove <- function(items, uid) purrr::discard(items, function(it) identical(it$uid, uid))

# An item with the analyst's changes put on it. edits holds only what changed: `stem` and `options`
#   (a list of new texts by the option's number). An option whose text is cleared is taken out.
apply_edits <- function(it, ed) {
  if (is.null(ed)) return(it)
  texts = function(old, new) {
    olds = purrr::map_chr(old, function(o) paste(unlist(o), collapse = " "))
    now = purrr::imap_chr(olds, function(o, j) new[[as.character(j)]] %||% o)
    as.list(now[nzchar(trimws(now))])
  }
  if (!is.null(ed$stem)) it$stem = ed$stem
  if (!is.null(ed$options)) it$options = texts(it$options, ed$options)
  it
}

# What the analyst changed, read from the boxes on the page: for each item, the fields whose text is
#   no longer the draft's. get(id) gives what is in the box with that input id, or NULL; the box ids
#   are made by edit_input_id(). An item with no change has no entry in the result.
edit_input_id <- function(uid, ...) paste(c("ed", uid, ...), collapse = "_")

edits_from_inputs <- function(items, get) {
  text_of = function(o) paste(unlist(o), collapse = " ")
  changed = function(id, old) { v = get(id); if (!is.null(v) && !identical(v, old)) v }
  out = purrr::map(items, function(it) {
    new = purrr::imap(purrr::map_chr(it$options, text_of), function(o, j) changed(edit_input_id(it$uid, paste0("o", j)), o))
    opts = purrr::set_names(new, seq_along(new))[!purrr::map_lgl(new, is.null)]
    ed = purrr::compact(list(stem = changed(edit_input_id(it$uid, "stem"), it$stem),
                             options = if (length(opts)) opts))
    if (length(ed)) ed
  })
  purrr::compact(purrr::set_names(out, purrr::map_chr(items, "uid")))
}

# The items as the analyst left them, each with the changes put on it and `edited`.
final_items <- function(items, edits)
  purrr::map(items, function(it) c(apply_edits(it, edits[[it$uid]]), list(edited = !is.null(edits[[it$uid]]))))

# ---- what is shown: the result, short (DESIGN.md section 18) ---------------------------------------

# The one sentence above either result.
RESULT_NOTICE <- "These are drafts. Test them with real respondents before fielding."

CHECK_LABEL <- "Check before use:"

# One drafted question as blocks, and nothing else: its number, the question, its answer options (or
#   what an open question collects) and, when the reviewer found a real problem, the one line to
#   check before use.
item_blocks <- function(it, i, check = "") {
  opts = purrr::map_chr(it$options, function(o) paste(unlist(o), collapse = " "))
  c(list(blk_h(paste("Question", i), 3L), blk_p(it$stem)),
    if (length(opts)) list(blk_list(opts, ordered = TRUE))
    else list(blk_p(paste0("[Open question", if (nzchar(it$open_format)) paste0(": ", it$open_format), "]"))),
    if (nzchar(check)) list(blk_p(paste(CHECK_LABEL, check), em = TRUE)))
}

# The drafted questions as the analyst left them (final_items()), under the one sentence.
draft_blocks <- function(chosen)
  c(list(blk_p(RESULT_NOTICE, em = TRUE)),
    unlist(purrr::imap(chosen, function(it, i) item_blocks(it, i)), recursive = FALSE))


# ---- a review ------------------------------------------------------------------------------------

# The review as blocks, from shape_review(): the one sentence; for each question marked Revise, the
#   question as pasted, the verdict, and at most two problems with a suggested rewrite; the questions
#   marked Keep folded into one line; and at most three points about the questionnaire as a whole.
#   rv is run_review()'s result.
review_blocks <- function(f, rv) {
  sh = shape_review(rv$reply, f$questionnaire)
  revise = purrr::keep(sh$questions, function(q) identical(q$verdict, "Revise"))
  per_question = unlist(purrr::map(revise, function(q)
    c(list(blk_h(paste("Question", q$id), 3L)),
      if (nzchar(q$text)) list(blk_p(q$text)),
      list(blk_p("Revise", em = TRUE)),
      unlist(purrr::map(q$problems, function(p)
        c(list(blk_p(paste("Problem:", p$problem))),
          if (nzchar(p$rewrite)) list(blk_p(paste("Suggested rewrite:", p$rewrite))))), recursive = FALSE))),
    recursive = FALSE)
  c(list(blk_p(RESULT_NOTICE, em = TRUE)),
    if (identical(rv$status, "partial"))
      list(blk_p(paste0("PART OF THE REVIEW IS MISSING: ", rv$error, " The questions that are not below were not reviewed."))),
    per_question,
    if (length(sh$keep))
      list(blk_p(paste0(if (length(sh$keep) == 1L) "Question " else "Questions ", paste(sh$keep, collapse = ", "),
                        ": keep as written"))),
    if (length(sh$instrument))
      list(blk_h("The questionnaire as a whole", 2L), blk_list(sh$instrument)))
}

# ---- the disclosure block ----------------------------------------------------------------------

DISCLOSURE_LINE <- paste("Expert-review appraisal and first drafts by a language model.",
                         "Not a pretest. Test with real respondents before fielding.")

# A model as the endpoint names it: its id, and the host that served it.
model_text <- function(m) paste0(m$id, " (", llm_host(m), ")")

# The disclosure block, as blocks: the date, the profile, the model, each reflex file's version, and
#   the hash of each prompt sent. approved is the approved prompt (its hash, and whether it was
#   edited); review is run_review()'s result, whose parts each have their own hash.
disclosure_blocks <- function(f, approved = NULL, review = NULL, profile = APP_PROFILE, m = APP_MODEL,
                              time = Sys.time(), dir = REFLEXES_DIR) {
  files = step_files(f$task, "work")
  versions = purrr::map_chr(files, function(x) paste0(x, " ", read_reflex_file(x, dir)$version))
  hashes = if (length(review$batches) > 1L)
    purrr::map_chr(review$batches, function(b)
      paste0(if (identical(b$kind, "instrument")) "Prompt, instrument as a whole" else paste0("Prompt, part ", b$part, " of ", b$n_parts),
             ": ", b$hash))
  else if (!is.null(approved))
    c(paste0(if (isTRUE(approved$edited)) "Prompt as sent (edited by the analyst): " else "Prompt (not edited): ", approved$hash),
      if (isTRUE(approved$edited)) paste0("Prompt as assembled: ", approved$original_hash))
  c(list(blk_h("Disclosure of the use of a language model", 2L),
         blk_list(c(paste0("Date: ", format(time, "%Y-%m-%d %H:%M")),
                    paste0("Profile: ", profile),
                    paste0("Model: ", model_text(m)),
                    paste0("Reflex files and versions: ", paste(versions, collapse = "; ")),
                    hashes))),
    list(blk_p(DISCLOSURE_LINE)))
}


# ---- the whole output --------------------------------------------------------------------------

# The version of the tool, in the last line of what is copied to Word.
QUESTIONR_VERSION <- "0.9"

# The three lines after what is on screen, in what is copied to Word: the date, who drafted and who
#   reviewed (the analyst completes the last), and the tool's version.
output_footer <- function(time = Sys.time())
  list(blk_p(paste0("Date: ", format(time, "%Y-%m-%d"))),
       blk_p("Drafted with QuestionR, an AI tool; reviewed by [analyst to complete]"),
       blk_p(paste0("QuestionR version ", QUESTIONR_VERSION)))

# The output of one flow, as a list: `kind` ("draft" or "review"), `blocks` (what is on screen, then
#   the three lines), `html` (plain HTML for Word), `text` (the same, as plain text), `screen_text` (the
#   text of what is on screen, without the three lines) and `n_items`. A drafting flow's output is the
#   items as the analyst left them (final_items()); a review's is the review. With nothing to show, the output
#   says so and has no three lines. Everything else (prompts, models, hashes, every draft, the full
#   reply) is in the record (disclosure_blocks(), run_log_json()), not here. f is the cleaned form.
build_output <- function(f, items = list(), edits = list(), review = NULL, time = Sys.time()) {
  kind = TASKS[[f$task]]$kind
  if (kind == "review") {
    if (is.null(review) || is.null(review$reply))
      return(finish_output(kind, list(blk_p("There is no review to show. Run one on the Results tab.")), list(), 0L))
    return(finish_output(kind, review_blocks(f, review), output_footer(time), 0L))
  }
  chosen = final_items(items, edits)
  if (!length(chosen))
    return(finish_output(kind, list(blk_p("There is no drafted item to show.")), list(), 0L))
  finish_output(kind, draft_blocks(chosen), output_footer(time), length(chosen))
}

finish_output <- function(kind, screen, footer, n_items) {
  blocks = c(screen, footer)
  list(kind = kind, blocks = blocks, html = doc_html(blocks), text = doc_text(blocks),
       screen_text = doc_text(screen), n_items = n_items)
}

# ---- the run log and keys ---------------------------------------------------------------------------

# The keys this session could have used: the analyst's pasted key and any server key of the models,
#   as strings, for scrub_secrets(). Nothing is ever written with a key in it.
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

# The full record of the session as JSON, one file (the "Download the full record" button): schema 1,
#   the profile and time, the disclosure of the use of language models as text lines (models, reflex
#   file versions, prompt hashes), and every round as flow_round() made it (form, prompts and hashes,
#   raw and parsed replies, and the analyst's edits and final items). It holds everything that is not on screen or in what
#   is copied to Word, so the work stays defensible. Keys scrubbed.
run_log_json <- function(rounds, profile = APP_PROFILE, time = Sys.time(), secrets = character(0),
                         disclosure = character(0))
  scrub_secrets(as.character(flow_log_json(list(
    schema = 1L, app = "QuestionR", version = QUESTIONR_VERSION,
    written = format(time, "%Y-%m-%dT%H:%M:%S%z"), profile = profile,
    disclosure = as.list(disclosure), rounds = unname(rounds)))), secrets)
