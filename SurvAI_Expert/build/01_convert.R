# 01_convert.R -- HOME ONLY (.rscignore keeps build/ off Connect). Step 1 of the SurvAI_Expert
#   build: every source document becomes one markdown file under data/markdown/<source>/.
#   Run from inside SurvAI_Expert/:
#
#     Rscript --no-init-file build/01_convert.R dry     # what would be converted, pages, cost; no model call
#     Rscript --no-init-file build/01_convert.R pilot   # PILOT_FOLDER only (PDFs and its .qmd/.Rmd)
#     Rscript --no-init-file build/01_convert.R all     # every source
#     Rscript --no-init-file build/01_convert.R jpsm    # one source (any name in SOURCES)
#     Rscript --no-init-file build/01_convert.R rewrite # every document again from the cache; no model call
#     Rscript --no-init-file build/01_convert.R figures # describe figures on candidate pages (FIGURE_CAP_USD)
#
#   Conversion runs at home only; its output reaches work as text, through git.
#
#   PDFs: every page is rendered to a PNG and sent to BUILD_MODEL, one page per call, with the
#   settings of the winning arm of the Phase 1 model test (survai-expert branch, build.R:
#   BUILD_MT_PROMPT as the user turn, no system prompt, 150 dpi, temperature 0, max_tokens 4096).
#   pdftools text is only a cross-check. .qmd/.Rmd: no model, chunks become fenced blocks.
#   Sampling Techniques .md: copied under a header. Each page reply is cached under
#   data/build/pages/<sha256>/, so a rerun pays only for pages it does not have, and a source file
#   whose sha256 is in the manifest with no problems is not read again.
#
#   data/catalog/manifest.csv travels to work; data/build/ (caches, convert_problems.csv) does not.
#   Every path written into a header or the manifest is relative to SurvAI_Expert/ or to the source root.


# ---- 1. settings -------------------------------------------------------------------------------

# The conversion model: an OpenAI-style chat completions endpoint. Nothing else in this script
#   names a provider or a model. The key is read from OPENROUTER_API_KEY, held in a closure for the
#   call, and never written to a file, the log or the console.
BUILD_MODEL <- list(api = "openai", base_url = "https://openrouter.ai/api/v1", id = "google/gemini-4-argon")
BUILD_KEY_VAR <- "OPENROUTER_API_KEY"

# Reply settings of the model test. The limit is sent as max_tokens in the request body, as the
#   model test did (ellmer's params() would send max_completion_tokens).
BUILD_TEMPERATURE <- 0
BUILD_MAX_TOKENS <- 4096L

# One entry per source: a short id (the folder under data/markdown/), a root, a type.
SOURCES <- list(
  jpsm       = list(id = "jpsm", root = "D:/repos/UMD_JPSM_coursework", type = "coursework"),
  practools  = list(id = "practools", root = "D:/documents/UMD/books", type = "textbook",
                    files = "practical_tools_textbook.pdf"),
  tidysurvey = list(id = "tidysurvey", root = "D:/repos/tidy-survey-book", type = "rmd_book"),
  sampling   = list(id = "sampling", root = "D:/repos/SurvAI_Expert/external/sampling-techniques",
                    type = "md_book"),
  training   = list(id = "training", root = "D:/documents/UMD/training", type = "slides",
                    files = c("questionnaire_design_iass_wss/Quex_Design_Session1.pdf",
                              "questionnaire_design_iass_wss/Quex_Design_Session2.pdf")))

# Spend cap for everything recorded in the page cache, this run and earlier ones.
COST_CAP_USD <- 60

# The pilot: one course folder of the coursework.
PILOT_FOLDER <- "applied_sampling_SURV625"

# The model test's settings for the winning arm, verbatim (survai-expert:SurvAI_Expert/build.R).
BUILD_DPI <- 150
BUILD_PROMPT <- paste(
  "Convert this page image to markdown.",
  "Write all mathematics in LaTeX: inline as $...$, and each displayed",
  "equation as $$...$$ on its own lines.",
  "Copy any R code exactly into fenced ```r blocks, character for character,",
  "including every ~ (tilde); do not correct or complete it.",
  "Keep headings, bullet points and tables (as markdown tables).",
  "Add nothing that is not on the page: no summary, no commentary, no",
  "description of pictures. Output only the markdown.")

# Figure lines (mode "figures"): a page whose markdown has no description of its figure is sent
#   again, same model, asking only for the figure. The reply is cached in FIG_DIR and appended to
#   the page as "*[Figure: ...]*" when the document is assembled; the page reply is not changed.
#   Candidates: pages flagged "short" first, then pages with a figure caption line.
FIGURE_PROMPT <- paste(
  "Describe only the figure, diagram or plot on this page image, in at most two sentences:",
  "say what it shows, its axes, the groups it compares, and the main pattern.",
  "Do not transcribe the text of the page.",
  "If the page has no figure, diagram or plot, reply NONE.")
FIGURE_CAP_USD <- 3
FIG_CAPTION_RX <- "(?im)^[\\s*#>-]*(?:figure|fig\\.)\\s*[:0-9]"

# Requests in flight at once inside this R process, and seconds before one gives up.
IN_FLIGHT <- 8L
CALL_TIMEOUT_S <- 120

# USD per million tokens, used only when a reply carries no cost of its own (the endpoint reports
#   one per call when asked with usage = list(include = TRUE)). BUILD_MODEL's list price on
#   2026-11-10 (old STATUS.md); change it with the model.
PRICE_PER_M <- c(input = 2.00, output = 10.00)

# Where things go, relative to SurvAI_Expert/.
OUT_DIR <- "data/markdown"
BUILD_DIR <- "data/build"
PAGE_DIR <- file.path(BUILD_DIR, "pages")
FIG_DIR <- file.path(BUILD_DIR, "figures")
FILES_CACHE <- file.path(BUILD_DIR, "files.csv")
PROBLEMS_CSV <- file.path(BUILD_DIR, "convert_problems.csv")
MANIFEST_CSV <- "data/catalog/manifest.csv"

# Text replaced in every written document (columns find, replace; fixed strings), for personal
#   details in the sources such as a seed taken from a student ID. Kept in data/build/, which git
#   ignores, so what is removed never reaches the repository. A source already in the manifest is
#   not reread: after adding a line, delete that source's manifest row or its markdown file.
REDACT_CSV <- file.path(BUILD_DIR, "redact.csv")
MODELTEST_RESULTS <- file.path(BUILD_DIR, "modeltest", "results.csv")

# Skip rules of the old project (D:/repos/SurvAI_Expert: build/extract.R SKIP and FOLDERS,
#   README "The rests"), matched against "/" + the path relative to the coursework root.
JPSM_SKIP <- list(
  `old textbook conversion (practools replaces it)` = "^/practical_tools_textbook/",
  `rendered output or figure folder` = "/\\.quarto/|/_freeze/|/_site/|/renv/|/\\.git/|/node_modules/|/images/|/figures?/|/libs/|\\.Rhistory$",
  `*_files/ folder` = "_files/",
  `readings/` = "/readings/",
  `data/` = "/data/",
  `data or binary file` = "\\.(rdata|rds|rdx|rdb|dat|dta|sav|sas7bdat|xlsx|xls|csv|tsv|png|jpe?g|gif|svg|mp4|zip|html|docx|odt|pptx)$",
  `assignment PDF (its .qmd/.Rmd is read)` = "/assignments/[^/]*\\.pdf$",
  `syllabus or admin PDF` = "syllabus|pledge|waiver|mail -|peerrs")
JPSM_FOLDERS <- list(
  lectures = "pdf", assignments = c("qmd", "rmd", "r"), midterm = c("qmd", "rmd", "pdf"),
  final = c("qmd", "rmd", "pdf"), exams = c("qmd", "rmd", "pdf"), code = c("r", "qmd", "rmd", "py"),
  class_code = c("r", "qmd", "rmd", "py"), class_code_files = c("r", "qmd", "rmd", "py"),
  class_examples = c("r", "qmd", "rmd", "pdf", "py"), labs = c("r", "qmd", "rmd", "pdf"),
  lab = c("r", "qmd", "rmd", "pdf"), class_labs = c("r", "qmd", "rmd", "pdf"),
  llm_demo = c("r", "qmd", "rmd", "py"), record_linkage = c("r", "qmd", "rmd", "pdf"),
  project = c("qmd", "rmd", "r", "pdf"), notes = "pdf")
JPSM_DOC_TYPE <- c(lectures = "lecture", notes = "lecture", assignments = "assignment", midterm = "assignment",
                   final = "assignment", exams = "assignment", project = "assignment")

# Tidy Survey Book files not converted: duplicates and pages with no text of their own
#   (old DrSvyR inventory and old fetch_external.R TIDY_SKIP).
TIDY_SKIP <- list(`LaTeX duplicate of a chapter` = "-latex[.]Rmd$", `bibliography only` = "^99-references",
                  `codebook include only` = "^9[12]-Appendix", `corrections page` = "^94-Appendix")


# ---- 2. packages ---------------------------------------------------------------------------------

library(dplyr)
library(purrr)
library(stringr)
library(tibble)

local({
  need = c("digest", "ellmer", "jsonlite", "katex", "later", "pdftools", "promises", "S7")
  missing = discard(need, requireNamespace, quietly = TRUE)
  if (length(missing)) stop("Not installed: ", paste(missing, collapse = ", "), call. = FALSE)
  # The functions and arguments used below, checked against the installed versions.
  calls = list(ellmer = list(chat_openai_compatible = c("base_url", "name", "credentials", "model", "params", "api_args", "echo"),
                             content_image_file = c("path", "resize"), params = "temperature"),
               pdftools = list(pdf_convert = c("pdf", "format", "pages", "filenames", "dpi", "verbose"),
                               pdf_info = "pdf", pdf_text = "pdf"),
               katex = list(katex_html = c("tex", "displayMode", "include_css", "preview")))
  gone = unlist(imap(calls, function(fns, pkg) imap(fns, function(args, fn) {
    absent = setdiff(args, names(formals(getExportedValue(pkg, fn))))
    if (length(absent)) paste0(pkg, "::", fn, "(", paste(absent, collapse = ", "), ")")
  })))
  if (length(gone)) stop("The installed packages lack: ", paste(gone, collapse = "; "), call. = FALSE)
})

stopifnot(identical(map, purrr::map), identical(filter, dplyr::filter))
if (!file.exists("build/01_convert.R")) stop("Run this from inside SurvAI_Expert/.", call. = FALSE)


# ---- 3. what each source holds -------------------------------------------------------------------

file_ext <- function(x) tolower(tools::file_ext(x))
out_rel <- function(rel) sub("[.][^./]+$", ".md", rel)
doc_id <- function(source, rel) paste0(source, "/", str_replace_all(sub("[.][^./]+$", "", rel), "\\s+", "_"))

# Course titles from the coursework README table: | Fall 2024 | SURV 615 | Title | [`folder`](...) |
course_titles <- function(root) {
  f = file.path(root, "README.md")
  if (!file.exists(f)) return(character(0))
  m = str_match(readLines(f, warn = FALSE, encoding = "UTF-8"),
                "\\|\\s*SURV\\s*\\d{3}\\s*\\|\\s*([^|]+?)\\s*\\|\\s*\\[`([^`]+)`\\]")
  m = m[!is.na(m[, 1]), , drop = FALSE]
  set_names(m[, 2], m[, 3])
}

list_jpsm <- function(s) {
  rel = list.files(s$root, recursive = TRUE)
  ext = file_ext(rel)
  rel_s = paste0("/", rel)
  hits = map(JPSM_SKIP, function(rx) str_detect(rel_s, regex(rx, ignore_case = TRUE)))
  first_rule = map_chr(seq_along(rel), function(i) detect(names(hits), function(n) hits[[n]][i]) %||% NA_character_)
  # The folder that decides type, as old extract.R: course root = notes, else the first known name.
  folder = map_chr(strsplit(rel, "/"), function(p) {
    if (length(p) == 2) return("notes")
    known = tolower(p) %in% setdiff(names(JPSM_FOLDERS), "notes")
    if (any(known)) tolower(p)[which(known)[1]] else NA_character_
  })
  allowed = map2_lgl(ext, folder, function(e, f) !is.na(f) && e %in% JPSM_FOLDERS[[f]])
  stem = tolower(tools::file_path_sans_ext(rel))
  twin = ext == "pdf" & stem %in% stem[ext %in% c("qmd", "rmd")]
  titles = course_titles(s$root)
  top = str_extract(rel, "^[^/]+")
  tibble(source = s$id, path = file.path(s$root, rel), rel = rel, ext = ext,
         skip = case_when(!is.na(first_rule) ~ first_rule,
                          twin ~ "PDF with a .qmd/.Rmd twin",
                          !ext %in% c("pdf", "qmd", "rmd") ~ "code or text file (not this step)",
                          !allowed ~ "folder or type outside the old list",
                          TRUE ~ NA_character_),
         course = coalesce(str_extract(top, "SURV[0-9]{3}"), ""),
         course_title = unname(coalesce(titles[top], "")),
         doc_type = unname(coalesce(JPSM_DOC_TYPE[folder], "lab")))
}

list_files_of <- function(s, doc_type) {
  rel = s$files
  tibble(source = s$id, path = file.path(s$root, rel), rel = rel, ext = file_ext(rel),
         skip = if_else(file.exists(file.path(s$root, rel)), NA_character_, "missing file"),
         course = "", course_title = "", doc_type = doc_type)
}

list_tidy <- function(s) {
  rel = list.files(s$root, pattern = "[.]Rmd$")
  rule = map_chr(rel, function(r) detect(names(TIDY_SKIP), function(n) str_detect(r, TIDY_SKIP[[n]])) %||% NA_character_)
  tibble(source = s$id, path = file.path(s$root, rel), rel = rel, ext = "rmd", skip = rule,
         course = "", course_title = "", doc_type = "book")
}

list_sampling <- function(s) {
  rel = list.files(s$root, pattern = "[.]md$")
  tibble(source = s$id, path = file.path(s$root, rel), rel = rel, ext = "md", skip = NA_character_,
         course = "", course_title = "", doc_type = "book")
}

list_sources <- function() {
  walk(SOURCES, function(s) if (!dir.exists(s$root)) stop("No source folder at ", s$root, call. = FALSE))
  out = bind_rows(list_jpsm(SOURCES$jpsm), list_files_of(SOURCES$practools, "textbook"),
                  list_tidy(SOURCES$tidysurvey), list_sampling(SOURCES$sampling),
                  list_files_of(SOURCES$training, "slides")) |>
    mutate(out = file.path(OUT_DIR, source, out_rel(rel)), id = doc_id(source, rel))
  clash = out |> filter(is.na(skip)) |> count(out) |> filter(n > 1)
  if (nrow(clash)) stop("Two sources would write the same file: ", paste(clash$out, collapse = ", "), call. = FALSE)
  out
}

# sha256 and page count of each file to convert, cached by path, size and modification time.
file_facts <- function(todo) {
  old = if (file.exists(FILES_CACHE)) utils::read.csv(FILES_CACHE, stringsAsFactors = FALSE) else
    tibble(path = character(), size = numeric(), mtime = character(), sha256 = character(), pages = integer())
  info = file.info(todo$path)
  now = tibble(path = todo$path, size = info$size, mtime = format(info$mtime, "%Y-%m-%d %H:%M:%S"))
  known = inner_join(now, old, by = c("path", "size", "mtime"))
  new = anti_join(now, known, by = "path")
  if (nrow(new)) message("Reading ", nrow(new), " files for sha256 and page count")
  new = new |> mutate(
    sha256 = map_chr(path, function(p) digest::digest(file = p, algo = "sha256")),
    pages = map2_int(path, file_ext(path), function(p, e)
      if (e == "pdf") tryCatch(as.integer(pdftools::pdf_info(p)$pages), error = function(e) NA_integer_) else NA_integer_))
  facts = bind_rows(known, new)
  dir.create(BUILD_DIR, recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(bind_rows(facts, anti_join(old, facts, by = "path")), FILES_CACHE, row.names = FALSE, fileEncoding = "UTF-8")
  left_join(todo, select(facts, path, sha256, pages), by = "path")
}

page_file <- function(sha, page, ext) file.path(PAGE_DIR, sha, sprintf("p%04d.%s", page, ext))

# USD per page from the model test, the winning arm's strata weighted by their pages.
est_usd_page <- function() {
  if (!file.exists(MODELTEST_RESULTS)) stop("No ", MODELTEST_RESULTS, ": cannot estimate cost.", call. = FALSE)
  r = utils::read.csv(MODELTEST_RESULTS) |> filter(arm == BUILD_MODEL$id)
  if (!nrow(r)) stop("The model test has no arm ", BUILD_MODEL$id, call. = FALSE)
  stats::weighted.mean(r$usd_page, r$pages)
}


# ---- 4. checks on a page, all in R --------------------------------------------------------------

# The renderer the old app used (D:/repos/SurvAI_Expert/R/render.R, kx()): NA when KaTeX refuses.
kx <- function(expr, display = FALSE)
  tryCatch(as.character(suppressWarnings(katex::katex_html(expr, displayMode = display, include_css = FALSE,
                                                           preview = FALSE, output = "mathml"))),
           error = function(e) NA_character_)

INLINE_RX <- "(?<![\\\\$\\w])\\$(?!\\$|\\s)([^$\\n]+?)(?<!\\s)\\$(?!\\d)"
DISPLAY_RX <- "(?s)\\$\\$(.+?)\\$\\$"

strip_code <- function(md) str_remove_all(md, "(?s)```.*?```|`[^`\n]+`")

math_spans <- function(md) {
  prose = strip_code(md)
  display = str_match_all(prose, DISPLAY_RX)[[1]][, 2]
  inline = str_match_all(str_remove_all(prose, DISPLAY_RX), INLINE_RX)[[1]][, 2]
  tibble(tex = c(display, inline), display = rep(c(TRUE, FALSE), c(length(display), length(inline))))
}

# A fence line may sit in a list item ("* ```r"), as the model test's replies show.
fence_lines <- function(md) sum(str_detect(strsplit(md, "\n", fixed = TRUE)[[1]], "^\\s*(?:[-*+]\\s+|\\d+[.)]\\s+)?```"))

# A short reply is not a problem when the page is a figure or a displayed equation: pdftools spreads
#   axis labels and formulas over many characters. The prompt asks for no description of pictures,
#   so the figure sign is a caption line ("Figure: ...", "Figure 4.2", "Fig. 3") or a markdown image.
figure_or_display <- function(md) {
  prose = strip_code(md)
  str_detect(prose, FIG_CAPTION_RX) || str_detect(prose, "!\\[") || str_detect(prose, fixed("*[Figure: ")) ||
    str_detect(prose, DISPLAY_RX)
}

# One row per failed check: check, detail. pdf_chars is NA for documents with no PDF text.
check_page <- function(md, pdf_chars = NA_integer_) {
  prose = str_remove_all(strip_code(md), "\\\\\\$")
  spans = math_spans(md)
  bad = spans |> filter(is.na(map2_chr(tex, display, kx)))
  bind_rows(
    if (!nzchar(str_trim(md))) tibble(check = "empty", detail = "no text"),
    if (!is.na(pdf_chars) && pdf_chars > 300 && nchar(md) < 0.4 * pdf_chars && !figure_or_display(md))
      tibble(check = "short", detail = sprintf("%d characters against %d in the PDF text", nchar(md), pdf_chars)),
    if (fence_lines(md) %% 2) tibble(check = "fences", detail = "odd number of ``` lines"),
    if (str_count(prose, fixed("$$")) %% 2 || str_count(str_remove_all(prose, fixed("$$")), fixed("$")) %% 2)
      tibble(check = "dollars", detail = "unbalanced $ or $$"),
    if (nrow(bad)) tibble(check = "katex", detail = paste0(if_else(bad$display, "$$", "$"), str_trunc(str_squish(bad$tex), 80))))
}

# A whole reply wrapped in one ```markdown fence is unwrapped; a ``` code page is left alone.
unwrap_reply <- function(txt) {
  m = str_match(str_trim(txt), "(?s)^```(?:markdown|md)[ \t]*\n(.*)\n```$")
  if (is.na(m[1, 1])) str_trim(txt) else str_trim(m[1, 2])
}

# The slide number a page ends with ("48 / 71"), dropped when the page is assembled; the cached
#   reply keeps it. Only the last line, only N / M with N <= M, so a fraction in the text stays.
strip_slide_number <- function(md) {
  lines = strsplit(str_trim(md), "\n", fixed = TRUE)[[1]]
  if (!length(lines)) return(md)
  m = str_match(lines[length(lines)], "^\\s*(\\d{1,4})\\s*/\\s*(\\d{1,4})\\s*$")
  if (is.na(m[1, 1]) || as.integer(m[1, 2]) > as.integer(m[1, 3])) return(md)
  str_trim(paste(lines[-length(lines)], collapse = "\n"))
}

# A literal dollar sign written as \$. Code (fenced or inline) and maths that renders are set
#   aside; in what is left, a $ before a digit (or a space and a digit) is a dollar amount. If an odd number of bare $
#   then remain, none of them can be maths delimiters, so all are escaped (an "Income in $" or a
#   "df$var" in prose). Applied to every page and text document when it is assembled.
escape_dollars <- function(md) {
  if (!str_detect(md, fixed("$"))) return(md)
  store = new.env()
  store$x = character(0)
  hide = function(m) {
    if (!length(m)) return(m)
    n0 = length(store$x)
    store$x = c(store$x, m)
    paste0("\u0001", n0 + seq_along(m), "\u0002")
  }
  hide_valid = function(m, display) {
    ok = !is.na(map_chr(str_sub(m, if (display) 3 else 2, if (display) -3 else -2), kx, display = display))
    out = m
    out[ok] = hide(m[ok])
    out
  }
  t = str_replace_all(md, "(?s)```.*?```|`[^`\n]+`", hide)
  t = str_replace_all(t, DISPLAY_RX, function(m) hide_valid(m, TRUE))
  t = str_replace_all(t, INLINE_RX, function(m) hide_valid(m, FALSE))
  t = str_replace_all(t, "(?<!\\\\)\\$(?= ?\\d)", function(m) rep("\\$", length(m)))
  if (str_count(t, "(?<!\\\\)\\$") %% 2) t = str_replace_all(t, "(?<!\\\\)\\$", function(m) rep("\\$", length(m)))
  str_replace_all(t, "\u0001(\\d+)\u0002", function(m) store$x[as.integer(str_sub(m, 2, -2))])
}


# ---- 5. the model --------------------------------------------------------------------------------

model_key <- function() {
  k = Sys.getenv(BUILD_KEY_VAR)
  if (!nzchar(k)) stop("Set the environment variable ", BUILD_KEY_VAR, " (in .Renviron) first.", call. = FALSE)
  k
}

# One chat object per page: one page per call, no history.
model_chat <- function(m, key) {
  if (!identical(m$api, "openai")) stop("BUILD_MODEL$api must be 'openai' (an OpenAI-style endpoint).", call. = FALSE)
  ellmer::chat_openai_compatible(
    base_url = m$base_url, name = sub("^[a-z]+://([^/]+).*$", "\\1", m$base_url), credentials = function() key,
    model = m$id, params = ellmer::params(temperature = BUILD_TEMPERATURE), echo = "none",
    api_args = list(max_tokens = BUILD_MAX_TOKENS, usage = list(include = TRUE)))
}

# Text, USD (as the endpoint reported it, else from tokens), tokens, finish and seconds of a reply.
reply_facts <- function(chat, reply, started) {
  turn = chat$last_turn()
  tok = as.numeric(S7::prop(turn, "tokens"))
  cost = tryCatch(as.numeric(S7::prop(turn, "json")$usage$cost), error = function(e) NULL)
  from_tokens = (tok[1] * PRICE_PER_M[["input"]] + tok[2] * PRICE_PER_M[["output"]]) / 1e6
  list(text = as.character(reply), finish = as.character(S7::prop(turn, "finish_reason") %||% NA),
       tokens_in = tok[1], tokens_out = tok[2],
       usd = if (length(cost) == 1L && !is.na(cost)) cost else from_tokens, usd_reported = length(cost) == 1L,
       seconds = as.numeric(difftime(Sys.time(), started, units = "secs")))
}

root_message <- function(e, key) {
  cause = if (inherits(e$parent, "condition")) e$parent else e
  str_trunc(gsub(key, "[key]", conditionMessage(cause), fixed = TRUE), 200)
}

# Several pages in flight in this one R process, as QuestionR's llm_complete_all(): each gets its
#   own chat object, chat_async() starts it, later::run_now() turns until all have settled.
#   Returns, in order, the facts of each reply or list(error = message).
send_pages <- function(pngs, key, prompt = BUILD_PROMPT) {
  old = options(ellmer_timeout_s = CALL_TIMEOUT_S)
  on.exit(options(old), add = TRUE)
  state = new.env()
  state$out = vector("list", length(pngs))
  state$done = rep(FALSE, length(pngs))
  settle = function(i, v) { state$out[[i]] = v; state$done[[i]] = TRUE }
  iwalk(pngs, function(png, i) {
    chat = model_chat(BUILD_MODEL, key)
    started = Sys.time()
    tryCatch(promises::then(chat$chat_async(prompt, ellmer::content_image_file(png, resize = "none")),
                            onFulfilled = function(v) settle(i, tryCatch(reply_facts(chat, v, started),
                                                                         error = function(e) list(error = root_message(e, key)))),
                            onRejected = function(e) settle(i, list(error = root_message(e, key)))),
             error = function(e) settle(i, list(error = root_message(e, key))))
  })
  detect(seq_len(ceiling(2 * (CALL_TIMEOUT_S + 60))), function(k) { later::run_now(timeoutSecs = 0.5); all(state$done) })
  map(state$out, function(x) x %||% list(error = "no answer came back in time"))
}


# ---- 6. PDFs: pages to markdown ------------------------------------------------------------------

spent_so_far <- function() {
  f = list.files(PAGE_DIR, pattern = "[.]json$", recursive = TRUE, full.names = TRUE)
  sum(map_dbl(f, function(x) as.numeric(jsonlite::read_json(x)$usd %||% 0)))
}

write_utf8 <- function(txt, f) {
  dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
  writeLines(enc2utf8(txt), f, useBytes = TRUE)
}
read_utf8 <- function(f) paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

# One attempt's outcome scored: problems (a call error counts as one), so the better of two is kept.
score <- function(r, pdf_chars) {
  if (!is.null(r$error)) return(tibble(check = "call", detail = r$error))
  bind_rows(if (identical(r$finish, "max_tokens")) tibble(check = "cutoff", detail = "reply reached max_tokens"),
            check_page(unwrap_reply(r$text), pdf_chars))
}

# Renders, sends, checks and retries one group of pages; writes p0001.md and p0001.json each.
convert_group <- function(g, key, run) {
  tmp = tempfile("pages")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  pngs = pmap_chr(list(g$path, g$page, seq_len(nrow(g))), function(p, pg, i) {
    f = file.path(tmp, sprintf("%02d.png", i))
    tryCatch({ pdftools::pdf_convert(p, format = "png", pages = pg, filenames = f, dpi = BUILD_DPI, verbose = FALSE); f },
             error = function(e) NA_character_)
  })
  first = map(seq_along(pngs), function(i) list(error = "page could not be rendered"))
  ok = !is.na(pngs)
  first[ok] = send_pages(pngs[ok], key)
  probs1 = map2(first, g$pdf_chars, score)
  again = which(ok & map_int(probs1, nrow) > 0)
  second = vector("list", length(pngs))
  if (length(again)) second[again] = send_pages(pngs[again], key)
  # No key, no credit: more calls cannot succeed, so the run stops after this group.
  refused = keep(map_chr(c(first, compact(second)), function(r) r$error %||% NA_character_), function(e) isTRUE(str_detect(e, "HTTP 40[12]")))
  if (length(refused)) run$fatal = str_trunc(str_squish(refused[1]), 120)
  pwalk(list(seq_len(nrow(g)), first, second, probs1), function(i, a, b, pa) {
    tries = compact(list(a, b))
    usd = sum(map_dbl(tries, function(r) r$usd %||% 0))
    pick = if (is.null(b) || nrow(pa) <= nrow(score(b, g$pdf_chars[i]))) a else b
    run$spent = run$spent + usd
    run$paid_usd = run$paid_usd + usd
    run$paid_pages = run$paid_pages + 1L
    # A page sent again (an earlier call failed, or its reply was removed to resend it) keeps the
    #   spend and attempts already recorded, so the cap still counts them.
    jf = page_file(g$sha256[i], g$page[i], "json")
    before = if (file.exists(jf)) jsonlite::read_json(jf) else list()
    if (is.null(pick$error)) write_utf8(unwrap_reply(pick$text), page_file(g$sha256[i], g$page[i], "md"))
    dir.create(dirname(jf), recursive = TRUE, showWarnings = FALSE)
    jsonlite::write_json(list(usd = usd + as.numeric(before$usd %||% 0),
                              attempts = length(tries) + as.integer(before$attempts %||% 0L), tokens_in = pick$tokens_in %||% NA,
                              tokens_out = pick$tokens_out %||% NA, usd_reported = pick$usd_reported %||% NA, finish = pick$finish %||% NA,
                              error = pick$error %||% NA, seconds = pick$seconds %||% NA, model = BUILD_MODEL$id,
                              at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S")),
                         page_file(g$sha256[i], g$page[i], "json"), auto_unbox = TRUE, digits = NA)
  })
}

# Pages of these PDFs without a cached reply, sent IN_FLIGHT at a time until done or the cap.
convert_pdf_pages <- function(pdfs, key, est) {
  text = map(pdfs$path, function(p) tryCatch(pdftools::pdf_text(p), error = function(e) character(0)))
  jobs = pmap(list(pdfs$path, pdfs$sha256, pdfs$pages, text), function(p, sha, n, txt)
    tibble(path = p, sha256 = sha, page = seq_len(n),
           pdf_chars = if (length(txt) == n) nchar(str_trim(txt)) else NA_integer_)) |>
    list_rbind(ptype = tibble(path = character(), sha256 = character(), page = integer(), pdf_chars = integer()))
  # A page with a reply is done (even one that failed its checks twice); a page whose calls failed is tried again.
  todo = jobs |> filter(!file.exists(page_file(sha256, page, "md")))
  run = new.env()
  run$spent = spent_so_far()
  run$paid_usd = 0
  run$paid_pages = 0L
  run$stopped = FALSE
  started = Sys.time()
  message(sprintf("%d pages, %d to convert; %.2f USD already spent", nrow(jobs), nrow(todo), run$spent))
  if (!nrow(todo)) return(list(text = set_names(text, pdfs$path), run = run))
  groups = split(seq_len(nrow(todo)), ceiling(seq_len(nrow(todo)) / IN_FLIGHT))
  iwalk(groups, function(ix, k) {
    if (run$stopped) return(invisible())
    per_page = if (run$paid_pages >= 20) run$paid_usd / run$paid_pages else est
    if (run$spent + length(ix) * per_page > COST_CAP_USD) {
      run$stopped = TRUE
      return(message(sprintf("Stopped: the next %d pages would pass the %.0f USD cap (%.2f spent).",
                             length(ix), COST_CAP_USD, run$spent)))
    }
    convert_group(todo[ix, ], key, run)
    if (!is.null(run$fatal)) {
      run$stopped = TRUE
      return(message("Stopped: the endpoint refused the key or the credit: ", run$fatal))
    }
    message(sprintf("  group %s/%d: %d pages paid, %.3f USD this run, %.1f min", k, length(groups),
                    run$paid_pages, run$paid_usd, as.numeric(difftime(Sys.time(), started, units = "mins"))))
  })
  list(text = set_names(text, pdfs$path), run = run)
}

fig_file <- function(sha, page) file.path(FIG_DIR, sha, sprintf("p%04d.json", page))
figures_spent <- function() {
  f = list.files(FIG_DIR, pattern = "[.]json$", recursive = TRUE, full.names = TRUE)
  sum(map_dbl(f, function(x) as.numeric(jsonlite::read_json(x)$usd %||% 0)))
}

# The figure line of a page, or NA: no reply cached, a failed call, or NONE.
fig_text <- function(sha, page) {
  f = fig_file(sha, page)
  if (!file.exists(f)) return(NA_character_)
  t = jsonlite::read_json(f)$text %||% NA_character_
  if (is.na(t) || str_detect(t, "^\\W*NONE\\W*$")) NA_character_ else t
}

# Pages to describe: "short" pages in the problem list first, then pages whose reply has a figure
#   caption line; a page with a cached description (or NONE) is not sent again.
figure_candidates <- function(pdfs) {
  pages = pdfs |> select(id, path, sha256, pages) |>
    reframe(path, sha256, page = seq_len(pages), .by = id)
  short = if (file.exists(PROBLEMS_CSV)) utils::read.csv(PROBLEMS_CSV, colClasses = "character") |>
    filter(check == "short") |> transmute(id = file, page = as.integer(page), short = TRUE) else tibble(id = character(), page = integer(), short = logical())
  pages |> left_join(short, by = c("id", "page")) |> mutate(short = coalesce(short, FALSE)) |>
    filter(file.exists(page_file(sha256, page, "md"))) |>
    mutate(caption = !short & map2_lgl(sha256, page, function(s, p) str_detect(read_utf8(page_file(s, p, "md")), FIG_CAPTION_RX))) |>
    filter(short | caption) |>
    filter(!map2_lgl(sha256, page, function(s, p) {
      f = fig_file(s, p)
      file.exists(f) && is.na(jsonlite::read_json(f)$error %||% NA)
    })) |>
    arrange(desc(short), id, page)
}

# One call per page, IN_FLIGHT at a time, until done or FIGURE_CAP_USD.
convert_figures <- function(cands, key) {
  run = new.env()
  run$spent = figures_spent()
  run$n = 0L
  run$usd = 0
  message(sprintf("%d pages to describe (%d short); %.3f USD already spent on figures", nrow(cands), sum(cands$short), run$spent))
  if (!nrow(cands)) return(invisible(run))
  groups = split(seq_len(nrow(cands)), ceiling(seq_len(nrow(cands)) / IN_FLIGHT))
  walk(groups, function(ix) {
    per_page = if (run$n >= 20) run$usd / run$n else est_usd_page()
    if (isTRUE(run$stopped) || run$spent + length(ix) * per_page > FIGURE_CAP_USD) {
      if (!isTRUE(run$stopped)) message(sprintf("Stopped at the %.0f USD figure cap (%.3f spent).", FIGURE_CAP_USD, run$spent))
      run$stopped = TRUE
      return(invisible())
    }
    g = cands[ix, ]
    tmp = tempfile("fig")
    dir.create(tmp)
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
    pngs = pmap_chr(list(g$path, g$page, seq_len(nrow(g))), function(p, pg, i) {
      f = file.path(tmp, sprintf("%02d.png", i))
      tryCatch({ pdftools::pdf_convert(p, format = "png", pages = pg, filenames = f, dpi = BUILD_DPI, verbose = FALSE); f },
               error = function(e) NA_character_)
    })
    ok = !is.na(pngs)
    res = map(seq_along(pngs), function(i) list(error = "page could not be rendered"))
    res[ok] = send_pages(pngs[ok], key, FIGURE_PROMPT)
    pwalk(list(g$sha256, g$page, res), function(s, p, r) {
      f = fig_file(s, p)
      before = if (file.exists(f)) jsonlite::read_json(f) else list()
      txt = if (is.null(r$error)) str_squish(str_remove_all(str_trim(r$text), "^\\*?\\[?(?:Figure:\\s*)?|\\]?\\*?$")) else NA
      usd = (r$usd %||% 0) + as.numeric(before$usd %||% 0)
      run$spent = run$spent + (r$usd %||% 0)
      run$usd = run$usd + (r$usd %||% 0)
      run$n = run$n + 1L
      dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
      jsonlite::write_json(list(text = txt, usd = usd, finish = r$finish %||% NA, error = r$error %||% NA,
                                model = BUILD_MODEL$id, at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S")),
                           f, auto_unbox = TRUE, digits = NA)
    })
    message(sprintf("  %d pages described, %.3f USD this run", run$n, run$usd))
  })
  invisible(run)
}


# ---- 7. .qmd, .Rmd and .md ------------------------------------------------------------------------

# Title from the YAML header, which is dropped; every chunk opener ```{r ...} becomes ```r.
qmd_to_md <- function(path) {
  lines = readLines(path, warn = FALSE, encoding = "UTF-8")
  yaml_end = if (length(lines) && trimws(lines[1]) == "---") which(trimws(lines)[-1] %in% c("---", "..."))[1] + 1L else 0L
  yaml = if (is.na(yaml_end) || yaml_end == 0L) character(0) else lines[seq_len(yaml_end)]
  body = if (length(yaml)) lines[-seq_len(yaml_end)] else lines
  m = str_match(body, "^(\\s*)(`{3,})\\s*\\{\\s*[=.]?([A-Za-z0-9_+-]+)[^}]*\\}\\s*$")
  body = close_open_fences(if_else(is.na(m[, 1]), body, paste0(m[, 2], m[, 3], tolower(m[, 4]))))
  title = str_match(yaml, "^title:\\s*(.+?)\\s*$")[, 2] |> discard(is.na)
  title = str_remove_all(coalesce(title[1], ""), "^[\"']|[\"']$")   # no title: line gives ""
  list(title = if (nzchar(title)) title else first_heading(body, path), body = paste(body, collapse = "\n"))
}

# An opening fence (one with a language, ```r) met while a block is still open closes that block
#   first: a bare ``` line is put before it. A bare ``` toggles open/closed as usual.
close_open_fences <- function(lines) {
  fence = str_detect(lines, "^\\s*`{3,}")
  opener = fence & str_detect(lines, "^\\s*`{3,}\\s*[A-Za-z{]")
  # open_before[i]: a block is open when line i is reached
  open_before = accumulate(seq_along(lines), function(open, i) if (!fence[i]) open else if (opener[i]) TRUE else !open,
                           .init = FALSE)[seq_along(lines)]
  add = opener & open_before
  if (!any(add)) return(lines)
  unlist(map2(lines, add, function(l, a) if (a) c(str_extract(l, "^\\s*`{3,}"), l) else l))
}

# The first level-1 heading outside code (an R comment is not a heading), else the file name.
first_heading <- function(lines, path) {
  lines = strsplit(strip_code(paste(lines, collapse = "\n")), "\n", fixed = TRUE)[[1]]
  h = str_match(lines,"^#\\s+(.+?)\\s*(\\{[^}]*\\})?\\s*$")[, 2] |> discard(is.na)
  if (length(h)) h[1] else tools::file_path_sans_ext(basename(path))
}

md_copy <- function(path) {
  lines = readLines(path, warn = FALSE, encoding = "UTF-8")
  list(title = first_heading(lines, path), body = paste(lines, collapse = "\n"))
}


# ---- 8. writing the files ---------------------------------------------------------------------------

yaml_value <- function(v) {
  if (is.numeric(v)) return(if (is.na(v)) "" else format(v, scientific = FALSE))
  v = if (is.na(v)) "" else v
  paste0("\"", str_replace_all(str_replace_all(v, fixed("\\"), "\\\\"), fixed("\""), "\\\""), "\"")
}

header <- function(d, title, pages, by) {
  f = list(id = d$id, source = d$source, course = d$course, course_title = d$course_title, doc_type = d$doc_type,
           title = title, original = d$rel, pages = pages, sha256 = d$sha256, converted_by = by,
           converted_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"))
  c("---", paste0(names(f), ": ", map_chr(f, yaml_value)), "---", "")
}

# One PDF's markdown from its cached pages. NULL when a page has not been tried yet.
assemble_pdf <- function(d, text) {
  n = d$pages
  if (!all(file.exists(page_file(d$sha256, seq_len(n), "json")))) return(NULL)
  txt = text[[d$path]]
  pages = map(seq_len(n), function(p) {
    f = page_file(d$sha256, p, "md")
    info = jsonlite::read_json(page_file(d$sha256, p, "json"))
    if (!file.exists(f)) return(list(md = "", usd = info$usd %||% 0,
                                     probs = tibble(page = p, check = "call", detail = as.character(info$error %||% "no reply"))))
    md = strip_slide_number(read_utf8(f))
    fig = fig_text(d$sha256, p)
    if (!is.na(fig)) md = paste0(md, "\n\n*[Figure: ", fig, "]*")
    md = escape_dollars(md)
    list(md = md, usd = info$usd %||% 0,
         probs = mutate(check_page(md, if (length(txt) == n) nchar(str_trim(txt[p])) else NA_integer_), page = p, .before = 1))
  })
  body = paste0("<!-- page ", seq_len(n), " -->\n\n", map_chr(pages, "md"), collapse = "\n\n")
  title = first_heading(strsplit(map_chr(pages, "md")[1], "\n")[[1]], d$path)
  list(lines = c(header(d, title, n, BUILD_MODEL$id), body), body = body,
       usd = sum(map_dbl(pages, "usd")), probs = list_rbind(map(pages, "probs")))
}

assemble_text <- function(d) {
  doc = if (d$ext == "md") md_copy(d$path) else qmd_to_md(d$path)
  doc$body = escape_dollars(doc$body)
  list(lines = c(header(d, doc$title, NA_integer_, "01_convert.R (no model)"), doc$body), body = doc$body, usd = 0,
       probs = mutate(check_page(doc$body), page = NA_integer_, .before = 1))
}

# Redaction before writing: the fixed strings of REDACT_CSV (kept out of git), then two rules for
#   every document: an email address becomes [email]; a Windows user folder (C:/Users/<name>/ or
#   C:\Users\<name>\, any drive letter, backslashes single or doubled) becomes ~/. Other drive-letter
#   paths stay as written. The pre-commit scan uses the same two patterns.
EMAIL_RX <- "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
USER_DIR_RX <- "(?i)(?<![A-Za-z0-9])[A-Z]:(?:/|\\\\{1,2})Users(?:/|\\\\{1,2})[^/\\\\\\s\"'`]+(?:/|\\\\{1,2})"

redact <- function(txt) {
  if (file.exists(REDACT_CSV)) {
    r = utils::read.csv(REDACT_CSV, stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
    txt = reduce2(r$find, r$replace, function(x, f, s) str_replace_all(x, fixed(f), s), .init = txt)
  }
  txt |> str_replace_all(EMAIL_RX, "[email]") |> str_replace_all(USER_DIR_RX, "~/")
}

# Writes each document, then merges its rows into the manifest and the problem list.
write_documents <- function(docs, text) {
  made = pmap(docs, function(...) {
    d = list(...)
    a = if (d$ext == "pdf") assemble_pdf(d, text) else assemble_text(d)
    if (is.null(a)) return(NULL)
    a$lines = redact(a$lines)
    a$body = redact(a$body)
    write_utf8(a$lines, d$out)
    spans = math_spans(a$body)
    # Paths here are relative: markdown to SurvAI_Expert/, original to the source root.
    list(row = tibble(id = d$id, source = d$source, course = d$course, doc_type = d$doc_type, pages = d$pages,
                      characters = nchar(a$body), equations = nrow(spans), code_blocks = fence_lines(a$body) %/% 2,
                      problems = nrow(a$probs), usd = round(a$usd, 4), sha256 = d$sha256,
                      original = d$rel, markdown = d$out),
         probs = if (nrow(a$probs)) mutate(a$probs, file = d$id, .before = 1))
  }) |> compact()
  rows = list_rbind(map(made, "row"))
  probs = list_rbind(map(made, "probs"))
  merge_csv(rows, MANIFEST_CSV, rows$id, "id")
  merge_csv(probs, PROBLEMS_CSV, rows$id, "file",
            empty = tibble(file = character(), page = integer(), check = character(), detail = character()))
  message(sprintf("%d of %d documents written; %d not yet complete", nrow(rows), nrow(docs), nrow(docs) - nrow(rows)))
  rows
}

merge_csv <- function(new, f, ids, key, empty = new[0, ]) {
  old = if (file.exists(f)) utils::read.csv(f, stringsAsFactors = FALSE, colClasses = "character") else NULL
  keep = if (is.null(old)) NULL else old[!old[[key]] %in% ids, , drop = FALSE]
  out = bind_rows(mutate(keep %||% tibble(), across(everything(), as.character)),
                  mutate(bind_rows(empty, new), across(everything(), as.character)))
  dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(out, f, row.names = FALSE, fileEncoding = "UTF-8", na = "")
}


# ---- 9. run ----------------------------------------------------------------------------------------

# A source whose id and sha256 are in the manifest with no problems, and whose markdown exists, is
#   done: it is not read, converted or written again.
unchanged <- function(todo) {
  if (!file.exists(MANIFEST_CSV)) return(rep(FALSE, nrow(todo)))
  m = utils::read.csv(MANIFEST_CSV, stringsAsFactors = FALSE, colClasses = "character")
  if (!"sha256" %in% names(m)) return(rep(FALSE, nrow(todo)))
  ok = m |> filter(problems == "0")
  paste(todo$id, todo$sha256) %in% paste(ok$id, ok$sha256) & file.exists(todo$out)
}

dry_run <- function(all, todo, est, n_unchanged) {
  message(n_unchanged, " documents unchanged since the manifest, with no problems: not read again.")
  cached = map2_int(todo$sha256, todo$pages, function(sha, n)
    if (is.na(n)) 0L else sum(file.exists(page_file(sha, seq_len(n), "md"))))
  by_source = todo |> mutate(cached = cached) |> group_by(source) |>
    summarise(files = n(), pdfs = sum(ext == "pdf"), text_files = sum(ext != "pdf"),
              pages = sum(pages, na.rm = TRUE), pages_cached = sum(cached), .groups = "drop") |>
    mutate(est_usd = round((pages - pages_cached) * est, 2))
  message(sprintf("\nTo convert (estimate %.5f USD per page, from the model test):", est))
  print(as.data.frame(bind_rows(by_source, summarise(by_source, source = "TOTAL", across(where(is.numeric), sum)))))
  message("\nSkipped, by rule:")
  print(as.data.frame(all |> filter(!is.na(skip)) |> count(source, skip, name = "files") |> arrange(source, desc(files))))
  invisible(by_source)
}

main <- function(mode = "dry") {
  mode = match.arg(mode, c("dry", "pilot", "all", "rewrite", "figures", names(SOURCES)))
  t0 = Sys.time()
  all = list_sources()
  todo = all |> filter(is.na(skip))
  if (mode == "pilot") todo = todo |> filter(source == "jpsm", str_starts(rel, paste0(PILOT_FOLDER, "/")))
  if (mode %in% names(SOURCES)) todo = todo |> filter(source == mode)
  todo = file_facts(todo)
  # A PDF with no pages (an empty Rplots.pdf) has nothing to convert; one pdftools cannot read is
  # reported and left out.
  empty = todo |> filter(ext == "pdf", pages %in% 0L)
  bad = todo |> filter(ext == "pdf", is.na(pages))
  all = all |> mutate(skip = case_when(path %in% empty$path ~ "PDF with no pages",
                                       path %in% bad$path ~ "PDF unreadable", .default = skip))
  if (nrow(bad)) message("Unreadable PDFs, left out: ", paste(bad$rel, collapse = ", "))
  todo = todo |> filter(!path %in% c(empty$path, bad$path))
  # rewrite: every document written again from the page cache and the sources (after a change to
  #   redaction or the checks); no model call, nothing skipped as unchanged.
  # figures: describe the figures of candidate pages (FIGURE_CAP_USD); "rewrite" then adds the lines.
  if (mode == "figures") {
    run = convert_figures(figure_candidates(todo |> filter(ext == "pdf")), model_key())
    message(sprintf("Done in %.1f min: %d pages, %.3f USD this run, %.3f USD on figures in all.",
                    as.numeric(difftime(Sys.time(), t0, units = "mins")), run$n, run$usd, run$spent))
    return(invisible(run))
  }
  if (mode == "rewrite") {
    pdfs = todo |> filter(ext == "pdf")
    text = set_names(map(pdfs$path, function(p) tryCatch(pdftools::pdf_text(p), error = function(e) character(0))), pdfs$path)
    rows = write_documents(todo, text)
    message(sprintf("Rewritten in %.1f min, no model call.", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
    return(invisible(rows))
  }
  same = unchanged(todo)
  todo = todo[!same, ]
  est = est_usd_page()
  if (mode == "dry") return(invisible(dry_run(all, todo, est, sum(same))))
  message(sum(same), " documents unchanged since the manifest, with no problems: not read again.")
  key = model_key()
  pdfs = todo |> filter(ext == "pdf")
  res = convert_pdf_pages(pdfs, key, est)
  rows = write_documents(todo, res$text)
  message(sprintf("Done in %.1f min: %d pages paid, %.3f USD this run, %.2f USD in the cache%s.",
                  as.numeric(difftime(Sys.time(), t0, units = "mins")), res$run$paid_pages, res$run$paid_usd,
                  res$run$spent, if (res$run$stopped) "; STOPPED at the cap" else ""))
  invisible(rows)
}

if (sys.nframe() == 0L) main(head(c(commandArgs(trailingOnly = TRUE), "dry"), 1))
