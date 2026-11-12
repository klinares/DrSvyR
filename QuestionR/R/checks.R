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
    fields = c(appraisal = "list", coverage = "list", differences = "list",
               merged = "list", test_first = "list", limits = "string"),
    each = list(appraisal = c(candidate = "text", id = "text", fails = "list")),
    rules = c("fail_entries")))

TYPE_WORDS <- c(text = "a non-empty string", string = "a string",
                logical = "true or false", list = "a list")

type_ok <- function(x, type) {
  optional = endsWith(type, "?")
  if (is.null(x)) return(optional)
  switch(sub("?", "", type, fixed = TRUE),
         text = is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x)),
         string = is.character(x) && length(x) == 1L && !is.na(x),
         logical = is.logical(x) && length(x) == 1L && !is.na(x),
         list = is.list(x),
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
  # Every fail in an appraisal names the check it fails.
  fail_entries = function(obj, ...) {
    bad = purrr::keep(obj$appraisal, function(e)
      !all(purrr::map_lgl(e$fails, function(f) is.list(f) && type_ok(f$check, "text"))))
    if (length(bad))
      paste0("A fail for ", paste(purrr::map_chr(bad, function(e)
        paste0(e$candidate, " ", e$id)), collapse = ", "), " does not name its check.")
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
                        "every (point|option)[^.;]{0,30}label", "verbal label")

matches_any <- function(patterns, txt)
  any(purrr::map_lgl(patterns, function(p) grepl(p, txt, ignore.case = TRUE, perl = TRUE)))

plain_apostrophe <- function(x) gsub("[\u2018\u2019]", "'", x)

# One item's defaults, coded from its JSON and nothing else:
#   format       "open" or "closed"
#   n_options    options listed
#   n_points     options that are scale points: not a don't-know, no-opinion or
#                not-applicable option (English only; NA elsewhere)
#   midpoint     an odd number of points, from the count alone, so an unordered
#                list of three codes as a midpoint too (NA for an open item, and
#                where the points cannot be told from the other options)
#   dont_know    such an option is there (NA for an open item, and where there
#                is no pattern list for the output language)
#   ref_period   the stem or its lead-in names a period (NA with no list)
#   labels       "yes", "no" or "not stated", from the item's own decisions
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
  decisions = paste(plain_apostrophe(as.character(unlist(it$decisions))), collapse = " ; ")
  heads = plain_apostrophe(paste(it$intro, it$stem))

  list(format = if (closed) "closed" else "open",
       n_options = length(options),
       n_points = as.integer(n_points),
       midpoint = if (closed && !is.na(n_points)) n_points >= 3L && n_points %% 2L == 1L
                  else NA,
       dont_know = if (closed && !is.null(dk_patterns)) any(is_dk) else NA,
       ref_period = if (!is.null(period_patterns)) matches_any(period_patterns, heads) else NA,
       labels = if (!closed) "not stated"
                else if (matches_any(LABEL_NO_PATTERNS, decisions)) "no"
                else if (matches_any(LABEL_YES_PATTERNS, decisions)) "yes"
                else "not stated")
}

# The coded defaults as label -> words, for a table.
defaults_labels <- function(d) {
  yes_no = function(x) if (is.na(x)) "not coded" else if (x) "yes" else "no"
  c("Format" = d$format,
    "Options listed" = as.character(d$n_options),
    "Scale points" = if (is.na(d$n_points)) "not coded" else as.character(d$n_points),
    "Midpoint (odd count)" = yes_no(d$midpoint),
    "Don't know / no opinion" = yes_no(d$dont_know),
    "Reference period" = yes_no(d$ref_period),
    "Every point labelled (self-reported)" = d$labels)
}


# ---- checks on an appraisal ------------------------------------------------------------

# The appraisal is the project manager's, so R checks what it can without a model
#   (DESIGN.md section 7). candidates is the drafts the appraiser saw, named by
#   letter; checklist is the named vector it was sent. Returns:
#   fails            one row per fail the appraiser reported, with whether its
#                    `check` is an id in the checklist that was sent
#   unknown_checks   ids it cited that were not sent
#   not_appraised    "letter|id" of items it gave no entry. The skill has it
#                    report only failures, so a missing entry would otherwise
#                    read as a pass.
#   unknown_items    entries for an item no candidate has
#   merged_problems  merged items that do not exist, or that failed a check
check_appraisal <- function(reply, candidates, checklist) {
  entries = reply$appraisal %||% list()
  key = function(letter, id) if (length(id)) paste(letter, id, sep = "|") else character(0)
  expected = unlist(purrr::imap(candidates, function(r, letter)
    key(letter, purrr::map_chr(r$items, function(it) it$id %||% ""))), use.names = FALSE)
  entry_keys = purrr::map_chr(entries, function(e) key(e$candidate %||% "", e$id %||% ""))

  fails = purrr::list_flatten(purrr::map(entries, function(e)
    purrr::map(e$fails, function(f)
      list(candidate = e$candidate %||% "", id = e$id %||% "",
           check = as.character(f$check %||% ""), evidence = as.character(f$evidence %||% ""),
           stage = as.character(f$stage %||% ""), why = as.character(f$why %||% ""),
           known = as.character(f$check %||% "") %in% names(checklist)))))
  failed_keys = unique(purrr::map_chr(fails, function(f) key(f$candidate, f$id)))

  merged = purrr::keep(reply$merged %||% list(), function(m)
    nzchar(m$candidate %||% "") && nzchar(m$id %||% ""))
  merged_problems = unlist(purrr::map(merged, function(m) {
    k = key(m$candidate, m$id)
    if (!k %in% expected) paste0("Merged item ", m$candidate, " ", m$id, " is not in any candidate.")
    else if (k %in% failed_keys) paste0("Merged item ", m$candidate, " ", m$id,
                                         " failed a check the appraiser reported.")
  }))

  list(fails = fails,
       unknown_checks = unique(purrr::map_chr(purrr::discard(fails, function(f) f$known), "check")),
       not_appraised = setdiff(expected, entry_keys),
       unknown_items = setdiff(entry_keys, expected),
       merged_problems = merged_problems %||% character(0))
}
