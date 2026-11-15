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
  list(cites = length(cites), bad_cites = bad_cites, cites_valid = !length(bad_cites),
       tokens = length(tokens), bad_tokens = bad_tokens, tokens_valid = !length(bad_tokens),
       display_math = str_detect(prose_only(answer), "\\$\\$|\\\\\\["),
       code_blocks = length(blocks), code_parses = all(parses), unverified = setdiff(fns, known))
}

kx <- function(expr, display = FALSE)
  tryCatch(as.character(suppressWarnings(katex::katex_html(expr, displayMode = display, include_css = FALSE,
                                                           preview = FALSE, output = "mathml"))),
           error = function(e) NA_character_)

MATH_RX <- c(display = "(?s)\\$\\$(.+?)\\$\\$",
             inline = "(?<![\\\\$\\w])\\$(?!\\$|\\s)([^$\\n]+?)(?<!\\s)\\$(?!\\d)",
             paren = "(?s)\\\\\\((.+?)\\\\\\)",
             bracket = "(?s)\\\\\\[(.+?)\\\\\\]")

# Formula tokens, then math, are swapped for placeholders before markdown runs, so markdown cannot
#   mangle an underscore inside a formula; code is protected first so df$a + df$b is not math.
render_answer <- function(answer, gathered) {
  text = as.character(answer)
  code = str_extract_all(text, "(?s)```.*?```|`[^`\n]+`")[[1]]
  ctok = sprintf("CODETOKEN%04dZ", seq_along(code))
  text = reduce2(code, ctok, function(a, cd, tk) sub(cd, tk, a, fixed = TRUE), .init = text)
  env = new.env()
  env$m = list()
  hold = function(html) { tk = sprintf("MATHTOKEN%04dZ", length(env$m) + 1L); env$m[[tk]] = html; tk }
  Fm = gathered$formulas
  text = str_replace_all(text, FORMULA_TOKEN_RX, function(m) map_chr(m, function(one) {
    id = str_match(one, FORMULA_TOKEN_RX)[, 2]
    latex = if (!is.null(Fm) && nrow(Fm) && id %in% Fm$fid) Fm$latex[Fm$fid == id][1] else NA_character_
    html = if (is.na(latex)) NA_character_ else kx(latex, TRUE)
    paste0("\n\n", hold(if (is.na(html)) paste0("<span class='text-danger'>", htmltools::htmlEscape(one), "</span>") else html), "\n\n")
  }))
  text = reduce(names(MATH_RX), function(txt, kind) {
    disp = kind %in% c("display", "bracket")
    str_replace_all(txt, regex(MATH_RX[[kind]]), function(m) map_chr(m, function(one) {
      html = kx(str_match(one, regex(MATH_RX[[kind]]))[, 2], disp)
      tk = hold(if (is.na(html)) as.character(htmltools::htmlEscape(one)) else html)
      if (disp) paste0("\n\n", tk, "\n\n") else tk
    }))
  }, .init = text)
  text = reduce2(ctok, code, function(a, tk, cd) sub(tk, cd, a, fixed = TRUE), .init = text)
  html = reduce2(names(env$m), unlist(env$m), function(a, tk, h) gsub(tk, h, a, fixed = TRUE),
                 .init = commonmark::markdown_html(text, extensions = TRUE))
  cited = unique(unlist(str_extract_all(unlist(str_extract_all(as.character(answer), CITE_RX)), "S\\d+")))
  list(html = html, cards = gathered$sources |> filter(label %in% cited) |>
         select(label, kind, passage_id, markdown, title, heading, pages, description, text))
}
