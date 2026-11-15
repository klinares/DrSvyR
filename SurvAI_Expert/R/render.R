# render.R: check_answer() (no model) and render_answer() (markdown and LaTeX to HTML, server side).
#   KaTeX writes MathML, which the browser draws with no stylesheet or fonts. Function definitions
#   and constants only.

FORMULA_TOKEN_RX <- "\\{\\{F:([^}]+)\\}\\}"
CITE_RX <- "\\[S\\d+(?:\\s*[,;]\\s*S\\d+)*\\]"
CODE_BLOCK_RX <- "(?s)```[ \\t]*\\{?[rR]\\}?[^\\n]*\\n(.*?)```"
BASE_PACKAGES <- c("stats", "utils", "graphics", "grDevices", "methods")
TIDYVERSE_CORE <- c("dplyr", "tidyr", "ggplot2", "readr", "purrr", "tibble", "stringr", "forcats", "lubridate")

# Prose with fenced code blocks and code spans removed.
prose_only <- function(x) str_remove_all(x, "(?s)```.*?```|`[^`\n]+`")

called_functions <- function(code) {
  pd = utils::getParseData(parse(text = code, keep.source = TRUE))
  setdiff(unique(pd$text[pd$token == "SYMBOL_FUNCTION_CALL"]),
          str_match_all(code, "([A-Za-z.][A-Za-z0-9._]*)\\s*(?:<-|=)\\s*function")[[1]][, 2])
}

exports_of <- function(pkgs) unique(unlist(map(pkgs, function(p)
  if (requireNamespace(p, quietly = TRUE)) getNamespaceExports(p) else character())))

check_answer <- function(answer, gathered) {
  answer = as.character(answer)
  cites = unique(unlist(str_extract_all(unlist(str_extract_all(answer, CITE_RX)), "S\\d+")))
  tokens = unique(str_match_all(answer, FORMULA_TOKEN_RX)[[1]][, 2])
  blocks = str_match_all(answer, CODE_BLOCK_RX)[[1]][, 2]
  parses = map_lgl(blocks, function(b) !inherits(try(parse(text = b), silent = TRUE), "try-error"))
  fns = unique(unlist(map(blocks[parses], called_functions)))
  pkgs = unique(unlist(str_split(if ("packages" %in% names(gathered$code)) gathered$code$packages else character(), ";")))
  pkgs = unique(c(pkgs[nzchar(pkgs)], if ("tidyverse" %in% pkgs) TIDYVERSE_CORE))
  known = unique(c(gathered$known_fns, ls(baseenv(), all.names = TRUE), exports_of(c(BASE_PACKAGES, pkgs))))
  bad_cites = setdiff(cites, gathered$sources$label)
  bad_tokens = setdiff(tokens, if ("fid" %in% names(gathered$formulas)) gathered$formulas$fid else character())
  u = prose_units(answer)
  list(cites = length(cites), bad_cites = bad_cites, cites_valid = !length(bad_cites),
       tokens = length(tokens), bad_tokens = bad_tokens, tokens_valid = !length(bad_tokens),
       display_math = str_detect(prose_only(answer), "\\$\\$|\\\\\\["),
       code_blocks = length(blocks), code_parses = all(parses), unverified = setdiff(fns, known),
       uncited = sum(!u$cited), uncited_text = u$text[!u$cited], units = length(u$text), not_from_store = sum(u$nfs),
       words = sum(str_count(str_remove_all(u$all, CITE_RX), "\\S+")))
}

NFS_RX <- "^(?i)[*_\\s]*not from the store:"
CHECK_RX <- "^(?i)[*_\\s]*check:"
WHAT_TO_CHECK_RX <- "^(?i)[#*_\\s]*(what to check|check before|things to check|before (running|using|you run))\\b"
HEADING_RX <- "^\\s*#|^\\s*\\*\\*[^*]+\\*\\*:?\\s*$"

# Sentences and bullets of the prose, each with whether it carries a citation or the "Not from
#   the store:" label (or begins "Check:", which flags sources that disagree). Headings, code,
#   formula lines, tables and the lines under "What to check" (instructions to the user) are left
#   out, and so are lead-ins (ending in ":") and fragments under four words; $all keeps every prose
#   unit, for word counts.
prose_units <- function(answer) {
  l = str_split_1(str_remove_all(as.character(answer), "(?s)```.*?```"), "\n")
  in_check = accumulate(seq_along(l), function(on, i) if (str_detect(l[i], WHAT_TO_CHECK_RX)) TRUE
                        else if (str_detect(l[i], HEADING_RX)) FALSE else on, .init = FALSE)[-1]
  l = l[!in_check & !str_detect(l, paste0("^\\s*$|^\\s*\\{\\{F:|^\\s*\\||", HEADING_RX))]
  bullet = str_detect(l, "^\\s*([-*+]|\\d+[.)])\\s+")
  para = cumsum(bullet | lag(bullet, default = TRUE))
  blocks = map_chr(split(str_remove(l, "^\\s*([-*+]|\\d+[.)])\\s+"), para), paste, collapse = " ")
  # a citation after the full stop belongs to the sentence before it
  blocks = str_replace_all(blocks, "([.!?])\\s*((?:\\[S\\d+[^\\]]*\\]\\s*)+)", " \\2\\1 ")
  s = str_squish(unlist(str_split(blocks, "(?<=[.!?])\\s+(?=[A-Z*_(\\[])")))
  s = s[nzchar(s)]
  keep_s = !str_detect(s, ":\\s*$") & str_count(s, "\\S+") >= 4
  t = s[keep_s]
  list(text = t, cited = str_detect(t, CITE_RX) | str_detect(t, NFS_RX) | str_detect(t, CHECK_RX), nfs = str_detect(t, NFS_RX), all = s)
}

# The answer's uncited factual sentences wrapped in a dotted underline, before it is rendered.
#   A sentence is marked where it stands on one line of the answer; one split across lines is not.
mark_uncited <- function(answer) {
  u = prose_units(answer)
  bad = unique(u$text[!u$cited])
  marked = reduce(bad, function(txt, s) {
    if (!str_detect(txt, fixed(s))) return(txt)
    sub(s, paste0("<span class=\"survai-uncited\">", s, "</span>"), txt, fixed = TRUE)
  }, .init = as.character(answer))
  list(text = marked, n = str_count(marked, fixed("survai-uncited")))
}

kx <- function(expr, display = FALSE)
  tryCatch(as.character(suppressWarnings(katex::katex_html(expr, displayMode = display, include_css = FALSE,
                                                           preview = FALSE, output = "mathml"))),
           error = function(e) NA_character_)

MATH_RX <- c(display = "(?s)\\$\\$(.+?)\\$\\$",
             inline = "(?<![\\\\$\\w])\\$(?!\\$|\\s)([^$\\n]+?)(?<!\\s)\\$(?!\\d)",
             paren = "(?s)\\\\\\((.+?)\\\\\\)",
             bracket = "(?s)\\\\\\[(.+?)\\\\\\]")

R_KEYWORDS_RX <- "\\b(function|if|else|return|TRUE|FALSE|NULL|NA|library|require)\\b"

# R code as HTML with comments, strings, keywords and function calls marked (no package needed).
highlight_r <- function(code) {
  line = function(l) {
    cm = str_locate(l, "#(?=[^\"']*$)")[1]
    body = if (is.na(cm)) l else str_sub(l, 1, cm - 1)
    b = htmltools::htmlEscape(body)
    b = str_replace_all(b, "(&quot;.*?&quot;|&#39;.*?&#39;)", "<span class='tok-str'>\\1</span>")
    b = str_replace_all(b, "\\b([A-Za-z.][A-Za-z0-9._]*)(?=\\()", "<span class='tok-fn'>\\1</span>")
    b = str_replace_all(b, R_KEYWORDS_RX, "<span class='tok-kw'>\\1</span>")
    paste0(b, if (!is.na(cm)) paste0("<span class='tok-com'>", htmltools::htmlEscape(str_sub(l, cm)), "</span>") else "")
  }
  paste0("<pre class='survai-code'><code>", paste(map_chr(str_split_1(code, "\n"), line), collapse = "\n"), "</code></pre>")
}

open_link <- function(open_input, label, text) if (is.null(open_input)) text else
  sprintf("<a href='#' class='survai-open' onclick=\"Shiny.setInputValue('%s', '%s', {priority: 'event'}); return false;\">%s</a>",
          open_input, str_replace_all(htmltools::htmlEscape(label, attribute = TRUE), "'", "\\\\'"), text)

# Markdown to HTML, server side. Formula tokens, then math, are swapped for placeholders before
#   markdown runs, so markdown cannot mangle an underscore inside a formula; code is protected first
#   so df$a + df$b is not math. formulas: a table with fid and latex (and label, the source S# the
#   formula links to). math = FALSE (while an answer streams) leaves maths as typed and tokens as a
#   note. open_input: the input a citation or a formula's "source" link sets.
render_md <- function(text, formulas = NULL, open_input = NULL, math = TRUE) {
  text = as.character(text)
  env = new.env()
  env$m = list()
  hold = function(html) { tk = sprintf("HOLDTOKEN%04dZ", length(env$m) + 1L); env$m[[tk]] = html; tk }
  text = str_replace_all(text, "(?s)```[^\\n]*\\n(.*?)```", function(m) map_chr(m, function(one)
    paste0("\n\n", hold(highlight_r(str_remove(str_match(one, "(?s)```[^\\n]*\\n(.*?)```")[, 2], "\n$"))), "\n\n")))
  code = str_extract_all(text, "`[^`\n]+`")[[1]]
  ctok = sprintf("CODETOKEN%04dZ", seq_along(code))
  text = reduce2(code, ctok, function(a, cd, tk) sub(cd, tk, a, fixed = TRUE), .init = text)
  text = str_replace_all(text, FORMULA_TOKEN_RX, function(m) map_chr(m, function(one) {
    id = str_match(one, FORMULA_TOKEN_RX)[, 2]
    i = if (!is.null(formulas) && nrow(formulas)) match(id, formulas$fid) else NA
    html = if (!math) "<em class='text-muted'>[formula from the store]</em>" else if (is.na(i)) NA_character_ else kx(formulas$latex[i], TRUE)
    if (math && !is.na(i) && !is.na(html) && !is.null(formulas$label)) html = paste0("<div class='survai-formula'>", html,
      "<div class='small text-end'>", open_link(open_input, formulas$label[i], paste("source", formulas$label[i])), "</div></div>")
    paste0("\n\n", hold(if (is.na(html)) paste0("<span class='text-danger'>", htmltools::htmlEscape(one), "</span>") else html), "\n\n")
  }))
  if (math) text = reduce(names(MATH_RX), function(txt, kind) {
    disp = kind %in% c("display", "bracket")
    str_replace_all(txt, regex(MATH_RX[[kind]]), function(m) map_chr(m, function(one) {
      html = kx(str_match(one, regex(MATH_RX[[kind]]))[, 2], disp)
      tk = hold(if (is.na(html)) as.character(htmltools::htmlEscape(one)) else html)
      if (disp) paste0("\n\n", tk, "\n\n") else tk
    }))
  }, .init = text)
  text = reduce2(ctok, code, function(a, tk, cd) sub(tk, cd, a, fixed = TRUE), .init = text)
  html = commonmark::markdown_html(text, extensions = TRUE)
  if (!is.null(open_input)) html = str_replace_all(html, "S(\\d+)(?=[^<>]*\\])", function(s) open_link(open_input, s, s))
  reduce2(names(env$m), unlist(env$m), function(a, tk, h) gsub(tk, h, gsub(paste0("<p>", tk, "</p>"), tk, a, fixed = TRUE), fixed = TRUE), .init = html)
}

render_answer <- function(answer, gathered, open_input = NULL) {
  Fm = gathered$formulas
  if (!is.null(Fm) && nrow(Fm)) Fm = Fm |> left_join(gathered$sources |> filter(kind == "formula") |> select(ref, label), by = c(fid = "ref"))
  cited = unique(unlist(str_extract_all(unlist(str_extract_all(as.character(answer), CITE_RX)), "S\\d+")))
  mk = mark_uncited(answer)
  html = paste0(render_md(mk$text, Fm, open_input),
                if (mk$n) "<p class='small text-muted'><span class='survai-uncited'>Dotted text</span> is not tied to a source.</p>" else "")
  list(html = html, uncited_marked = mk$n, cards = gathered$sources |> filter(label %in% cited) |>
         select(label, kind, passage_id, markdown, title, heading, pages, description, text))
}
