# report.R: the Report reader. Text from a PDF (pdftools, page by page) or a Word file (its
#   word/document.xml read with xml2); one model call when the text fits, else one per part and one
#   to combine. No retrieval from the store. Function definitions and constants only.

REPORT_MAX_CHARS <- 300000L   # one call up to this; longer reports are split by pages
WORD_PAGE_CHARS <- 3000L      # a Word file has no pages: its paragraphs are grouped into parts this long
REPORT_MIN_CHARS <- 200L      # less text than this in a PDF: taken to be a scan

# list(pages = text per page, paged = TRUE for a PDF, note = a message when there is no text)
report_text <- function(path, name) {
  ext = tolower(tools::file_ext(name))
  if (ext == "pdf") {
    p = tryCatch(pdftools::pdf_text(path), error = function(e) character())
    if (sum(nchar(str_squish(p))) < REPORT_MIN_CHARS)
      return(list(pages = character(), paged = TRUE, note = "This PDF has no text layer (it looks like a scan), so it cannot be read here."))
    return(list(pages = p, paged = TRUE, note = NULL))
  }
  if (ext == "docx") {
    dir = tempfile()
    xml = tryCatch(utils::unzip(path, files = "word/document.xml", exdir = dir), error = function(e) character())
    if (!length(xml) || !file.exists(xml)) return(list(pages = character(), paged = FALSE, note = "This Word file could not be opened."))
    x = xml2::read_xml(xml)
    ns = xml2::xml_ns(x)
    paras = map_chr(xml2::xml_find_all(x, ".//w:p", ns), function(p) paste(xml2::xml_text(xml2::xml_find_all(p, ".//w:t", ns)), collapse = ""))
    unlink(dir, recursive = TRUE)
    paras = paras[nzchar(str_squish(paras))]
    if (!length(paras)) return(list(pages = character(), paged = FALSE, note = "This Word file has no text."))
    grp = cumsum(c(0, utils::head(cumsum(nchar(paras)), -1)) %/% WORD_PAGE_CHARS)
    return(list(pages = map_chr(split(paras, grp), paste, collapse = "\n"), paged = FALSE, note = NULL))
  }
  list(pages = character(), paged = FALSE, note = "Upload a PDF or a Word (.docx) file.")
}

page_text <- function(pages, paged) paste0(if (paged) paste0("[Page ", seq_along(pages), "]\n") else "", pages, collapse = "\n\n")

# Pages grouped into parts of at most REPORT_MAX_CHARS characters (a longer single page is its own part).
report_parts <- function(pages) {
  n = nchar(pages) + 20L
  if (sum(n) <= REPORT_MAX_CHARS) return(list(seq_along(pages)))
  grp = accumulate(n[-1], function(st, x) if (st$size + x > REPORT_MAX_CHARS) list(g = st$g + 1L, size = x) else list(g = st$g, size = st$size + x),
                   .init = list(g = 1L, size = n[1]))
  unname(split(seq_along(pages), map_int(grp, "g")))
}

report_calls <- function(parts) if (length(parts) == 1L) 1L else length(parts) + 1L

PART_NOTE <- paste("This is part %d of %d of the report (pages %d to %d). Fill the structure from this part only, with page",
                   "numbers; write \"not in this part\" where this part is silent.")
COMBINE_NOTE <- paste("Below are summaries of the parts of one report, each in the same structure. Combine them into one,",
                      "keeping every page number; an item is \"not stated\" only when no part states it.")

# Resolves to list(text, calls, usd).
read_report_async <- function(rep, profile, key) {
  m = profile_model(profile)
  sys = read_reflex("report.md")
  parts = report_parts(rep$pages)
  one = function(i) call_model_async(m, "report", if (length(parts) > 1) paste0(sys, "\n\n", sprintf(PART_NOTE, i, length(parts),
                                       min(parts[[i]]), max(parts[[i]]))) else sys,
                                     page_text(rep$pages[parts[[i]]], rep$paged), key)
  usd = function(x) sum(map_dbl(x, function(r) attr(r, "usage")$usd %||% NA_real_))
  if (length(parts) == 1L) return(promises::then(one(1L), function(r) list(text = as.character(r), calls = 1L, usd = usd(list(r)))))
  chain = reduce(seq_along(parts), function(p, i) promises::then(p, function(acc) promises::then(one(i), function(r) c(acc, list(r)))),
                 .init = promises::promise_resolve(list()))
  promises::then(chain, function(rs) promises::then(
    call_model_async(m, "report", paste0(sys, "\n\n", COMBINE_NOTE), paste(map_chr(rs, as.character), collapse = "\n\n---\n\n"), key),
    function(r) list(text = as.character(r), calls = length(rs) + 1L, usd = usd(c(rs, list(r))))))
}
