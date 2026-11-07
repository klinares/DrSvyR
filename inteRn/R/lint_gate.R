# lint_gate.R -- R code in a reply passes lintr before the user sees it.
#
# Every ```r block in a reply is linted with the custom linters below (no
#   loops, no base graphics, colourblind-safe colours) plus two correctness
#   checks. On failure the problems go back to the model in the same
#   conversation and it rewrites the reply, at most lint_retries times
#   (config.R, default 2). Whatever still fails is shown with a note listing
#   the problems, never silently. Blocks that pass and were not run with
#   run_code get "# UNTESTED" as their first line if the model left it off.
#
# Skipped, with one message per session, when lintr is not installed.
# Function definitions and constants only.

# ---- linters -----------------------------------------------------------

BASE_GRAPHICS <- c("plot", "hist", "barplot", "pie", "boxplot", "dotchart", "matplot",
                   "stripchart", "mosaicplot", "svyhist", "svyboxplot", "svyplot")
UNSAFE_PALETTES <- c("rainbow", "heat.colors", "terrain.colors", "topo.colors", "cm.colors")
OKABE_ITO_SET <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
                   "#CC79A7", "#000000", "#FFFFFF")

xpath_calls <- function(fns)
  paste0("//SYMBOL_FUNCTION_CALL[", paste0("text() = '", fns, "'", collapse = " or "), "]")

no_loop_linter <- function()
  lintr::make_linter_from_xpath(
    "//FOR | //WHILE | //REPEAT",
    "No for, while or repeat loops: use purrr (map(), walk(), reduce()) or a vectorised function.",
    type = "warning")()

no_base_graphics_linter <- function()
  lintr::make_linter_from_xpath(
    xpath_calls(BASE_GRAPHICS),
    "No base graphics: use ggplot2 (see the dataviz skill).",
    type = "warning")()

# Unsafe palette functions, and hex colours that are neither Okabe-Ito nor
#   from a viridis map.
palette_linter <- function() lintr::Linter(function(source_expression) {
  xml = source_expression$xml_parsed_content
  if (is.null(xml)) return(list())
  bad_fun = xml2::xml_find_all(xml, xpath_calls(UNSAFE_PALETTES))
  strs = xml2::xml_find_all(xml, "//STR_CONST")
  vals = toupper(gsub("^[\"']|[\"']$", "", xml2::xml_text(strs)))
  hex = grepl("^#[0-9A-F]{6}([0-9A-F]{2})?$", vals)
  unsafe = hex
  unsafe[hex] = !safe_hex(substr(vals[hex], 1, 7))
  c(lintr::xml_nodes_to_lints(bad_fun, source_expression,
                              "Not colourblind-safe: use Okabe-Ito or a viridis scale.", type = "warning"),
    lintr::xml_nodes_to_lints(strs[unsafe], source_expression,
                              "Colour is not Okabe-Ito or viridis; pick a colourblind-safe one.",
                              type = "warning"))
}, linter_level = "expression")

# Okabe-Ito, white, or within 3 per channel of a viridis-family colour.
safe_hex <- function(hex) {
  if (!length(hex)) return(logical(0))
  fam = .state$viridis_rgb
  if (is.null(fam)) {
    opts = c("A", "B", "C", "D", "E", "F", "G")       # not "H", turbo: a rainbow
    fam = grDevices::col2rgb(unlist(purrr::map(opts, function(o)
      substr(viridisLite::viridis(256, option = o), 1, 7))))
    .state$viridis_rgb = fam
  }
  purrr::map_lgl(hex, function(h)
    h %in% OKABE_ITO_SET ||
      any(colSums(abs(fam - as.vector(grDevices::col2rgb(h))) <= 3) == 3))
}

intern_linters <- function() list(
  no_loop = no_loop_linter(),
  no_base_graphics = no_base_graphics_linter(),
  palette = palette_linter(),
  equals_na = lintr::equals_na_linter(),
  T_and_F_symbol = lintr::T_and_F_symbol_linter())

# ---- finding and checking code ---------------------------------------------

CODE_BLOCK <- "(?s)```\\{?[rR]\\}?[^\\n]*\\n(.*?)```"

code_blocks <- function(text) {
  m = regmatches(text, gregexpr(CODE_BLOCK, text, perl = TRUE))[[1]]
  sub(CODE_BLOCK, "\\1", m, perl = TRUE)
}

# A block shown on purpose as what not to do starts with "# BAD EXAMPLE".
#   It is neither linted nor marked UNTESTED; the marker keeps it visible to
#   the reader.
is_bad_example <- function(code) grepl("^\\s*#\\s*BAD EXAMPLE", code)

# One row per problem across the reply's code blocks. `# nolint` comments
#   are removed first: the model may not switch the gate off for real code.
lint_reply <- function(text) {
  blocks = code_blocks(text)
  if (!length(blocks)) return(data.frame(block = integer(), line = integer(), message = character()))
  rows = purrr::imap(blocks, function(code, i) {
    if (is_bad_example(code)) return(NULL)
    code = gsub("#\\s*nolint[^\n]*", "", code, perl = TRUE)
    res = as.data.frame(lintr::lint(text = paste0(code, "\n"), linters = intern_linters()))
    if (!nrow(res)) return(NULL)
    data.frame(block = i, line = res$line_number, message = res$message)
  })
  out = do.call(rbind, purrr::compact(rows))
  if (is.null(out)) data.frame(block = integer(), line = integer(), message = character()) else out
}

lint_feedback <- function(problems)
  paste0("The R code in your reply did not pass the lint gate:\n",
         paste0("- code block ", problems$block, ", line ", problems$line, ": ",
                problems$message, collapse = "\n"),
         "\n\nRewrite your whole reply with corrected code. Keep everything else the same, ",
         "and do not mention this check.")

norm_code <- function(x) gsub("\\s+", " ", trimws(x))

# Code the model ran this turn with run_code, so those blocks are not
#   marked UNTESTED.
ran_this_turn <- function(chat, n_before) {
  turns = chat$get_turns()
  new = if (length(turns) > n_before) turns[seq.int(n_before + 1, length(turns))] else list()
  calls = purrr::list_flatten(purrr::map(new, function(t)
    purrr::keep(t@contents, function(x) inherits(x, "ellmer::ContentToolRequest") &&
                  identical(x@name, "run_code"))))
  purrr::map_chr(calls, function(x) norm_code(x@arguments$code %||% ""))
}

# "# UNTESTED" as the first line of every block that lacks it and was not run.
mark_untested <- function(text, ran = character(0)) {
  m = gregexpr(CODE_BLOCK, text, perl = TRUE)
  regmatches(text, m) = list(purrr::map_chr(regmatches(text, m)[[1]], function(block) {
    code = sub(CODE_BLOCK, "\\1", block, perl = TRUE)
    if (grepl("^\\s*#\\s*UNTESTED", code) || is_bad_example(code) || norm_code(code) %in% ran)
      return(block)
    sub("(```\\{?[rR]\\}?[^\\n]*\\n)", "\\1# UNTESTED\n", block, perl = TRUE)
  }))
  text
}

gate_on <- function() {
  if (identical(INTERN_LLM$lint, FALSE)) return(FALSE)
  if (requireNamespace("lintr", quietly = TRUE)) return(TRUE)
  if (!isTRUE(.state$lint_warned)) {
    message("inteRn: lintr is not installed, so replies are not linted. install.packages(\"lintr\")")
    .state$lint_warned = TRUE
  }
  FALSE
}

lint_retries <- function() as.integer(INTERN_LLM$lint_retries %||% 2L)

finish_reply <- function(reply, problems, chat, n_before) {
  reply = mark_untested(reply, ran_this_turn(chat, n_before))
  if (!nrow(problems)) return(reply)
  paste0(reply, "\n\n> **Lint gate:** this code still has problems after ", lint_retries(),
         " rewrites:\n", paste0("> - block ", problems$block, ", line ", problems$line, ": ",
                                problems$message, collapse = "\n"))
}

# ---- the gate, blocking and async -------------------------------------------

# reply: the model's text. send: function(prompt) -> reply text, in the same
#   conversation. Recurses at most lint_retries() times.
# A linter that fails must never cost the user the reply: the gate is skipped
#   with a message instead.
safe_lint <- function(reply) tryCatch(lint_reply(reply), error = function(e) {
  message("inteRn: the lint gate failed and was skipped: ", conditionMessage(e))
  NULL
})

lint_gate <- function(reply, chat, send, n_before, attempt = 0L) {
  if (is.null(reply) || !gate_on()) return(reply)
  problems = safe_lint(reply)
  if (is.null(problems)) return(reply)
  if (!nrow(problems) || attempt >= lint_retries())
    return(finish_reply(reply, problems, chat, n_before))
  if (identical(.state$channel, "viewer"))
    viewer_send(list(type = "tool", text = paste0("lint gate: ", nrow(problems),
                                                 " problem(s), asking for a rewrite")))
  rewrite = send(lint_feedback(problems))
  if (is.null(rewrite)) return(finish_reply(reply, problems, chat, n_before))
  lint_gate(rewrite, chat, send, n_before, attempt + 1L)
}

# The same, for a promise of a reply; returns a promise.
lint_gate_async <- function(reply, chat, send_async, n_before, attempt = 0L) {
  if (is.null(reply) || !gate_on()) return(reply)
  problems = safe_lint(reply)
  if (is.null(problems)) return(reply)
  if (!nrow(problems) || attempt >= lint_retries())
    return(finish_reply(reply, problems, chat, n_before))
  viewer_send(list(type = "tool", text = paste0("lint gate: ", nrow(problems),
                                               " problem(s), asking for a rewrite")))
  promises::then(send_async(lint_feedback(problems)), function(r) {
    if (is.null(r)) return(finish_reply(reply, problems, chat, n_before))
    lint_gate_async(r, chat, send_async, n_before, attempt + 1L)
  })
}
