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
                       "mode.md", "cross_cultural.md", "evaluate.md", "pm_brief.md", "pm_appraise.md")

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


# ---- the analyst's set -------------------------------------------------------------------------

# What the reviewer recommended, and what the analyst does with it, is kept in the session
#   state and the run log, never in the drafts: the drafts stay as the workers wrote them.
#   state$set is a list of entries (set_entry()), one per item in the set, in the order asked:
#   the candidate letter, the item's position in that candidate's draft, its id and domain, the
#   reviewer's reason and concerns, and whether the analyst swapped it in. state$edits holds
#   only what the analyst changed, by the entry's uid (the letter and the position).
set_entry <- function(candidate, position, id, domain = "", check = "", swapped = FALSE)
  list(uid = paste0(candidate, "_", position), candidate = candidate, position = position, id = id,
       domain = domain, check = check, swapped = swapped)

# The set as the reviewer recommended it (check_appraisal()'s `selected`).
initial_set <- function(chk)
  purrr::map(chk$selected, function(e)
    set_entry(e$candidate, e$position, e$id, e$domain, e$check))
# An item from a draft put in the set: in place of the entry whose uid is `target`, or at the
#   end when there is none. An item that is already in the set is not put in twice.
set_swap <- function(set, entry, target = NULL) {
  uids = purrr::map_chr(set, "uid")
  at = match(target %||% "", uids)
  if (entry$uid %in% uids) set
  else if (is.na(at)) c(set, list(entry))
  else replace(set, at, list(entry))
}

# An item taken out of the set.
set_remove <- function(set, uid) purrr::discard(set, function(e) identical(e$uid, uid))

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

# What the analyst changed, read from the boxes on the page: for each entry of the set, the fields
#   whose text is no longer the draft's. get(id) gives what is in the box with that input id, or
#   NULL; the box ids are made by edit_input_id(). An entry with no change has no entry in the result.
edit_input_id <- function(uid, ...) paste(c("ed", uid, ...), collapse = "_")

edits_from_inputs <- function(set, drafts, seed, get) {
  cands = candidates_of(drafts, seed)
  text_of = function(o) paste(unlist(o), collapse = " ")
  changed = function(id, old) { v = get(id); if (!is.null(v) && !identical(v, old)) v }
  out = purrr::map(set, function(e) {
    it = full_item(unname(cands[[e$candidate]]$items)[[e$position]])
    new = purrr::imap(purrr::map_chr(it$options, text_of), function(o, j) changed(edit_input_id(e$uid, paste0("o", j)), o))
    opts = purrr::set_names(new, seq_along(new))[!purrr::map_lgl(new, is.null)]
    ed = purrr::compact(list(stem = changed(edit_input_id(e$uid, "stem"), it$stem),
                             options = if (length(opts)) opts))
    if (length(ed)) ed
  })
  purrr::compact(purrr::set_names(out, purrr::map_chr(set, "uid")))
}
# The set as the analyst left it: for each entry the candidate, the model behind that letter (which
#   Results shows), the item with the changes put on it, and whether it was swapped in or edited. An
#   entry that no longer points at an item is dropped, not guessed at.
final_set <- function(set, edits, drafts, seed) {
  cands = candidates_of(drafts, seed)
  labels = labels_of(drafts, seed)
  purrr::compact(purrr::map(set, function(e) {
    items = unname(cands[[e$candidate]]$items)
    if (is.null(items) || e$position > length(items)) return(NULL)
    list(candidate = e$candidate, model = labels[[e$candidate]], position = e$position, uid = e$uid,
         domain = e$domain, check = e$check %||% "", swapped = isTRUE(e$swapped), edited = !is.null(edits[[e$uid]]),
         item = apply_edits(full_item(items[[e$position]]), edits[[e$uid]]))
  }))
}

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

# The drafted questions of the set as the analyst left it (final_set()), under the one sentence.
draft_blocks <- function(chosen)
  c(list(blk_p(RESULT_NOTICE, em = TRUE)),
    unlist(purrr::imap(chosen, function(k, i) item_blocks(k$item, i, k$check)), recursive = FALSE))


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

DISCLOSURE_LINE <- paste("Expert-review appraisal and first drafts by language models.",
                         "Not a pretest. Test with real respondents before fielding.")

# The reflex files a flow used, and their versions: the task's files for the work step (and
#   cross_cultural.md only when it was in force), pm_appraise.md for the appraisal and pm_brief.md
#   when the brief was checked.
reflex_files_used <- function(f, brief_ran = FALSE) {
  files = unique(c(step_files(f$task, "work"),
                   if (TASKS[[f$task]]$kind == "draft") "pm_appraise.md",
                   if (brief_ran) "pm_brief.md"))
  files[files != "cross_cultural.md" | needs_cross_cultural(f)]
}

# A model as the endpoint names it: its id, and the host that served it.
model_text <- function(m) paste0(m$id, " (", llm_host(m), ")")

# The disclosure block, as blocks: the date, the profile, each model id, each reflex file's version,
#   the hash of each prompt and whether it was edited, which candidate each item of the set came from
#   and whether the analyst edited it or swapped it in, and the line that says what this is. chosen is
#   final_set(); brief, approved, appraisal and review are what the run returned, any of them NULL.
disclosure_blocks <- function(f, chosen = list(), drafts = NULL, appraisal = NULL, review = NULL,
                              brief = NULL, approved = NULL, profile = APP_PROFILE, models = APP_MODELS,
                              time = Sys.time(), dir = REFLEXES_DIR) {
  draft = TASKS[[f$task]]$kind == "draft"
  brief_ran = is.list(brief) && identical(brief$status, "ok")
  files = reflex_files_used(f, brief_ran)
  versions = purrr::map_chr(files, function(x) paste0(x, " ", read_reflex_file(x, dir)$version))
  hash = function(label, h) if (!is.null(h) && !is.na(h)) paste0(label, ": ", h)
  used = purrr::map_chr(purrr::keep(unname(as.list(drafts)), function(d) identical(d$status, "ok")), "model")
  asked = purrr::map_chr(unname(as.list(drafts)), "model")
  prompt_lines = c(
    if (brief_ran) hash("Brief check prompt", brief$hash),
    if (draft && !is.null(approved)) hash(if (isTRUE(approved$edited)) "Drafting prompt as sent (edited by the analyst)"
                                          else "Drafting prompt (not edited)", approved$hash),
    if (draft && isTRUE(approved$edited)) hash("Drafting prompt as assembled", approved$original_hash),
    if (draft && !is.null(appraisal)) hash("Appraisal prompt", appraisal$hash),
    if (!draft && length(review$batches) <= 1L && !is.null(review))
      hash(if (isTRUE(approved$edited)) "Review prompt as sent (edited by the analyst)" else "Review prompt (not edited)",
           review$hash),
    if (!draft && isTRUE(approved$edited) && length(review$batches) <= 1L)
      hash("Review prompt as assembled", approved$original_hash),
    if (!draft && length(review$batches) > 1L)
      unlist(purrr::map(review$batches, function(b) hash(if (identical(b$kind, "instrument")) "Review prompt, instrument as a whole"
                                                         else paste0("Review prompt, part ", b$part, " of ", b$n_parts), b$hash))))
  from = purrr::map_chr(seq_along(chosen), function(i)
    paste0("Item ", i, " (", chosen[[i]]$item$id, "): candidate ", chosen[[i]]$candidate, ", written by ",
           chosen[[i]]$model, if (chosen[[i]]$swapped) "; swapped in by the analyst, not the reviewer's choice",
           if (chosen[[i]]$edited) "; edited by the analyst"))
  c(list(blk_h("Disclosure of the use of language models", 2L),
         blk_list(c(
           paste0("Date: ", format(time, "%Y-%m-%d %H:%M")),
           paste0("Profile: ", profile),
           paste0("Project manager model: ", model_text(models$pm)),
           if (draft && length(used)) paste0("Worker models that drafted: ",
                                             paste(purrr::map_chr(purrr::keep(models$workers, function(m) m$id %in% used), model_text),
                                                   collapse = "; ")),
           if (draft && length(setdiff(asked, used))) paste0("Worker models asked that returned no usable draft: ",
                                                             paste(setdiff(asked, used), collapse = ", ")),
           paste0("Reflex files and versions: ", paste(versions, collapse = "; ")),
           prompt_lines,
           if (length(from)) from))),
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
#   set as the analyst left it (final_set()); a review's is the review. With nothing to show, the output
#   says so and has no three lines. Everything else (prompts, models, hashes, every draft, the full
#   reply) is in the record (disclosure_blocks(), run_log_json()), not here. f is the cleaned form.
build_output <- function(f, drafts = NULL, seed = NULL, set = list(), edits = list(), review = NULL,
                         time = Sys.time()) {
  kind = TASKS[[f$task]]$kind
  if (kind == "review") {
    if (is.null(review) || is.null(review$reply))
      return(finish_output(kind, list(blk_p("There is no review to show. Run one on the Results tab.")), list(), 0L))
    return(finish_output(kind, review_blocks(f, review), output_footer(time), 0L))
  }
  chosen = if (!is.null(drafts)) final_set(set, edits, drafts, seed) else list()
  if (!length(chosen))
    return(finish_output(kind, list(blk_p(paste0("There is no item in the set yet. The Results tab shows the ",
                                                 "recommended items, and you can add items from the drafts."))), list(), 0L))
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
known_keys <- function(models = APP_MODELS) {
  ks = purrr::map_chr(c(list(models$pm), models$workers), function(m)
    tryCatch(llm_key_for(m) %||% "", error = function(e) ""))
  unique(ks[nzchar(ks)])
}

# Every occurrence of a key taken out of a text. A key shorter than eight characters is not a key and
#   would damage ordinary words, so it is left.
scrub_secrets <- function(text, secrets) {
  secrets = secrets[nchar(secrets) >= 8L]
  purrr::reduce(secrets, function(t, s) gsub(s, "[key removed]", t, fixed = TRUE), .init = text)
}

# The full record of the session as JSON, one file (the "Download the full record" button): schema 1,
#   the profile and time, the disclosure of the use of language models as text lines (models, reflex
#   file versions, prompt hashes, which candidate each item came from), and every round as flow_round()
#   made it (form, prompts and hashes, raw and parsed replies, the seed and the candidate-to-model map,
#   and the analyst's set, edits and final items). It holds everything that is not on screen or in what
#   is copied to Word, so the work stays defensible. Keys scrubbed.
run_log_json <- function(rounds, profile = APP_PROFILE, time = Sys.time(), secrets = character(0),
                         disclosure = character(0))
  scrub_secrets(as.character(flow_log_json(list(
    schema = 1L, app = "QuestionR", version = QUESTIONR_VERSION,
    written = format(time, "%Y-%m-%dT%H:%M:%S%z"), profile = profile,
    disclosure = as.list(disclosure), rounds = unname(rounds)))), secrets)
