# checks.R for QuestionR
# What R checks and builds for itself, so no model is trusted with it: the shape and limits of every
#   reply, the questions and parts of a pasted questionnaire, the quote check, and the review as the
#   analyst is shown it, down to its bottom line. Function definitions and constants only.


# ---- reply schemas ---------------------------------------------------------------

# What a reply must hold, per kind of call: fields (top-level field -> type), each (for a list of
#   objects, field -> type), rules (REPLY_RULES run once the shape is right). Types: text (non-empty),
#   string, list, id (a label or a number); a trailing "?" lets a field be missing.
REPLY_SCHEMAS <- list(
  draft = list(
    fields = c(items = "list", not_covered = "list?", needs_from_analyst = "list?"),
    each = list(items = c(id = "text", domain = "text", intro = "string?", stem = "text", options = "list?",
                          open_format = "string?", parts = "list?", programming = "string?", why = "string?")),
    rules = c("item_count", "options_or_open", "item_limits")),
  refine = list(
    fields = c(items = "list", not_covered = "list?", needs_from_analyst = "list?"),
    each = list(items = c(id = "text", domain = "string?", intro = "string?", stem = "text", options = "list?",
                          open_format = "string?", parts = "list?", programming = "string?", changes = "string?")),
    rules = c("item_count", "options_or_open", "item_limits")),
  items = list(
    fields = c(items = "list"),
    each = list(items = c(id = "id", flags = "list", rewrite = "string")),
    rules = c("question_count", "flags_valid")),
  instrument = list(
    fields = c(instrument = "list"),
    each = list(instrument = c(check = "text", stage = "text", level = "text", questions = "list", why = "text")),
    rules = c("instrument_valid")))

# The limits R holds a review to. MAX_FLAGS is a guard against a runaway reply, not a target.
MAX_FLAGS <- 8L
MAX_WHY_WORDS <- 30L
MAX_CHANGES_WORDS <- 20L
MAX_INSTRUMENT_FLAGS <- 3L
STAGES <- c("comprehension", "retrieval", "judgment", "reporting")
LEVELS <- c("fix", "consider")

TYPE_WORDS <- c(text = "a non-empty string", string = "a string", list = "a list", id = "a question label or number")

type_ok <- function(x, type) {
  if (is.null(x)) return(endsWith(type, "?"))
  switch(sub("?", "", type, fixed = TRUE),
         text = is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x)),
         string = is.character(x) && length(x) == 1L && !is.na(x),
         list = is.list(x),
         id = (is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x))) ||
           (is.numeric(x) && length(x) == 1L && !is.na(x)),
         FALSE)
}

# The problems with one object against a field -> type spec, as sentences.
field_problems <- function(obj, spec, where = "") {
  if (!is.list(obj)) return(paste0(where, "is not a JSON object"))
  bad = purrr::keep(names(spec), function(k) !type_ok(obj[[k]], spec[[k]]))
  purrr::map_chr(bad, function(k)
    paste0(where, "'", k, "' ", if (is.null(obj[[k]])) "is missing"
           else paste0("must be ", TYPE_WORDS[[sub("?", "", spec[[k]], fixed = TRUE)]])))
}

n_words <- function(x) length(strsplit(trimws(x), "\\s+")[[1]])

# What is wrong with one flag, as sentences. checks is the ids of the CHECKLIST sent;
#   quoted says whether the flag cites words ("quote") or questions ("questions").
flag_problems <- function(fl, checks, where, quoted = TRUE) {
  if (!is.list(fl)) return(paste0(where, "is not a JSON object"))
  txt = function(k) if (type_ok(fl[[k]], "text")) trimws(fl[[k]]) else ""
  c(if (!txt("check") %in% checks) paste0(where, "cites the check '", txt("check"), "', which is not in the CHECKLIST"),
    if (!tolower(txt("stage")) %in% STAGES) paste0(where, "has the stage '", txt("stage"), "'; it must be one of ", paste(STAGES, collapse = ", ")),
    if (!tolower(txt("level")) %in% LEVELS) paste0(where, "has the level '", txt("level"), "'; it must be fix or consider"),
    if (quoted && !nzchar(txt("quote"))) paste0(where, "has no quote"),
    if (!quoted && !length(fl$questions)) paste0(where, "names no question"),
    if (!nzchar(txt("why"))) paste0(where, "has no why")
    else if (n_words(txt("why")) > MAX_WHY_WORDS) paste0(where, "has a why of ", n_words(txt("why")), " words; keep it to 25"))
}

# Checks that need more than a field's type. Each takes the parsed reply and the extra
#   arguments reply_validator() was given, and returns NULL or sentences.
REPLY_RULES <- list(
  # Exactly the number asked for.
  item_count = function(obj, n_items = NULL, ...) {
    n = length(obj$items)
    if (!is.null(n_items) && n != n_items)
      paste0("The reply holds ", n, if (n == 1L) " item" else " items", "; ", n_items, " ",
             if (n_items == 1L) "was" else "were", " asked for.")
  },
  # An item is closed (it has options) or open (it says what is entered).
  options_or_open = function(obj, ...) {
    bad = purrr::keep(obj$items, function(it) !length(it$options) && !type_ok(it$open_format, "text"))
    if (length(bad))
      paste0("Item ", paste(purrr::map_chr(bad, function(it) it$id %||% "?"), collapse = ", "),
             " has neither options nor an open_format.")
  },
  # At most three things asked of the analyst, one line of programming, every part an object with a
  #   stem, and a draft's why at most 30 words or a refine's changes at most 20.
  item_limits = function(obj, ...)
    c(if (length(obj$needs_from_analyst) > 3L) paste0("needs_from_analyst has ", length(obj$needs_from_analyst), " entries; the limit is 3"),
      unlist(purrr::imap(obj$items, function(it, i)
        c(if (type_ok(it$why, "text") && n_words(it$why) > MAX_WHY_WORDS) paste0("Item ", i, " has a why of ", n_words(it$why), " words; keep it to 25"),
          if (type_ok(it$changes, "text") && n_words(it$changes) > MAX_CHANGES_WORDS)
            paste0("Item ", i, " has changes of ", n_words(it$changes), " words; keep it to 15"),
          if (type_ok(it$programming, "text") && grepl("\n", it$programming, fixed = TRUE))
            paste0("Item ", i, " has more than one line of programming"),
          purrr::discard(purrr::imap_chr(it$parts %||% list(), function(p, j)
            if (!is.list(p) || !type_ok(p$stem, "text")) paste0("Item ", i, " part ", j, " has no stem") else NA_character_), is.na))))),
  # One entry per question of the part, so a question the model skipped is never shown as clear.
  question_count = function(obj, n_questions = NULL, ...) {
    n = length(obj$items)
    if (!is.null(n_questions) && n != n_questions)
      paste0("The reply reviews ", n, " questions; this part has ", n_questions, ". Give one entry per question, in order.")
  },
  flags_valid = function(obj, checks = character(0), ...)
    unlist(purrr::imap(obj$items, function(it, i) {
      where = paste0("Question ", i, " ")
      c(if (length(it$flags) > MAX_FLAGS) paste0(where, "has ", length(it$flags), " flags; the limit is ", MAX_FLAGS),
        unlist(purrr::imap(it$flags, function(fl, j) flag_problems(fl, checks, paste0(where, "flag ", j, " ")))))
    })),
  instrument_valid = function(obj, checks = character(0), ...)
    c(if (length(obj$instrument) > MAX_INSTRUMENT_FLAGS)
        paste0("The reply gives ", length(obj$instrument), " points about the whole; the limit is ", MAX_INSTRUMENT_FLAGS),
      unlist(purrr::imap(obj$instrument, function(fl, j) flag_problems(fl, checks, paste0("Point ", j, " "), quoted = FALSE)))))

# A validator for llm_json(): stops with a readable sentence when the reply is not what the
#   format asks for. Extra arguments go to the rules. A reply that fails is a failed attempt, so
#   it is retried, and the sentence is what the analyst reads if every attempt fails.
reply_validator <- function(format, ...) {
  spec = REPLY_SCHEMAS[[format]]
  if (is.null(spec)) stop("There is no reply schema called '", format, "'.", call. = FALSE)
  extra = list(...)
  function(obj) {
    if (!is.list(obj)) stop("The reply is not what was asked for: it is not a JSON object.", call. = FALSE)
    problems = c(field_problems(obj, spec$fields),
                 unlist(purrr::imap(spec$each, function(el_spec, field)
                   if (is.list(obj[[field]])) unlist(purrr::imap(obj[[field]], function(el, i)
                     field_problems(el, el_spec, paste0(field, " ", i, ": ")))))))
    if (length(problems))
      stop("The reply is not what was asked for: ", paste(utils::head(problems, 4), collapse = "; "), ".", call. = FALSE)
    said = unlist(purrr::map(spec$rules, function(r) do.call(REPLY_RULES[[r]], c(list(obj), extra))))
    if (length(said)) stop(paste(utils::head(said, 4), collapse = ". "), ".", call. = FALSE)
    invisible(obj)
  }
}


# ---- an item, read with defaults ---------------------------------------------------

ITEM_DEFAULTS <- list(id = "", domain = "", intro = "", stem = "", options = list(), open_format = "",
                      parts = list(), programming = "", why = "", changes = "")

# One item with every field present, so a screen never meets a missing one.
full_item <- function(it) purrr::imap(ITEM_DEFAULTS, function(d, k) it[[k]] %||% d)


# ---- a pasted questionnaire, as questions and parts ----------------------------------

# A line that starts a question: Q1. 1. 1) A1 (with an optional letter after the number).
QUESTION_LABEL <- "^\\s*(Q[0-9]+[a-z]?[.):]?|[0-9]+[a-z]?[.)]|[A-Z][0-9]+[a-z]?[.):]?)(\\s|$)"

# The questions of a pasted text: split on blank lines; a text with no blank line between
#   questions is split on the lines that start with a question label. A text that gives one
#   question either way is one question.
split_questions <- function(text) {
  txt = trimws(gsub("\r\n?", "\n", text))
  blocks = trimws(strsplit(txt, "\n[ \t]*\n\\s*", perl = TRUE)[[1]])
  if (length(blocks) > 1L) return(blocks)
  lines = strsplit(txt, "\n", fixed = TRUE)[[1]]
  starts = grepl(QUESTION_LABEL, lines, perl = TRUE)
  if (sum(starts) < 2L || !starts[[1]]) return(txt)
  unname(purrr::map_chr(split(lines, cumsum(starts)), function(l) trimws(paste(l, collapse = "\n"))))
}

# A question's own label when it starts with one (Q3, 12, A1), or its position.
question_id <- function(text, position) {
  m = regmatches(text, regexpr(QUESTION_LABEL, text, perl = TRUE))
  if (length(m)) sub("[.):]$", "", trimws(m)) else as.character(position)
}

# The calls a review of this text takes: the questions packed, in order, into parts of at most
#   max_questions questions and max_chars characters, one "items" call each; then, when there is
#   more than one question, one "instrument" call on the whole text. Each is list(kind, k, n,
#   first, ids, questions, text). A question longer than max_chars stops, since it is never cut.
review_plan <- function(text, max_questions = APP_BATCH_QUESTIONS, max_chars = APP_BATCH_CHARS) {
  qs = split_questions(text)
  long = which(nchar(qs) > max_chars)
  if (length(long))
    stop("Question ", long[[1]], " is ", format(nchar(qs[[long[[1]]]]), big.mark = ","), " characters, over the ",
         format(max_chars, big.mark = ","), " one call takes, and a question is never cut. Leave a blank line ",
         "between questions. It starts: \"", substr(qs[[long[[1]]]], 1, 60), "\".", call. = FALSE)
  starts = purrr::reduce(seq_along(qs), function(acc, i) {
    open = acc$start[length(acc$start)]
    if (length(acc$start) && i - open < max_questions && acc$chars + nchar(qs[[i]]) + 2L <= max_chars)
      list(start = acc$start, chars = acc$chars + nchar(qs[[i]]) + 2L)
    else list(start = c(acc$start, i), chars = nchar(qs[[i]]))
  }, .init = list(start = integer(0), chars = 0L))$start
  ids = purrr::imap_chr(qs, question_id)
  ends = c(starts[-1] - 1L, length(qs))
  n = length(starts)
  parts = purrr::map(seq_len(n), function(k) {
    at = starts[[k]]:ends[[k]]
    list(kind = "items", k = k, n = n, first = starts[[k]], ids = ids[at], questions = qs[at],
         text = paste(qs[at], collapse = "\n\n"))
  })
  c(parts, if (length(qs) > 1L)
    list(list(kind = "instrument", k = n + 1L, n = n, first = 1L, ids = ids, questions = qs,
              text = paste(qs, collapse = "\n\n"))))
}


# ---- the quote check -------------------------------------------------------------

# Curly quotes and dashes made plain, and runs of space made one, so a quote copied faithfully
#   is found whatever the typography. Quote marks around the whole of a quote are dropped.
normalise_quote <- function(x) {
  x = paste(unlist(x %||% ""), collapse = " ")
  x = gsub("[\u2018\u2019\u201a\u2032]", "'", x)
  x = gsub("[\u201c\u201d\u201e\u2033]", "\"", x)
  x = gsub("[\u2013\u2014]", "-", x)
  tolower(trimws(gsub("\\s+", " ", x)))
}
evidence_quote <- function(x) trimws(gsub("^[\"']+|[\"']+$", "", normalise_quote(x)))

# Whether a flag's quote is in the text it is about. A flag whose quote is not found is shown with
#   a mark, never dropped.
quote_found <- function(quote, text) {
  q = evidence_quote(quote)
  nzchar(q) && grepl(q, normalise_quote(text), fixed = TRUE)
}


# ---- the review, as the analyst is shown it -------------------------------------------

# The plain-language name of a check: its Label in the reflex file, else its id in words.
check_label <- function(id, labels = check_labels()) {
  l = labels[id]
  ifelse(is.na(l), gsub("_", " ", id), l)
}

# The review, shaped from run_review()'s result: per question its id, text as pasted, flags (check,
#   label, stage, level, quote, why, found) most damaging first, rewrite, and whether it was reviewed
#   at all (a part that did not come back leaves its questions unreviewed, never clear); and the
#   flags about the instrument as a whole.
shape_review <- function(rv, labels = check_labels()) {
  flag = function(fl, text = NULL) {
    s = function(k) trimws(paste(unlist(fl[[k]] %||% ""), collapse = " "))
    c(list(check = s("check"), label = unname(check_label(s("check"), labels)), stage = tolower(s("stage")),
           level = tolower(s("level")), why = s("why")),
      if (is.null(text)) list(questions = as.character(unlist(fl$questions)))
      else list(quote = s("quote"), found = quote_found(s("quote"), text)))
  }
  items = purrr::keep(rv$batches %||% list(), function(b) identical(b$kind, "items"))
  questions = unlist(purrr::map(items, function(b) purrr::imap(b$questions, function(text, j) {
    it = if (identical(b$status, "ok")) b$reply$items[[j]]
    rw = trimws(paste(unlist(it$rewrite %||% ""), collapse = " "))
    flags = purrr::map(it$flags %||% list(), function(fl) flag(fl, text))
    list(id = b$ids[[j]], text = text, reviewed = !is.null(it), flags = flags,
         rewrite = if (any(purrr::map_chr(flags, "level") == "fix")) rw else "")
  })), recursive = FALSE)
  inst = purrr::detect(rv$batches %||% list(), function(b) identical(b$kind, "instrument") && identical(b$status, "ok"))
  list(questions = questions %||% list(),
       instrument = purrr::map(inst$reply$instrument %||% list(), function(fl) flag(fl)))
}

n_level <- function(q, level) sum(purrr::map_chr(q$flags, "level") == level)

# The questions to fix first: those with a fix-level flag, by number of fix flags and then in the
#   order pasted, at most n.
fix_first <- function(sh, n = 5L) {
  qs = purrr::keep(sh$questions, function(q) n_level(q, "fix") > 0L)
  utils::head(qs[order(-purrr::map_int(qs, n_level, level = "fix"), seq_along(qs))], n)
}

# A label inside a sentence: its first letter in lower case.
lc1 <- function(x) paste0(tolower(substr(x, 1, 1)), substring(x, 2))

# "a (3), b (2)": labels with their counts, most first, ties in order of first appearance.
count_phrase <- function(x) {
  x = lc1(x)
  t = table(factor(x, levels = unique(x)))
  t = t[order(-t, seq_along(t))]
  paste0(names(t), " (", as.integer(t), ")", collapse = ", ")
}

# The bottom line, built from the flags with no model call: how many questions have a problem
#   likely to change answers (a fix-level flag), how many more have a point to consider, the
#   stage most of the first problems are at with their checks, and one line on the instrument.
bottom_line <- function(sh) {
  qs = purrr::keep(sh$questions, function(q) q$reviewed)
  fix = purrr::keep(qs, function(q) n_level(q, "fix") > 0L)
  more = sum(purrr::map_lgl(qs, function(q) n_level(q, "fix") == 0L && length(q$flags) > 0L))
  of = paste0(length(fix), " of ", length(qs), if (length(qs) == 1L) " question" else " questions")
  first = c(
    if (length(fix)) paste0(of, if (length(fix) == 1L) " has" else " have", " a problem likely to change answers")
    else paste0("None of ", length(qs), if (length(qs) == 1L) " question" else " questions",
                " has a problem this review would fix before fielding"),
    if (more) paste0(more, if (length(fix)) " more" else "", if (more == 1L) " has a point" else " have points", " to consider"))
  top = purrr::map(fix, function(q) purrr::detect(q$flags, function(fl) fl$level == "fix"))
  stages = purrr::map_chr(top, "stage")
  tab = table(factor(stages, levels = intersect(STAGES, stages)))
  main = if (length(stages)) names(tab)[order(-tab, seq_along(tab))][[1]]
  in_main = purrr::keep(top, function(fl) identical(fl$stage, main))
  inst = sh$instrument
  c(paste0(paste(first, collapse = ", and "), "."),
    if (length(fix) == 1L) paste0("It is a ", main, " problem: ", lc1(in_main[[1]]$label), ".")
    else if (length(fix)) paste0(if (length(in_main) == length(fix)) "All are " else "Most are ", main, " problems (",
                                 length(in_main), "): ", count_phrase(purrr::map_chr(in_main, "label")), "."),
    if (length(inst)) paste0("The questionnaire as a whole: ",
                             paste(purrr::map_chr(inst, function(fl)
                               paste0(lc1(fl$label), if (length(fl$questions)) paste0(" (", paste(fl$questions, collapse = ", "), ")"))),
                               collapse = "; "), "."))
}
