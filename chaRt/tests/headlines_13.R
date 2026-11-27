# Phase 13 Part A 7: the headline R writes for every gold spec (tests/gold_specs.yaml), and for four charts of the messy file, with no model call.
#   Run from inside chaRt/:   Rscript --no-init-file tests/headlines_13.R [out.md]
# Prints, and writes to `out.md` when given, a table: the gold spec's name, its description (the spec's title), R's headline, its words, and whether it
#   passed its checks (r) or fell back (fallback, with the reason).
# Always writes tests/review/headlines.md (git-ignored), for the manager's review (night task 01): every gold spec and the four messy-file charts with
#   their family, description, R's headline and the FACTS lines the headline was made from; then the skewness of each gold histogram, the moment
#   coefficient g1 = m3 / m2^(3/2) (m2 and m3 the second and third moments about the mean, each divided by n), as spec_facts() computes it.
app <- shiny::shinyAppDir(".")
source(file.path("tests", "gallery.R"))
args <- commandArgs(trailingOnly = TRUE)
work_dir <- file.path(tempdir(), "headlines13")
dir.create(work_dir, showWarnings = FALSE)
gold <- purrr::compact(purrr::map(gold_entries(), function(en) { g <- gold_load(en, work_dir); if (!is.null(g)) list(entry = en, g = g) }))

# the messy file's maker and its planted value, from the smoke test's top level, as tests/mutate_11B.R takes them
smoke <- parse(text = readLines(file.path("tests", "smoke.R"), encoding = "UTF-8"), keep.source = FALSE)
purrr::walk(purrr::keep(as.list(smoke), function(e) is.call(e) && identical(as.character(e[[1]]), "<-") && is.symbol(e[[2]]) && as.character(e[[2]]) %in% c("SECRET", "make_messy")),
            eval, envir = globalenv())
messy <- local({
  p <- make_messy(file.path(work_dir, "messy.csv")); r <- read_data(p, "messy.csv", "-99")
  cb <- new_codebook(profile_data(r$data), "messy.csv", nrow(r$data), "-99", r$encoding); cb$row_is <- "one record"
  list(data = r$data, cb = cb)
})
messy_specs <- list(list(family = "bar", x = "rating", fn = "count", title = "Records by rating"), list(family = "histogram", x = "score_1", title = "Score two"),
                    list(family = "scatter", x = "score", y = "score_1", title = "Score against score two"), list(family = "box", x = "rating", y = "score_1", title = "Score two by rating"))

head_of <- function(spec, g) tryCatch(r_headline(new_chart("c1", spec), g$cb, g$data),
                                      error = function(e) list(text = paste("ERROR:", conditionMessage(e)), source = "error", problems = character(0)))
row_of <- function(name, spec, g) {
  h <- head_of(spec, g)
  from <- if (is.null(h$facts)) character(0) else names_back(h$facts$from %||% character(0), h$facts$names)
  data.frame(chart = name, family = spec$family, description = spec$title %||% "", headline = h$text, words = hl_words(h$text), source = h$source,
             why = paste(h$problems, collapse = "; "), from = paste(from, collapse = "<br>"), stringsAsFactors = FALSE)
}
rows <- dplyr::bind_rows(c(purrr::map(gold, function(x) row_of(x$entry$name, x$entry$spec, x$g)),
                           purrr::imap(messy_specs, function(sp, i) row_of(paste0("messy ", i), sp, messy))))
esc <- function(x) gsub("|", "\\|", x, fixed = TRUE)
md <- c("| Gold spec | Description (the line under) | R's headline | Words | Checks |", "|---|---|---|---|---|",
        sprintf("| %s | %s | %s | %d | %s |", esc(rows$chart), esc(rows$description), esc(rows$headline), rows$words,
                ifelse(rows$source == "r", "passed", paste0(rows$source, ": ", esc(rows$why)))))
cat(md, sep = "\n")
cat("\n", sum(rows$source == "r"), " of ", nrow(rows), " written by R and passed; longest ", max(rows$words), " words\n", sep = "")
if (length(args)) writeLines(md, args[[1]], useBytes = TRUE)

# the skewness of each gold histogram, over the rows it plots (the x column's values that are present, after the spec's filter when it has one)
g1 <- function(x) { m <- mean(x); mean((x - m)^3) / mean((x - m)^2)^1.5 }
hists <- purrr::keep(gold, function(x) identical(x$entry$spec$family, "histogram"))
skews <- purrr::map(hists, function(x) {
  t <- tryCatch(spec_table(x$entry$spec, x$g$data, x$g$cb), error = function(e) NULL)
  v <- if (is.data.frame(t) && x$entry$spec$x %in% names(t)) t[[x$entry$spec$x]] else x$g$data[[x$entry$spec$x]]
  v <- suppressWarnings(as.numeric(v)); v <- v[is.finite(v)]
  data.frame(chart = x$entry$name, description = x$entry$spec$title %||% "", rows = length(v), g1 = round(g1(v), 3),
             tail = if (g1(v) > SPEC_FACTS_SKEW) "longer to the right" else if (g1(v) < -SPEC_FACTS_SKEW) "longer to the left" else "none named",
             headline = if (length(v) >= HEADLINE_TAIL_MIN_ROWS) "may name it" else "too few rows", stringsAsFactors = FALSE)
})
skews <- dplyr::bind_rows(skews)
sk_md <- c("| Gold histogram | Description | Rows | g1 | Tail in FACTS (beyond 1 either way) | Headline (30 rows or more) |", "|---|---|---|---|---|---|",
           sprintf("| %s | %s | %d | %.3f | %s | %s |", esc(skews$chart), esc(skews$description), skews$rows, skews$g1, skews$tail, skews$headline))
cat("\n", sk_md, sep = "\n")

dir.create(file.path("tests", "review"), showWarnings = FALSE)
# Night task 03: R's headline before the change, from tests/review/headlines_before.md (the table as it was, kept by hand) when it is there, row by row
#   (the same order: the gold specs, then the messy file), matched on the description.
before_file <- file.path("tests", "review", "headlines_before.md")
before <- if (file.exists(before_file)) {
  bl <- readLines(before_file, encoding = "UTF-8")
  start <- which(startsWith(bl, "| Family |"))[1]
  body <- if (!is.na(start)) bl[(start + 2L):length(bl)] else character(0)
  body <- body[seq_len(match(TRUE, !startsWith(body, "| "), nomatch = length(body) + 1L) - 1L)]
  cells <- purrr::map(body, function(l) strsplit(sub("^[|] ", "", sub(" [|]$", "", l)), " | ", fixed = TRUE)[[1]])
  if (length(cells) == nrow(rows) && all(purrr::map_chr(cells, 2L) == esc(rows$description))) purrr::map_chr(cells, 3L)
}
writeLines(c("# R's headline for every gold spec and four charts of the messy file", "",
             paste0("Written by tests/headlines_13.R on ", format(Sys.time(), "%Y-%m-%d %H:%M"), ", no model call. ", sum(rows$source == "r"), " of ", nrow(rows),
                    " written by R and passed their checks. The last four rows are the messy file (tests/smoke.R, make_messy())."), "",
             if (!is.null(before)) "The column \"Before\" is R's headline before night task 03 (the manager's rules after reading all 39); \"=\" when it did not change.",
             if (!is.null(before)) "",
             if (is.null(before)) "| Family | Description | R's headline | FACTS lines the headline was made from |" else "| Family | Description | Before | R's headline | FACTS lines the headline was made from |",
             if (is.null(before)) "|---|---|---|---|" else "|---|---|---|---|---|",
             sprintf(if (is.null(before)) "| %s | %s | %s%s | %s |" else "| %s | %s | %s | %s | %s |", esc(rows$family), esc(rows$description),
                     if (is.null(before)) esc(ifelse(rows$source == "r", rows$headline, paste0(rows$headline, " (", rows$source, ")"))) else ifelse(before == esc(rows$headline), "=", before),
                     if (is.null(before)) "" else esc(ifelse(rows$source == "r", rows$headline, paste0(rows$headline, " (", rows$source, ")"))),
                     ifelse(nzchar(rows$from), esc(rows$from), "(none)")),
             "", "## The skewness of each gold histogram", "",
             paste0("The measure is the moment coefficient g1 = m3 / m2^(3/2), m2 and m3 the second and third moments about the mean, each divided by n ",
                    "(no small-sample correction), over the values the chart plots. FACTS names a tail beyond SPEC_FACTS_SKEW (", SPEC_FACTS_SKEW,
                    ") either way; a headline names it only with HEADLINE_TAIL_MIN_ROWS (", HEADLINE_TAIL_MIN_ROWS, ") rows or more."), "", sk_md),
           file.path("tests", "review", "headlines.md"), useBytes = TRUE)
cat("\nwrote tests/review/headlines.md\n")
