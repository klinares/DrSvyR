# checks.R for QuestionR
# What R checks and codes for itself, so no model is trusted with it (DESIGN.md
#   sections 7 and 12): the shape of every reply and the validators built from
#   it, the item count, the coded format defaults, and the checks on an
#   appraisal. No Shiny and no model call in here; every function takes the
#   parsed reply it is to check. Function definitions and constants only.


# ---- reply schemas, one entry per output format ----------------------------------

# What a reply must hold, per output format, and the validator built from it. A
#   new output format is one entry here. Each entry:
#     fields  top-level field -> type
#     each    for a field that is a list of objects, field -> (field -> type)
#     rules   names of the checks in REPLY_RULES that run once the shape is right
#   Types: text (a non-empty string), string (any string, empty allowed), logical,
#   list. A trailing "?" lets the field be missing or null: a model may leave
#   `options` out of an open question.
# Only what R itself reads is required. A field a skill asks for and R does not
#   use (an item's notes, programming, decisions) is read with a default, so a
#   model that forgets one is not retried for it.
REPLY_SCHEMAS <- list(
  brief = list(
    fields = c(complete = "logical", questions = "list", task_fit = "string", criteria = "list"),
    each = list(questions = c(ask = "text", blocking = "logical")),
    rules = character(0)),
  draft = list(
    fields = c(items = "list"),
    each = list(items = c(id = "text", domain = "text", stem = "text",
                          options = "list?", open_format = "string?", parts = "list?")),
    rules = c("item_count", "options_or_open")),
  appraisal = list(
    fields = c(appraisal = "list", set_fails = "list", coverage = "list", differences = "list",
               merged = "list", test_first = "list", limits = "string"),
    each = list(appraisal = c(candidate = "text", id = "text", fails = "list"),
                set_fails = c(candidate = "text", check = "text", severity = "number")),
    rules = c("fail_entries")),
  # A review of pasted text (the Evaluate task). Findings sit one level further
  #   down than `each` reaches, so a rule reads them.
  review = list(
    fields = c(items = "list", instrument = "list", trapd = "list", test_first = "list",
               not_assessed = "string"),
    each = list(items = c(id = "id", findings = "list")),
    rules = c("finding_entries")))

TYPE_WORDS <- c(text = "a non-empty string", string = "a string",
                logical = "true or false", list = "a list", number = "a number from 1 to 10",
                id = "a question number or label")

type_ok <- function(x, type) {
  optional = endsWith(type, "?")
  if (is.null(x)) return(optional)
  switch(sub("?", "", type, fixed = TRUE),
         text = is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x)),
         string = is.character(x) && length(x) == 1L && !is.na(x),
         logical = is.logical(x) && length(x) == 1L && !is.na(x),
         list = is.list(x),
         # A severity: 1 to 10.
         number = is.numeric(x) && length(x) == 1L && !is.na(x) && x >= 1 && x <= 10,
         # A question's own number or label: a string or a number.
         id = (is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x))) ||
           (is.numeric(x) && length(x) == 1L && !is.na(x)),
         FALSE)
}

# The problems with one object against a field -> type spec, as sentences.
field_problems <- function(obj, spec, where = "") {
  if (!is.list(obj)) return(paste0(where, "is not a JSON object"))
  bad = purrr::keep(names(spec), function(k) !type_ok(obj[[k]], spec[[k]]))
  purrr::map_chr(bad, function(k)
    paste0(where, "'", k, "' ",
           if (is.null(obj[[k]])) "is missing"
           else paste0("must be ", TYPE_WORDS[[sub("?", "", spec[[k]], fixed = TRUE)]])))
}

# Checks that need more than a field's type. Each takes the parsed reply and the
#   extra arguments reply_validator() was given, and returns NULL or a sentence.
REPLY_RULES <- list(
  # Exactly the number asked for. Questions in an item's parts (a filter, a
  #   branch, an unfolding bracket) belong to their item and are not counted.
  item_count = function(obj, n_items = NULL, ...) {
    n = length(obj$items)
    if (!is.null(n_items) && n != n_items)
      paste0("The reply holds ", n, if (n == 1L) " item" else " items", "; ", n_items,
             " ", if (n_items == 1L) "was" else "were", " asked for. Questions inside ",
             "an item's parts are not counted.")
  },
  # An item is closed (it has options) or open (it says what is entered).
  options_or_open = function(obj, ...) {
    bad = purrr::keep(obj$items, function(it)
      !length(it$options) && !type_ok(it$open_format, "text"))
    if (length(bad))
      paste0("Item ", paste(purrr::map_chr(bad, function(it) it$id %||% "?"), collapse = ", "),
             " has neither options nor an open_format.")
  },
  # Every fail in an appraisal names the check it fails and rates it 1 to 10.
  fail_entries = function(obj, ...) {
    bad = purrr::keep(obj$appraisal, function(e)
      !all(purrr::map_lgl(e$fails, function(f)
        is.list(f) && type_ok(f$check, "text") && type_ok(f$severity, "number"))))
    if (length(bad))
      paste0("A fail for ", paste(purrr::map_chr(bad, function(e)
        paste0(e$candidate, " ", e$id)), collapse = ", "),
        " does not name its check and give a severity from 1 to 10.")
  },
  # Every finding in a review gives the check, the evidence, the problem and a
  #   severity from 1 to 10, whether it is about a question or the instrument.
  finding_entries = function(obj, ...) {
    whole = function(f)
      is.list(f) && type_ok(f$check, "text") && type_ok(f$severity, "number") &&
        type_ok(f$evidence, "string") && type_ok(f$problem, "string")
    bad_items = purrr::keep(obj$items, function(it) !all(purrr::map_lgl(it$findings, whole)))
    bad_inst = !all(purrr::map_lgl(obj$instrument, whole))
    if (length(bad_items) || bad_inst)
      paste0("A finding for ",
             paste(c(purrr::map_chr(bad_items, function(it) paste("question", it$id)),
                     if (bad_inst) "the instrument"), collapse = ", "),
             " does not give its check, evidence, problem and a severity from 1 to 10.")
  })

# A validator for llm_json(): stops with a readable sentence when the reply is not
#   what the format asks for. Extra arguments (n_items for a draft) go to the
#   rules. A reply that fails is a failed attempt, so it is retried, and the
#   sentence is what the analyst reads if every attempt fails.
reply_validator <- function(format, ...) {
  spec = REPLY_SCHEMAS[[format]]
  if (is.null(spec))
    stop("There is no reply schema called '", format, "'.", call. = FALSE)
  extra = list(...)
  function(obj) {
    if (!is.list(obj))
      stop("The reply is not what was asked for: it is not a JSON object.", call. = FALSE)
    problems = c(
      field_problems(obj, spec$fields),
      unlist(purrr::imap(spec$each, function(element_spec, field)
        if (is.list(obj[[field]]))
          unlist(purrr::imap(obj[[field]], function(el, i)
            field_problems(el, element_spec, paste0(field, " ", i, ": ")))))))
    if (length(problems))
      stop("The reply is not what was asked for: ",
           paste(utils::head(problems, 4), collapse = "; "), ".", call. = FALSE)
    # A rule is a sentence of its own, so it needs no lead-in.
    said = unlist(purrr::map(spec$rules, function(r) do.call(REPLY_RULES[[r]], c(list(obj), extra))))
    if (length(said)) stop(paste(said, collapse = " "), call. = FALSE)
    invisible(obj)
  }
}


# ---- an item, read with defaults -----------------------------------------------------

ITEM_DEFAULTS <- list(
  id = "", domain = "", intro = "", stem = "", options = list(), open_format = "",
  parts = list(), programming = "", decisions = list(), source_english = "", notes = "")

# One item with every field present, so a screen never meets a missing one. A null
#   becomes the default as well as an absent field.
full_item <- function(it)
  purrr::imap(ITEM_DEFAULTS, function(d, k) it[[k]] %||% d)

# Everything an item says, as one string, for the pattern checks below. The
#   notes are left out: they are about the item, not part of it.
item_text <- function(it) {
  it = full_item(it)
  parts = purrr::map(it$parts, function(p) c(p$stem %||% "", unlist(p$options)))
  paste(c(it$intro, it$stem, unlist(it$options), unlist(parts)), collapse = "\n")
}


# ---- coded format defaults (DESIGN.md section 7) -------------------------------------

# Pattern lists, one per output language, English first. A language that has no
#   list is "not coded": the cell says so, instead of guessing from words R
#   cannot read. Adding a language is one entry in each. Matched without regard
#   to case, with a curly apostrophe read as a straight one.
DONT_KNOW_PATTERNS <- list(
  english = c("don't know", "do not know", "\\bdk\\b", "no opinion", "not sure",
              "unsure", "can't (say|choose|decide)", "cannot (say|choose|decide)",
              "not applicable", "\\bn/a\\b", "does not apply", "no view",
              "haven't (decided|thought)"))

REFERENCE_PERIOD_PATTERNS <- list(
  english = c("\\b(past|last|previous|preceding) (\\d+|one|two|three|four|five|six|seven|ten|twelve|few|several) ?(hours?|days?|weeks?|months?|years?)",
              "\\b(past|last|previous|preceding) (hour|day|week|month|year|night)\\b",
              "\\byesterday\\b", "\\btoday\\b", "\\bthis (week|month|year|morning)\\b",
              "\\bsince\\b"))

# What an item's own `decisions` say about labelling every point. Self-reported:
#   the model wrote it, and R does not check it against the options. The
#   decisions are always written in English, whatever the output language.
LABEL_NO_PATTERNS <- c("end ?points?[^.;]{0,25}only", "only[^.;]{0,15}end ?points?",
                       "only the (end|first|last)", "numeric(al)? only", "numbers only",
                       "unlabell?ed", "not (all )?labell?ed", "no (verbal )?labels?")
LABEL_YES_PATTERNS <- c("(fully|all|every|each)[^.;]{0,40}labell?ed", "labell?ed[^.;]{0,20}(all|every|each)",
                        "every (point|option|response)[^.;]{0,30}label", "verbal label",
                        "label (every|each|all)", "all labels? (are |is )?present",
                        "labels? (are |is )?(all )?present")

matches_any <- function(patterns, txt)
  any(purrr::map_lgl(patterns, function(p) grepl(p, txt, ignore.case = TRUE, perl = TRUE)))

plain_apostrophe <- function(x) gsub("[\u2018\u2019]", "'", x)

# One item's defaults, coded from its JSON and nothing else:
#   format       "open" or "closed"
#   n_options    options listed
#   n_points     options that are scale points: not a don't-know, no-opinion or
#                not-applicable option (English only; NA elsewhere)
#   points_odd   whether that number is odd (NA for an open item, and where the
#                points cannot be told from the other options). R does not call
#                an odd count a midpoint: a unipolar scale from "none" to "a lot"
#                has five points and no midpoint.
#   midpoint_stated  what the item's own `decisions` say about a midpoint: "yes",
#                "no" or "not stated". Self-reported.
#   dont_know    such an option is there (NA for an open item, and where there
#                is no pattern list for the output language)
#   ref_period   the stem or its lead-in names a period (NA with no list)
#   labels       "yes", "no" or "not stated", from the item's own decisions
#   decisions    "itemised" (two or more separate entries), "not itemised" (one
#                string or one entry, as a model writes when it runs them all
#                together) or "none"
# NA means "not coded", and is shown as that.
code_defaults <- function(item, output_language = "English") {
  it = full_item(item)
  lang = lang_key(if (form_blank(output_language)) "English" else output_language)
  options = plain_apostrophe(as.character(unlist(it$options)))
  closed = length(options) > 0L
  dk_patterns = DONT_KNOW_PATTERNS[[lang]]
  period_patterns = REFERENCE_PERIOD_PATTERNS[[lang]]

  is_dk = if (closed && !is.null(dk_patterns))
    purrr::map_lgl(options, function(o) matches_any(dk_patterns, o))
  n_points = if (closed && !is.null(dk_patterns)) sum(!is_dk) else NA_integer_
  entries = as.character(unlist(it$decisions))
  decisions = paste(plain_apostrophe(entries), collapse = " ; ")
  heads = plain_apostrophe(paste(it$intro, it$stem))

  list(format = if (closed) "closed" else "open",
       n_options = length(options),
       n_points = as.integer(n_points),
       points_odd = if (closed && !is.na(n_points)) n_points %% 2L == 1L else NA,
       midpoint_stated = if (matches_any(MIDPOINT_NO_PATTERNS, decisions)) "no"
                         else if (matches_any(MIDPOINT_YES_PATTERNS, decisions)) "yes"
                         else "not stated",
       dont_know = if (closed && !is.null(dk_patterns)) any(is_dk) else NA,
       ref_period = if (!is.null(period_patterns)) matches_any(period_patterns, heads) else NA,
       labels = if (!closed) "not stated"
                else if (matches_any(LABEL_NO_PATTERNS, decisions)) "no"
                else if (matches_any(LABEL_YES_PATTERNS, decisions)) "yes"
                else "not stated",
       decisions = if (!length(entries)) "none"
                   else if (is.list(it$decisions) && length(it$decisions) >= 2L) "itemised"
                   else "not itemised")
}

# What an item's own decisions say about a midpoint.
MIDPOINT_NO_PATTERNS <- c("\\bno (mid-?point|middle|neutral)", "without (a )?(mid-?point|middle|neutral)",
                          "(omit|omitted|exclude|excluded)[^.;]{0,20}(mid-?point|middle|neutral)",
                          "mid-?point:? ?no\\b",
                          "(not|n't) (offer|include|use|have|provide)[^.;]{0,20}(mid-?point|middle|neutral)")
MIDPOINT_YES_PATTERNS <- c("mid-?point", "middle (option|category|position|point|answer)",
                           "neutral (option|category|point)")

# The coded defaults as label -> words, for a table.
defaults_labels <- function(d) {
  yes_no = function(x) if (is.na(x)) "not coded" else if (x) "yes" else "no"
  c("Format" = d$format,
    "Options listed" = as.character(d$n_options),
    "Scale points (no-answer options not counted)" = if (is.na(d$n_points)) "not coded" else as.character(d$n_points),
    "Odd number of points" = yes_no(d$points_odd),
    "Midpoint, as the item states it (self-reported)" = d$midpoint_stated,
    "Don't know / no opinion" = yes_no(d$dont_know),
    "Reference period" = yes_no(d$ref_period),
    "Every point labelled (self-reported)" = d$labels,
    "Design decisions" = d$decisions)
}


# ---- checks on an appraisal ------------------------------------------------------------

# A fail or a finding rated below this goes in a collapsed list, and does not
#   count against an item when a merged option or the clean items are drawn up
#   (pm_appraise.md, evaluate.md; DESIGN.md section 13).
SEVERITY_SHOWN <- 5L

# The three bands a finding or a fail is shown in, highest first (DESIGN.md
#   section 14): 7 and above "Fix before fielding", 5 and 6 "Needs your
#   judgment", below 5 "Minor" (collapsed). The cut at 5 stays what it was; a
#   finding with no severity is shown, so it goes in the middle band.
SEVERITY_FIX <- 7L
SEVERITY_BANDS <- c(fix = "Fix before fielding", judgment = "Needs your judgment",
                    minor = "Minor")

# The band id ("fix", "judgment" or "minor") of each severity.
severity_band <- function(severity)
  ifelse(is.na(severity) | (severity >= SEVERITY_SHOWN & severity < SEVERITY_FIX), "judgment",
         ifelse(severity >= SEVERITY_FIX, "fix", "minor"))

# The appraisal is the project manager's, so R checks what it can without a model
#   (DESIGN.md section 7). candidates is the drafts the appraiser saw, named by
#   letter; checklist is the named vector it was sent. Returns:
#   fails            one row per fail the appraiser reported on an item, with its
#                    severity, whether it is shown (severity 5 or more, or none
#                    given), and whether its `check` is an id that was sent
#   set_fails        the same for the fails about a candidate's set of items
#   unknown_checks   ids it cited that were not sent
#   not_appraised    "letter|id" of items it gave no entry. The skill has it
#                    report only failures, so a missing entry would otherwise
#                    read as a pass.
#   unknown_items    entries for an item no candidate has
#   merged_problems  merged items that do not exist, or that have a fail shown
check_appraisal <- function(reply, candidates, checklist) {
  entries = reply$appraisal %||% list()
  key = function(letter, id) if (length(id)) paste(letter, id, sep = "|") else character(0)
  expected = unlist(purrr::imap(candidates, function(r, letter)
    key(letter, purrr::map_chr(r$items, function(it) it$id %||% ""))), use.names = FALSE)
  entry_keys = purrr::map_chr(entries, function(e) key(e$candidate %||% "", e$id %||% ""))

  row = function(f, candidate, id, items = NULL)
    list(candidate = candidate, id = id, items = items,
         check = as.character(f$check %||% ""), evidence = as.character(f$evidence %||% ""),
         stage = as.character(f$stage %||% ""), why = as.character(f$why %||% ""),
         severity = if (is.numeric(f$severity)) f$severity else NA_real_,
         shown = !is.numeric(f$severity) || f$severity >= SEVERITY_SHOWN,
         known = as.character(f$check %||% "") %in% names(checklist))
  fails = purrr::list_flatten(purrr::map(entries, function(e)
    purrr::map(e$fails, function(f) row(f, e$candidate %||% "", e$id %||% ""))))
  set_fails = purrr::map(reply$set_fails %||% list(), function(f)
    row(f, f$candidate %||% "", "", paste(unlist(f$items), collapse = ", ")))
  failed_keys = unique(purrr::map_chr(purrr::keep(fails, function(f) f$shown),
                                      function(f) key(f$candidate, f$id)))

  merged = purrr::keep(reply$merged %||% list(), function(m)
    nzchar(m$candidate %||% "") && nzchar(m$id %||% ""))
  merged_problems = unlist(purrr::map(merged, function(m) {
    k = key(m$candidate, m$id)
    if (!k %in% expected) paste0("Merged item ", m$candidate, " ", m$id, " is not in any candidate.")
    else if (k %in% failed_keys) paste0("Merged item ", m$candidate, " ", m$id,
                                         " has a fail rated 5 or above.")
  }))

  all_fails = c(fails, set_fails)
  list(fails = fails, set_fails = set_fails,
       unknown_checks = unique(purrr::map_chr(purrr::discard(all_fails, function(f) f$known), "check")),
       not_appraised = setdiff(expected, entry_keys),
       unknown_items = setdiff(entry_keys, expected),
       merged_problems = merged_problems %||% character(0))
}


# ---- a long questionnaire, in parts (DESIGN.md section 14) ---------------------------------

# The questionnaire split on blank lines into blocks (a block is a question with its
#   options), and whole blocks packed, in order, into parts of at most max_chars
#   characters. Joining the parts with a blank line gives the text back, when the
#   text separates its blocks by one blank line (a longer run of blank lines counts
#   as one). A block longer than max_chars stops with a message quoting its first
#   words, since it cannot be split without cutting a question. The result is the
#   parts as a character vector, with the attribute "first_block": the number of
#   each part's first block among all the blocks.
split_questionnaire <- function(text, max_chars) {
  blocks = strsplit(trimws(gsub("\r\n?", "\n", text)), "\n[ \t]*\n\\s*", perl = TRUE)[[1]]
  too_long = which(nchar(blocks) > max_chars)
  if (length(too_long))
    stop("Block ", too_long[[1]], " of the questionnaire is ", format(nchar(blocks[[too_long[[1]]]]), big.mark = ","),
         " characters, over the ", format(max_chars, big.mark = ","), " a call can take, and a block is never cut. ",
         "Leave a blank line between questions so that it can be split. It starts: \"",
         substr(blocks[[too_long[[1]]]], 1, 60), "\".", call. = FALSE)
  packed = purrr::reduce(seq_along(blocks), function(acc, i) {
    n = length(acc$parts)
    joined = if (n) paste(acc$parts[[n]], blocks[[i]], sep = "\n\n")
    if (n && nchar(joined) <= max_chars) {
      acc$parts[[n]] = joined
      acc
    } else list(parts = c(acc$parts, blocks[[i]]), first = c(acc$first, i))
  }, .init = list(parts = list(), first = integer(0)))
  structure(unlist(packed$parts), first_block = packed$first)
}

# The calls a review of this questionnaire takes, in order. One part: a single call
#   of kind "all", the whole review as in Phase 4. More than one: an "items" call
#   for each part, then an "instrument" call. Each is list(kind, k, n, first_block,
#   text), and the instrument call's text is the whole questionnaire.
review_plan <- function(text, max_chars) {
  parts = split_questionnaire(text, max_chars)
  n = length(parts)
  if (n <= 1L) return(list(list(kind = "all", k = 1L, n = 1L, first_block = 1L, text = text)))
  c(purrr::imap(unname(as.list(parts)), function(p, k)
      list(kind = "items", k = k, n = n, first_block = attr(parts, "first_block")[[k]], text = p)),
    list(list(kind = "instrument", k = n + 1L, n = n, first_block = 1L, text = text)))
}


# ---- checks on a review ------------------------------------------------------------------

# How evidence is compared with the pasted text (DESIGN.md sections 7 and 14): case
#   and runs of white space ignored, curly and straight quotes alike. A model told
#   to copy words exactly sometimes wraps them in quotation marks, so a quote
#   around the whole of the evidence is dropped (evidence_quote()).
normalise_quote <- function(x)
  gsub("\\s+", " ", tolower(trimws(plain_apostrophe(gsub("[“”]", "\"", x)))))

# The evidence as it is looked for in the text: normalised, then without quotation
#   marks at either end. An ellipsis is not removed, so evidence that has one is
#   not found: evaluate.md asks for words copied exactly.
evidence_quote <- function(x)
  trimws(gsub("^[\"']+|[\"']+$", "", normalise_quote(x)))

# The review's findings, one row each, whether about a question or the instrument:
#   item            the question's id, or "" for an instrument finding
#   scope           "question" or "instrument"
#   position        the question's place in the reply (0 for the instrument), so
#                   two questions with one id are still told apart
#   check           the id it cites
#   severity        1 to 10 (NA if none given)
#   shown           severity 5 or more, or none given
#   evidence        what it quoted
#   evidence_found  the quote occurs in the pasted text (NA for an instrument
#                   finding, whose evidence is a list of question ids). One that
#                   does not is flagged, not dropped.
#   check_known     the check is an id in the CHECKLIST that was sent
#   stage, problem, rewrite, rewrite_english, probe   as written
check_review <- function(reply, form) {
  f = clean_form(form)
  sent = names(build_checklist(f))
  text = normalise_quote(f$questionnaire)
  as_text = function(x) paste(unlist(x %||% ""), collapse = " ")
  found = function(ev) {
    q = evidence_quote(as_text(ev))
    nzchar(q) && grepl(q, text, fixed = TRUE)
  }
  one = function(x, item, scope, position)
    list(item = item, scope = scope, position = position, check = as_text(x$check),
         severity = if (is.numeric(x$severity)) x$severity else NA_real_,
         evidence = as_text(x$evidence),
         evidence_found = if (scope == "question") found(x$evidence) else NA,
         check_known = as_text(x$check) %in% sent, stage = as_text(x$stage),
         problem = as_text(x$problem), rewrite = as_text(x$rewrite),
         rewrite_english = as_text(x$rewrite_english), probe = as_text(x$probe))
  rows = c(
    purrr::list_flatten(purrr::imap(unname(reply$items %||% list()), function(it, i)
      purrr::map(it$findings %||% list(), function(x) one(x, as_text(it$id), "question", i)))),
    purrr::map(reply$instrument %||% list(), function(x) one(x, "", "instrument", 0L)))
  d = data.frame(item = purrr::map_chr(rows, "item"), scope = purrr::map_chr(rows, "scope"),
                 position = purrr::map_int(rows, "position"),
                 check = purrr::map_chr(rows, "check"), severity = purrr::map_dbl(rows, "severity"),
                 evidence = purrr::map_chr(rows, "evidence"),
                 evidence_found = purrr::map_lgl(rows, "evidence_found"),
                 check_known = purrr::map_lgl(rows, "check_known"), stage = purrr::map_chr(rows, "stage"),
                 problem = purrr::map_chr(rows, "problem"), rewrite = purrr::map_chr(rows, "rewrite"),
                 rewrite_english = purrr::map_chr(rows, "rewrite_english"),
                 probe = purrr::map_chr(rows, "probe"), stringsAsFactors = FALSE)
  d$shown = is.na(d$severity) | d$severity >= SEVERITY_SHOWN
  d
}
