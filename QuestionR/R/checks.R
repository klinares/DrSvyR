# checks.R for QuestionR
# What R checks and codes for itself, so no model is trusted with it (DESIGN.md
#   sections 7 and 12): the shape of every reply and the validators built from
#   it, the item count, the coded format defaults, and the checks on the reviewer's
#   recommendation. No Shiny and no model call in here; every function takes the
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
# Only what R itself reads is required. A field a reflex file asks for and R does not
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
                          options = "list?", open_format = "string?")),
    rules = c("item_count", "options_or_open")),
  # The reviewer's recommendation: which items, by candidate letter and id, and for each at most one
  #   line to check before use (DESIGN.md section 18).
  appraisal = list(
    fields = c(selected = "list"),
    each = list(selected = c(domain = "text", candidate = "text", id = "id", check_before_use = "string?")),
    rules = c("selection_valid")),
  # A review of pasted text (the Evaluate task): for each question a verdict and, for Revise, up to
  #   two problems with a rewrite; and points about the questionnaire as a whole. A rule reads the
  #   problems, which sit one level further down than `each` reaches.
  review = list(
    fields = c(items = "list", instrument = "list"),
    each = list(items = c(id = "id", verdict = "text")),
    rules = c("review_entries")))

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
             " ", if (n_items == 1L) "was" else "were", " asked for.")
  },
  # An item is closed (it has options) or open (it says what is entered).
  options_or_open = function(obj, ...) {
    bad = purrr::keep(obj$items, function(it)
      !length(it$options) && !type_ok(it$open_format, "text"))
    if (length(bad))
      paste0("Item ", paste(purrr::map_chr(bad, function(it) it$id %||% "?"), collapse = ", "),
             " has neither options nor an open_format.")
  },
  # The recommendation names items that are in the drafts, none twice, and no more than were
  #   asked for. candidates is the drafts by letter, n_items the number asked for.
  selection_valid = function(obj, candidates = NULL, n_items = NULL, ...) {
    sel = obj$selected
    label = function(e) paste0("item ", e$id, " of candidate ", e$candidate)
    keys = purrr::map_chr(sel, function(e) paste(e$candidate, as.character(e$id), sep = "|"))
    unknown = if (!is.null(candidates)) purrr::keep(sel, function(e)
      !as.character(e$id) %in% purrr::map_chr(candidates[[as.character(e$candidate)]]$items,
                                              function(it) as.character(it$id %||% "")))
    c(if (length(unknown))
        paste0("The reply recommends ", paste(purrr::map_chr(unknown, label), collapse = ", "),
               ", which ", if (length(unknown) == 1L) "is" else "are", " not among the drafts."),
      if (anyDuplicated(keys))
        paste0("The reply recommends the same item more than once: ",
               paste(purrr::map_chr(sel[duplicated(keys)], label), collapse = ", "), "."),
      if (!is.null(n_items) && length(sel) > n_items)
        paste0("The reply recommends ", length(sel), " items; ", n_items, " ",
               if (n_items == 1L) "was" else "were", " asked for."))
  },
  # A verdict is Keep or Revise. A Revise has at least one problem with its sentence, and every
  #   point about the questionnaire as a whole is a sentence.
  review_entries = function(obj, ...) {
    verdict = function(it) tolower(trimws(paste(unlist(it$verdict %||% ""), collapse = " ")))
    bad_verdict = purrr::keep(obj$items, function(it) !verdict(it) %in% c("keep", "revise"))
    thin = purrr::keep(obj$items, function(it)
      identical(verdict(it), "revise") &&
        !any(purrr::map_lgl(it$problems %||% list(), function(p) is.list(p) && type_ok(p$problem, "text"))))
    bad_points = !all(purrr::map_lgl(obj$instrument, function(x)
      (is.character(x) && length(x) == 1L && nzchar(trimws(x))) || (is.list(x) && length(unlist(x)) > 0L)))
    ids = function(its) paste(purrr::map_chr(its, function(it) paste("question", paste(unlist(it$id %||% "?"), collapse = " "))), collapse = ", ")
    c(if (length(bad_verdict))
        paste0("The verdict for ", ids(bad_verdict), " must be \"Keep\" or \"Revise\"."),
      if (length(thin))
        paste0("A \"Revise\" for ", ids(thin), " gives no problem. Give the problem in one sentence, ",
               "or say \"Keep\"."),
      if (bad_points) "Each point about the questionnaire as a whole must be one sentence of text.")
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
  parts = list(), programming = "", decisions = list(), notes = "")

# One item with every field present, so a screen never meets a missing one. A null
#   becomes the default as well as an absent field.
full_item <- function(it)
  purrr::imap(ITEM_DEFAULTS, function(d, k) it[[k]] %||% d)


# ---- what the analyst is shown ---------------------------------------------------------------

# What the analyst is shown is short (DESIGN.md section 18). The models are asked for one
#   sentence of 20 words or fewer; R holds them to it, so a longer remark is cut to its first
#   sentence and, if that is still long, to its first 20 words. The full reply stays in the record.
CHECK_WORDS <- 20L
MAX_PROBLEMS <- 2L   # problems shown for one question
MAX_POINTS <- 3L     # points shown about the questionnaire as a whole

# The first sentence of a text, on one line. A sentence ends at . ! or ? followed by a space and a
#   capital letter, a quote or a bracket.
first_sentence <- function(x) {
  x = trimws(gsub("\\s+", " ", paste(unlist(x %||% ""), collapse = " ")))
  sub("^(.+?[.!?])\\s+(?=[A-Z\"'(]).*$", "\\1", x, perl = TRUE)
}

cap_words <- function(x, n = CHECK_WORDS) {
  w = strsplit(x, " ", fixed = TRUE)[[1]]
  if (length(w) > n) paste0(paste(w[seq_len(n)], collapse = " "), "…") else x
}

# One remark as it is shown: its first sentence, in 20 words or fewer.
one_line <- function(x, n = CHECK_WORDS) cap_words(first_sentence(x), n)

# The reviewer's recommendation is the project manager's, so R checks what it can without a
#   model (DESIGN.md sections 7, 16 and 18). candidates is the drafts the reviewer saw, named by
#   letter. The reviewer returns candidate letters and item ids, and for each a line to check
#   before use: R finds each item in its draft, and copies the wording from there. Returns
#   `selected`, one entry per recommended item in the order given: candidate, id, the item's
#   position in that candidate's items, domain, and `check`, the line to check before use (one
#   sentence of 20 words or fewer, "" when there is none). An item that cannot be found is left
#   out (the validator refuses such a reply, so none is). No other field of the reply is read.
check_appraisal <- function(reply, candidates) {
  ids_of = function(letter) purrr::map_chr(candidates[[letter]]$items, function(it) as.character(it$id %||% ""))
  selected = purrr::map(reply$selected %||% list(), function(e)
    list(candidate = as.character(e$candidate), id = as.character(e$id),
         position = match(as.character(e$id), ids_of(as.character(e$candidate))),
         domain = as.character(e$domain %||% ""), check = one_line(e$check_before_use)))
  list(selected = purrr::discard(selected, function(e) is.na(e$position)))
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
#   of kind "all", the whole review. More than one: an "items" call
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


# ---- the review, as the analyst is shown it -----------------------------------------------

# The text of each question as it was pasted, for the ids the review gave, in order. A
#   questionnaire with a blank line between its questions (what the Brief tab asks for) gives
#   its blocks when they are as many as the ids. Otherwise each question is the run of lines
#   from the line that begins with its id to the line before the next one's. A question that
#   cannot be found is "".
pasted_questions <- function(questionnaire, ids) {
  txt = trimws(gsub("\r\n?", "\n", questionnaire))
  blocks = strsplit(txt, "\n[ \t]*\n\\s*", perl = TRUE)[[1]]
  if (length(blocks) == length(ids)) return(trimws(blocks))
  lines = strsplit(txt, "\n", fixed = TRUE)[[1]]
  escape = function(s) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", s)
  # A line that begins with the id and a full stop, bracket or colon, else one that begins with the id
  #   alone (an option "2 No" is not question 2 when "2. Second?" is further on).
  find_start = function(id, from) {
    at_of = function(pat) which(grepl(pat, lines, ignore.case = TRUE, perl = TRUE) & seq_along(lines) >= from)
    at = at_of(paste0("^\\s*\\(?", escape(id), "[.):](\\s|$)"))
    if (!length(at)) at = at_of(paste0("^\\s*\\(?", escape(id), "(\\s|$)"))
    if (length(at)) at[[1]] else NA_integer_
  }
  starts = purrr::reduce(ids, function(acc, id)
    c(acc, find_start(id, if (any(!is.na(acc))) max(acc, na.rm = TRUE) + 1L else 1L)), .init = integer(0))
  ends = purrr::map_int(seq_along(starts), function(i) {
    later = starts[seq_along(starts) > i & !is.na(starts)]
    if (length(later)) min(later) - 1L else length(lines)
  })
  purrr::map_chr(seq_along(starts), function(i)
    if (is.na(starts[[i]])) "" else trimws(paste(lines[starts[[i]]:ends[[i]]], collapse = "\n")))
}

# The review as the analyst is shown it (DESIGN.md section 18), from the parsed reply and the
#   questionnaire as pasted. Per question: its id, its text as pasted, "Keep" or "Revise" and, for
#   Revise, at most two problems (the first two given, most serious first), each cut to one line,
#   with the suggested rewrite. `keep` is the ids of the questions marked Keep. `instrument` is at
#   most three points about the questionnaire as a whole, one sentence each. A Revise with no
#   problem is a Keep. No other field of the reply is read.
shape_review <- function(reply, questionnaire) {
  items = unname(reply$items %||% list())
  ids = purrr::map_chr(items, function(it) paste(unlist(it$id %||% ""), collapse = " "))
  texts = pasted_questions(questionnaire, ids)
  questions = purrr::pmap(list(items, ids, texts), function(it, id, text) {
    probs = purrr::map(it$problems %||% list(), function(p)
      list(problem = one_line(p$problem), rewrite = trimws(paste(unlist(p$rewrite %||% ""), collapse = " "))))
    probs = utils::head(purrr::keep(probs, function(p) nzchar(p$problem)), MAX_PROBLEMS)
    revise = identical(tolower(trimws(paste(unlist(it$verdict %||% ""), collapse = " "))), "revise") && length(probs) > 0L
    list(id = id, text = text, verdict = if (revise) "Revise" else "Keep", problems = if (revise) probs else list())
  })
  points = purrr::map_chr(utils::head(reply$instrument %||% list(), MAX_POINTS), first_sentence)
  list(questions = questions,
       keep = purrr::map_chr(purrr::keep(questions, function(q) identical(q$verdict, "Keep")), "id"),
       instrument = points[nzchar(points)])
}
